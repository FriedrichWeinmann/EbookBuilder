function Export-EBRoyalRoadPage
{
<#
	.SYNOPSIS
		Export book pages as HTML document for publishing on Royal Road.
	
	.DESCRIPTION
		Export book pages as HTML document for publishing on Royal Road.
		This involves resolving all stylesheets and converting them to inline style-attributes.
	
	.PARAMETER Name
		Name of the series.
	
	.PARAMETER Path
		Path to the folder in which to create files.
		Creates one file per chapter.
		Folder must exist.
	
	.PARAMETER CssData
		CSS style content to use.
		If left empty, it will use the module defaults.
	
	.PARAMETER Page
		The page object to generate documents for.
		Must be the output of Read-DBMarkdown.
	
	.EXAMPLE
		PS C:\> Export-EBRoyalRoadPage -Name 'MyBookSeries' -Path '.' -Page $page
	
		Exports all pages to the current folder.
#>
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[Parameter(Mandatory = $true)]
		[string]
		$Path,
		
		[string]
		$CssData,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[EbookBuilder.Page[]]
		$Page
	)
	
	begin
	{
		$cssContent = $CssData
		if (-not $cssContent) {
			$cssContent = [System.IO.File]::ReadAllText((Resolve-Path "$($script:ModuleRoot)\data\Common.css"), [System.Text.Encoding]::UTF8)
		}
		$styles = Read-EBCssStyleSheet -CssData $cssContent -Merge
		$resolvedPath = Resolve-PSFPath -Path $Path
		$encoding = [System.Text.UTF8Encoding]::new()
		$index = 1
	}
	process
	{
		foreach ($pageObject in $Page) {
			$newFile = Join-Path -Path $resolvedPath -ChildPath ("{0}_{1:D5}.html" -f $Name, $index)
			$content = $pageObject.Content | ConvertTo-EBHtmlInlineStyle -Style $styles
			if (-not (Test-Path $newFile)) {
				Write-PSFMessage -Level Host -Message 'Creating new chapter: {0:D5} ({1})' -StringValues $index, $newFile
			}
			else {
				$currentContent = [System.IO.File]::ReadAllText($newFile, $encoding)
				if ($currentContent -ne $content) {
					Write-PSFMessage -Level Host -Message 'Updating chapter: {0:D5} ({1})' -StringValues $index, $newFile
				}
			}
			[System.IO.File]::WriteAllText($newFile, $content, $encoding)
			
			$index++
		}
	}
}