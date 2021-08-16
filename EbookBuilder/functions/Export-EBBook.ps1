function Export-EBBook
{
<#
	.SYNOPSIS
		Exports pages and images into a epub ebook.
	
	.DESCRIPTION
		Exports pages and images into a epub ebook.
	
	.PARAMETER Path
		The path to export to.
		Will ignore the name if an explicit filename was specified.
	
	.PARAMETER Name
		The name of the ebook. Will also be used for the filename if a path to a folder was specified.
		Defaults to: New Book
	
	.PARAMETER FileName
		Explicitly specify the name of the exported file.
		The "Name" parameter will be used to calculate it if not specified.
	
	.PARAMETER Author
		The author to set for the ebook.
	
	.PARAMETER Publisher
		The publisher of the ebook.
	
	.PARAMETER CssData
		Custom CSS to use to style the ebook.
		Allows you to tune how the ebook is styled.
	
	.PARAMETER Page
		The pages to compile into an ebook.
	
	.PARAMETER Series
		The name of the series this book is part of.
		Added as metadata to the build ebook.
	
	.PARAMETER Volume
		The volume number of the series this book is part of.
		Only effecive if used together with the Series parameter.
	
	.PARAMETER Tags
		Any tags to add to the book's metadata.
	
	.PARAMETER Description
		A description to include in the book's metadata.
	
	.EXAMPLE
		PS C:\> Read-EBMicrosoftDocsIndexPage -Url https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory | Export-EBBook -Path . -Name ads-best-practices.epub -Author "Friedrich Weinmann" -Publisher "Infernal Press"
		
		Compiles an ebook out of the Active Directory Best Practices.
#>
	[CmdletBinding()]
	param (
		[PsfValidateScript('PSFramework.Validate.FSPath.FileOrParent', ErrorString = 'PSFramework.Validate.FSPath.FileOrParent')]
		[string]
		$Path = ".",
		
		[string]
		$Name = "New Book",
		
		[string]
		$FileName,
		
		[string]
		$Author = $env:USERNAME,
		
		[string]
		$Publisher = $env:USERNAME,
		
		[string]
		$CssData,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[EbookBuilder.Item[]]
		$Page,
		
		[string]
		$Series,
		
		[int]
		$Volume,
		
		[string[]]
		$Tags,
		
		[string]
		$Description
	)
	
	begin
	{
		#region Functions
		function Write-File
		{
			[CmdletBinding()]
			param (
				[System.IO.DirectoryInfo]
				$Root,
				
				[string]
				$Path,
				
				[string]
				$Text
			)
			
			$tempPath = Resolve-PSFPath -Path (Join-Path $Root.FullName $Path) -NewChild
			Write-PSFMessage -Level SomewhatVerbose -Message "Writing file: $($Path)"
			$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
			[System.IO.File]::WriteAllText($tempPath, $Text, $utf8NoBom)
		}
		
		function ConvertTo-ManifestPageData
		{
			[CmdletBinding()]
			param (
				$Pages
			)
			
			$lines = $Pages | ForEach-Object {
					'    <item id="{0}" href="Text/{0}" media-type="application/xhtml+xml"/>' -f $_.EbookFileName
			}
			$lines -join "`n"
		}
		
		function ConvertTo-ManifestImageData
		{
			[CmdletBinding()]
			param (
				$Images
			)
			
			$lines = $images | ForEach-Object {
				'    <item id="{0}" href="Images/{1}" media-type="image/{2}"/>' -f ($_.ImageID -replace "\s","_"), $_.FileName, "Jpeg"
			}
			$lines -join "`n"
		}
		#endregion Functions
		
		#region Prepare Resources
		if (-not $FileName) { $FileName = $Name }
		$resolvedPath = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem -NewChild
		if (Test-Path $resolvedPath)
		{
			if ((Get-Item $resolvedPath).PSIsContainer) { $resolvedPath = Join-Path $resolvedPath $FileName }
		}
		if ($resolvedPath -notlike "*.epub") { $resolvedPath += ".epub" }
		$zipPath = $resolvedPath -replace 'epub$', 'zip'
		$cssContent = $CssData
		if (-not $cssContent)
		{
			$cssContent = [System.IO.File]::ReadAllText((Resolve-Path "$($script:ModuleRoot)\data\Common.css"), [System.Text.Encoding]::UTF8)
		}
		$pages = @()
		$images = @()
		#endregion Prepare Resources
	}
	process
	{
		#region Process Input items
		foreach ($item in $Page)
		{
			switch ($item.Type)
			{
				"Page" { $pages += $item }
				"Image" { $images += $item }
			}
		}
		#endregion Process Input items
	}
	end
	{
		$id = 1
		$pages = $pages | Sort-Object Index | Select-PSFObject -KeepInputObject -Property @{
			Name = "EbookFileName"
			# Expression = { "{0}.xhtml" -f (New-Guid) }
			Expression = { "Chapter {0:D3}.xhtml" -f $_.Index }
		}, @{
			Name = "TocIndex"
			Expression = { $id++ }
		}
		
		$tempPath = New-Item -Path $env:TEMP -Name "Ebook-$(Get-Random -Maximum 99999 -Minimum 10000)" -ItemType Directory -Force
		
		Write-File -Root $tempPath -Path 'mimetype' -Text 'application/epub+zip'
		$metaPath = New-Item -Path $tempPath.FullName -Name "META-INF" -ItemType Directory
		Write-File -Root $metaPath -Path 'container.xml' -Text @'
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
    <rootfiles>
        <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
   </rootfiles>
</container>
'@
		$oebpsPath = New-Item -Path $tempPath.FullName -Name "OEBPS" -ItemType Directory
		
		#region content.opf
		$contentOpfText = @"
<?xml version="1.0" encoding="utf-8"?>
<package version="2.0" unique-identifier="uuid_id" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata">
    <dc:publisher>$Publisher</dc:publisher>
    <dc:language>en</dc:language>
    <dc:creator opf:role="aut" opf:file-as="$Author">$Author</dc:creator>
    <dc:title opf:file-as="$Name">$Name</dc:title>
"@
		if ($Description) { $contentOpfText += "`n    <dc:description>$Description</dc:description>" }
		if ($Series) {
			$contentOpfText += @"

    <opf:meta content="$Series" name="calibre:series" />
    <opf:meta content="$Volume.0" name="calibre:series_index" />
"@
		}
		foreach ($tag in $Tags) {
			$contentOpfText += "`n    <dc:subject>$tag</dc:subject>"
		}
		$contentOpfText += @"

  </metadata>
  <manifest>
$(ConvertTo-ManifestPageData -Pages $pages)
$(ConvertTo-ManifestImageData -Images $images)
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="style.css" href="Styles/Style.css" media-type="text/css"/>
  </manifest>
  <spine toc="ncx">
$($pages | Format-String -Format '    <itemref idref="{0}"/>' -Property EbookFileName | Join-String "`n")
  </spine>
  <guide/>
</package>
"@
		Write-File -Root $oebpsPath -Path 'content.opf' -Text $contentOpfText
		#endregion content.opf
		
		#region TOC.ncx
		$bookMarkText = ($pages | ForEach-Object {
				$tocIndex = $_.Index
				if ($_.TocIndex) { $tocIndex = $_.TocIndex}
				@'
    <navPoint id="navPoint-{0}" playOrder="{0}">
      <navLabel>
        <text>Chapter {0}</text>
      </navLabel>
      <content src="Text/{1}"/>
    </navPoint>
'@ -f $tocIndex, $_.EbookFileName
		}) -join "`n"
		
		$contentTocNcxText = @'
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN"
 "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"><ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/">
  <head>
    <meta content="{0}" name="dtb:uid"/>
    <meta content="1" name="dtb:depth"/>
    <meta content="0" name="dtb:totalPageCount"/>
    <meta content="0" name="dtb:maxPageNumber"/>
  </head>
  <docTitle>
    <text>{1}</text>
  </docTitle>
  <navMap>
{2}
  </navMap>
</ncx>
'@ -f (New-Guid), $Name, $bookMarkText
		Write-File -Root $oebpsPath -Path 'toc.ncx' -Text $contentTocNcxText
		#endregion TOC.ncx
		
		#region Files
		$stylesPath = New-Item -Path $oebpsPath.FullName -Name "Styles" -ItemType Directory
		Write-File -Root $stylesPath -Path 'Style.css' -Text $cssContent
		
		$textPath = New-Item -Path $oebpsPath.FullName -Name 'Text' -ItemType Directory
		foreach ($pageItem in $pages)
		{
			$pageText = @'
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
  "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>{0}</title>
  <meta content="http://www.w3.org/1999/xhtml; charset=utf-8" http-equiv="Content-Type"/>
  <link href="../Styles/Style.css" type="text/css" rel="stylesheet"/>
</head>
<body>
{1}
</body>
</html>
'@ -f $Name, $pageItem.Content
			Write-File -Root $textPath -Path $pageItem.EbookFileName -Text $pageText
		}
		#endregion Files
		
		#region Images
		if ($images)
		{
			$imagesPath = New-Item -Path $oebpsPath.FullName -Name 'Images' -ItemType Directory
			
			foreach ($image in $images)
			{
				$targetPath = Join-Path $imagesPath.FullName $image.FileName
				[System.IO.File]::WriteAllBytes($targetPath, $image.Data)
			}
		}
		#endregion Images
		
		Get-ChildItem $tempPath | Compress-Archive -DestinationPath $zipPath -Force
		if (Test-Path -Path $resolvedPath) {
			Remove-Item -Path $resolvedPath -Force -ErrorAction Ignore
		}
		Rename-Item -Path $zipPath -NewName (Split-Path $resolvedPath -Leaf)
		Remove-Item $tempPath -Recurse -Force
	}
}