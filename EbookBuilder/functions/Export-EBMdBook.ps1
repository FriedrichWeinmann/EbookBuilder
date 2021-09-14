function Export-EBMdBook {
<#
	.SYNOPSIS
		Converts a markdown-based book project into epub ebooks.
	
	.DESCRIPTION
		Converts a markdown-based book project into epub ebooks.
		This is the top-level execution command for processing the book pipeline.
	
		For details, see the description on New-EBBookProject.
	
	.PARAMETER ConfigFile
		The path to the configuration file, defining the properties of the book project.
	
	.EXAMPLE
		PS C:\> Export-EBMdBook -ConfigFile .\config.psd1
	
		Builds the book project in the current folder.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[string]
		$ConfigFile
	)
	
	$baseFolder = Split-Path -Path (Resolve-PSFPath -Path $ConfigFile)
	$config = Import-PSFPowerShellDataFile -Path $ConfigFile
	$bookRoot = Join-Path -Path $baseFolder -ChildPath $config.OutPath
	$blockRoot = Join-Path -Path $baseFolder -ChildPath $config.Blocks
	$exportPath = Join-Path -Path $baseFolder -ChildPath $config.ExportPath
	$rrExportPath = ''
	if ($config.RRExportPath) { $rrExportPath = Join-Path -Path $baseFolder -ChildPath $config.RRExportPath }
	
	$author = "Unknown"
	if ($config.Author) { $author = $config.Author }
	$publisher = "Unknown"
	if ($config.Publisher) { $publisher = $config.Publisher }
	
	$cssPath = $null
	if ($config.Style) {
		$cssPath = Join-Path -Path $baseFolder -ChildPath $config.Style
	}
	$rrCssPath = $null
	if ($config.RRStyle) {
		$rrCssPath = Join-Path -Path $baseFolder -ChildPath $config.RRStyle
	}
	$inlineHash = @{ }
	if ($config.InlineConfig) {
		$inlineHash = Import-PSFPowerShellDataFile -Path (Join-Path -Path $baseFolder -ChildPath $config.InlineConfig)
	}
	
	foreach ($file in Get-ChildItem -Path $blockRoot -File -Filter *.ps1) {
		& {
			. $file.FullName
		}
	}
	
	if ($rrExportPath) {
		$rrExportParam = @{
			Path = $rrExportPath
			Name = $config.Name
		}
		if ($cssPath -and -not $rrCssPath) {
			$rrExportParam.CssData = Get-ChildItem -Path $cssPath -Filter *.css | ForEach-Object {
				Get-Content -Path $_.FullName
			} | Join-String -Separator "`n"
		}
		if ($rrCssPath) {
			$rrExportParam.CssData = Get-ChildItem -Path $rrCssPath -Filter *.css | ForEach-Object {
				Get-Content -Path $_.FullName
			} | Join-String -Separator "`n"
		}
		
		$rrExportPipe = { Export-EBRoyalRoadPage @rrExportParam }.GetSteppablePipeline()
		$rrExportPipe.Begin($true)
	}
	
	foreach ($folder in Get-ChildItem -Path $bookRoot -Directory) {
		$volume = ($folder.Name -split "-")[0] -as [int]
		$bookName = ($folder.Name -split "-", 2)[1].Trim()
		
		$exportParam = @{
			Name = $bookName
			FileName = '{0:D3}-{1}' -f $volume, $bookName
			Path = $exportPath
			Author = $author
			Publisher = $publisher
			Series = $config.Name
			Volume = $volume
		}
		if ($cssPath) {
			$exportParam.CssData = Get-ChildItem -Path $cssPath -Filter *.css | ForEach-Object {
				Get-Content -Path $_.FullName
			} | Join-String -Separator "`n"
		}
		if ($config.Tags) { $exportParam.Tags = $config.Tags }
		
		$exportPipe = { Export-EBBook @exportParam }.GetSteppablePipeline()
		$exportPipe.Begin($true)
		Get-ChildItem -Path $folder.FullName -File -Filter *.md | Read-EBMarkdown -InlineStyles $inlineHash | ForEach-Object {
			$exportPipe.Process($_)
			if ($rrExportPath) { $rrExportPipe.Process($_) }
		}
		$picturePath = Join-Path -Path $folder.FullName -ChildPath pictures
		if (Test-Path -Path $picturePath) {
			foreach ($file in Get-ChildItem -Path $picturePath -File | Where-Object Extension -in '.jpeg', '.png', '.jpg', '.bmp') {
				$pictureObject = [EbookBuilder.Picture]::GetPicture($file)
				$exportPipe.Process($pictureObject)
			}
		}
		$exportPipe.End()
	}
	if ($rrExportPath) { $rrExportPipe.End() }
}