function Read-EBEpub {
<#
	.SYNOPSIS
		Extract chapters from an epub-formatted ebook and convert them to markdown.
	
	.DESCRIPTION
		Extract chapters from an epub-formatted ebook and convert them to markdown.
	
		Markdown parsing strongly relies on the provided replacements file.
	
	.PARAMETER Path
		The path to the ebook to parse.
	
	.PARAMETER OutPath
		The folder to which to export the chapters.
	
	.PARAMETER Name
		Name of the book being parsed.
		Used in the output files' name.
	
	.PARAMETER ReplacementPath
		Path to a PowerShell data file (*.psd1) containing replacements to use with the reading effort.
		The file should contain a single hashtable with a single key: Values.
		This shall then contain a list of replacement definitions using regex.
		Example content:
	
		@{
			Values = @(
				@{
					What = '<p class="text">(.+?)</p>'
					With = '$1'
					Weight = 1
				}
			)
		}
	
		What: The pattern in the source file to match
		With: What to replace it with
		Weight: The processing order when specifying multiple replacements. Lower numbers go first.
	
	.PARAMETER StartIndex
		The number the first chapter starts with.
		Only affects the file name of the output.
		Defaults to:1
	
	.EXAMPLE
		PS C:\> Read-EBEpub -Path '.\pirates.epub' -OutPath 'C:\ebooks\pirates\chapters' -ReplacementPath 'C:\ebooks\pirates\replacements.psd1' -Name Pirates
	
		Reads the "Pirates.epub" file, extracts the chapters to the specified output path, using the replacements provided inreplacements.psd1.
#>
	
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[Parameter(Mandatory = $true)]
		[string]
		$OutPath,
		
		[string]
		$Name = 'unknown',
		
		[string]
		$ReplacementPath,
		
		[int]
		$StartIndex = 1
	)
	
	begin{
		#region Functions
		function Convert-Chapter {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[string]
				$Content,
				
				$Replacements
			)
			$string = $Content -replace '</p>', "</p>`n" -replace '</{0,1}html[^>]{0,}>|</{0,1}body[^>]{0,}>|</{0,1}head[^>]{0,}>|</{0,1}link[^>]{0,}>|</{0,1}meta[^>]{0,}>|</{0,1}\?{0,1}xml[^>]{0,}>'
			$string = $string -split "\n" | ForEach-Object Trim | Remove-PSFNull | Join-String "`n`n"
			foreach ($item in $Replacements | Sort-Object Weight) {
				$string = $string -replace $item.What, $item.With
			}
			$string -replace '</{0,1}p[^>]{0,}>' -replace "(?s)\n{3,}", "`n`n"
		}
		#endregion Functions
		
		$tempFolder = Join-Path -Path (Get-PSFPath -Name Temp) -ChildPath "Ebook_Temp_$(Get-Random)"
		$null = New-Item -Path $tempFolder -ItemType Directory -Force
		$chapterIndex = $StartIndex
		$outputPath = Resolve-PSFPath -Path $OutPath -Provider FileSystem -SingleItem
		
		$replacements = @()
		if ($ReplacementPath) {
			$data = Import-PSFPowerShellDataFile -Path $ReplacementPath
			$replacements = foreach ($entry in $data.Values) {
				[PSCustomObject]$entry
			}
		}
		
	}
	process
	{
		foreach ($filePath in $Path) {
			foreach ($resolvedPath in Resolve-PSFPath -Path $filePath) {
				Expand-Archive -Path $resolvedPath -DestinationPath $tempFolder -Force
				foreach ($chapter in Get-ChildItem -Path "$tempFolder\OEBPS\sections") {
					$content = [System.IO.File]::ReadAllText($chapter.FullName)
					$newContent = Convert-Chapter -Content $content -Replacements $Replacements
					$newFileName = '{0}-{1:D4}.md' -f $Name, $chapterIndex
					[System.IO.File]::WriteAllText("$outputPath\$newFileName", $newContent)
					$chapterIndex++
				}
				Remove-Item -Path "$tempFolder\*" -Force -Recurse
			}
		}
	}
	end
	{
		Remove-Item -Path $tempFolder -Force -Recurse -ErrorAction Ignore
	}
}