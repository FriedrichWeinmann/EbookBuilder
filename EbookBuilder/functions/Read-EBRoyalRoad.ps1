function Read-EBRoyalRoad {
<#
	.SYNOPSIS
		Reads an entire series from Royal Road.
	
	.DESCRIPTION
		Reads an entire series from Royal Road.
		Converts it into the markdown format expected by Read-EBMarkdown.
	
	.PARAMETER Url
		The Url to the first chapter of a given Royal Road series
	
	.PARAMETER Name
		Name of the series
	
	.PARAMETER ConfigFile
		Path to a book project configuration file, replacing all the other parameters with values from it.
		For more details on configuration files, see New-EBBookProject.
	
	.PARAMETER Books
		A hashtable mapping page numbers as the start of a book to the name of that book.
		If left empty, there will only be one book, named for the series.
		Each page number key must an integer type.
	
	.PARAMETER OutPath
		The folder in which to create one subfolder per book, in which the chapter files will be created.
	
	.PARAMETER NoHeader
		The book does not include a header in the text portion.
		Will take the chapter-name as header instead.
	
	.PARAMETER ChapterOverride
		Chapters to skip.
		Intended for chapters where manual edits were performed and you do not want to overwrite them on the next sync.
	
	.EXAMPLE
		PS C:\> Read-EBRoyalRoad -Url https://www.royalroad.com/fiction/12345/evil-incarnate/chapter/666666/1-end-of-all-days -Name 'Evil Incarnate' -OutPath .
		
		Downloads the specified series, creates a folder in the current path and writes each chapter as its own .md file into that folder.
#>
	[CmdletBinding(DefaultParameterSetName = 'Explicit')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
		[string]
		$Url,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Explicit')]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ParameterSetName = 'Config')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[string]
		$ConfigFile,
		
		[Parameter(ParameterSetName = 'Explicit')]
		[hashtable]
		$Books = @{ },
		
		[Parameter(ParameterSetName = 'Explicit')]
		[string]
		$OutPath,

		[Parameter(ParameterSetName = 'Explicit')]
		[switch]
		$NoHeader,
		
		[Parameter(ParameterSetName = 'Explicit')]
		[int[]]
		$ChapterOverride = @()
	)
	
	begin {
		$index = 1
		$bookCount = 1
		$replacements = @{ }
		$chaptersToSkip = $ChapterOverride
		
		#region Process Config File
		if ($ConfigFile) {
			$baseFolder = Split-Path -Path (Resolve-PSFPath -Path $ConfigFile)
			$config = Import-PSFPowerShellDataFile -Path $ConfigFile
			$Name = $config.Name
			$Url = $config.Url
			if ($config.StartIndex) { $index = $config.StartIndex }
			if ($config.BookIndex) { $bookCount = $config.BookIndex }
			if ($config.ContainsKey('HasTitle')) { $NoHeader = -not $config.HasTitle }
			if ($config.Books) { $Books = $config.Books }
			if ($config.ChapterOverride) { $chaptersToSkip = $config.ChapterOverride | Invoke-Expression | Write-Output }
			$OutPath = Join-Path -Path $baseFolder -ChildPath $config.OutPath

			if ($config.Replacements) {
				$replacementRoot = Join-Path -Path $baseFolder -ChildPath $config.Replacements
				foreach ($file in Get-ChildItem -Path $replacementRoot -Filter *.psd1) {
					$entrySet = Import-PSFPowerShellDataFile -Path $file.FullName
					foreach ($pair in $entrySet.GetEnumerator()) {
						if (-not $replacements[$pair.Name]) { $replacements[$pair.Name] = @{ } }
						foreach ($childPair in $pair.Value.GetEnumerator()) {
							$replacements[$pair.Name][$childPair.Name] = [PSCustomObject]$childPair.Value
						}
					}
				}
			}
		}
		#endregion Process Config File
		
		if (-not $Books[1]) {
			$Books[1] = $Name
		}
		$currentBook = '{0} - {1}' -f $bookCount, $Books[$index]
		$currentBookPath = Join-Path -Path $OutPath -ChildPath $currentBook
		
		if (-not (Test-Path -Path $currentBookPath)) {
			$null = New-Item -Path $currentBookPath -Force -ItemType Directory -ErrorAction Stop
		}
	}
	process {
		$nextLink = $Url
		while ($nextLink) {
			Write-PSFMessage -Message 'Processing {0} Chapter {1} : {2}' -StringValues $Name, $index, $nextLink
			try { $page = Read-RRChapter -Url $nextLink -Index $index -NoHeader:$NoHeader -Replacements $replacements }
			catch { throw }
			$nextLink = $page.NextLink
			
			if ($index -notin $chaptersToSkip) {
				$page.TextMD | Set-Content -Path ("{0}\{1}-{2:D4}-{3:D4}.md" -f $currentBookPath, $Name, $bookCount, $index) -Encoding UTF8
			}
			
			$index++
			if ($Books[$index]) {
				$bookCount++
				$currentBook = '{0} - {1}' -f $bookCount, $Books[$index]
				$currentBookPath = Join-Path -Path $OutPath -ChildPath $currentBook
				
				if (-not (Test-Path -Path $currentBookPath)) {
					$null = New-Item -Path $currentBookPath -Force -ItemType Directory -ErrorAction Stop
				}
			}
		}
	}
}