function Export-EBBook
{
	[CmdletBinding()]
	param (
		[PsfValidateScript({ Resolve-PSFPath -Path $args[0] -Provider FileSystem -SingleItem -NewChild }, ErrorMessage = "Folder to place the file in must exist!")]
		[string]
		$Path = ".",
		
		[string]
		$Name = "New Book",
		
		[string]
		$Author = $env:USERNAME,
		
		[string]
		$Publisher = $env:USERNAME,
		
		[string]
		$CssData,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[EbookBuilder.Item[]]
		$Page
	)
	
	begin
	{
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
		
		function ConvertToManifestImageData
		{
			[CmdletBinding()]
			param (
				$Images
			)
			
			$lines = $images | ForEach-Object {
				'    <item id="{0}" href="Images/{1}" media-type="image/{2}"/>' -f $_.ImageID, $_.FileName, "Jpeg"
			}
			$lines -join "`n"
		}
		
		
		#region Prepare Resources
		$resolvedPath = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem -NewChild
		if (Test-Path $resolvedPath)
		{
			if ((Get-Item $resolvedPath).PSIsContainer) { $resolvedPath = Join-Path $resolvedPath $Name }
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
			Expression = { "{0}.xhtml" -f (New-Guid) }
		}, @{
			Name = "TocIndex"
			Expression = { $id++ }
		}
		
		$tempPath = New-Item -Path $env:TEMP -Name "Ebook-$(Get-Random -Maximum 99999 -Minimum 10000)" -ItemType Directory -Force
		
		Write-File -Root $tempPath -Path 'mimetype' -Text 'application/epub+zip'
		$metaPath = New-Item -Path $tempPath.FullName -Name "META-INF" -ItemType Directory
		Write-File -Root $metaPath -Path 'cotnainer.xml' -Text @'
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
    <rootfiles>
        <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
   </rootfiles>
</container>
'@
		$oebpsPath = New-Item -Path $tempPath.FullName -Name "OEBPS" -ItemType Directory
		
		#region content.opf
		$contentOpfText = @'
<?xml version="1.0" encoding="utf-8"?>
<package version="2.0" unique-identifier="uuid_id" xmlns="http://www.idpf.org/2007/opf">
  <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata">
    <dc:publisher>{0}</dc:publisher>
    <dc:language>en</dc:language>
    <dc:creator opf:role="aut" opf:file-as="{1}">{1}</dc:creator>
    <dc:title opf:file-as="{2}">{2}</dc:title>
  </metadata>
  <manifest>
{3}
{4}
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="style.css" href "Styles/Style.css" media-type="application/css"/>
  </manifest>
  <spine toc="ncx">
{5}
  </spine>
  <guide/>
</package>
'@ -f $Publisher, $Author, $Name, (ConvertTo-ManifestPageData -Pages $pages), (ConvertToManifestImageData -Images $images), (($pages | ForEach-Object { '    <itemref idref="{0}"/>' -f $_.EbookFileName }) -join "`n")
		Write-File -Root $oebpsPath -Path 'content.opf' -Text $contentOpfText
		#endregion content.opf
		
		#region TOC.ncx
		$bookMarkText = ($pages | ForEach-Object {
				@'
    <navPoint id="navPoint-{0}" playOrder="{0}">
      <navLabel>
        <text>Chapter {0}</text>
      </navLabel>
      <content src="Text/{1}"/>
    </navPoint>
'@ -f $_.TocIndex, $_.EbookFileName
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
		
		Get-ChildItem $tempPath | Compress-Archive -DestinationPath $zipPath
		Rename-Item -Path $zipPath -NewName (Split-Path $resolvedPath -Leaf)
		Remove-Item $tempPath -Recurse -Force
	}
}