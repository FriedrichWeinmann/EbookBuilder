function Read-EBMarkdown {
	<#
	.SYNOPSIS
		Reads a markdown file and converts it to a page to be built into an ebook
	
	.DESCRIPTION
		Reads a markdown file and converts it to a page to be built into an ebook
	
	.PARAMETER Path
		Path to the file to read.
	
	.EXAMPLE
		PS C:\> Get-ChildItem *.md | Read-EBMarkdown

		Reads and converts all markdown files in he current folder
	#>
	[OutputType([EbookBuilder.Page])]
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	
	begin {
		function ConvertFrom-Markdown {
			[OutputType([EbookBuilder.Page])]
			[CmdletBinding()]
			param (
				[string]
				$Path,
				
				[int]
				$Index
			)
			
			$lines = Get-Content -Path $Path -Encoding UTF8
			$stringBuilder = New-SBStringBuilder -Name ebook
			
			$inBlock = $false
			$blockData = [pscustomobject]@{
				Attributes = @{ }
				Type	   = $null
				Lines	   = @()
				File	   = $Path
			}
			$paragraph = @()
			$firstPar = $true
			
			foreach ($line in $lines) {
				#region Process Block Content
				if ($inBlock) {
					if ($line -like '## <*') {
						try { $firstPar = ConvertFrom-MdBlock -Type $blockData.Type -Lines $blockData.Lines -Attributes $blockData.Attributes -StringBuilder $stringBuilder }
						catch { Stop-PSFFunction -Message 'Failed to convert block' -ErrorRecord $_ -Target $blockData -EnableException $true -Cmdlet $PSCmdlet }
						$inBlock = $false
					}
					else { $blockData.Lines += $line }
					
					continue
				}
				#endregion Process Block Content
				
				# Handle Chapter Title
				if ($line -like '# *') {
					$null = $stringBuilder.AppendLine("<h2>$($line -replace '^# ')</h2>")
					continue
				}
				
				# Handle begin of a Block
				if ($line -like '## <*') {
					$inBlock = $true
					$blockData = New-Block -Line $line -Path $Path
					continue
				}
				
				#region Process paragraph
				if ($line.Trim() -eq "") {
					if (-not $paragraph) { continue }
					
					$class = 'text'
					if ($firstPar) {
						$class = 'firstpar'
						$firstPar = $false
					}
					
					$null = $stringBuilder.AppendLine("<p class=`"$class`">$(($paragraph -join " ") -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', '<i>$1</i>')</p>")
					$paragraph = @()
					continue
				}
				
				$paragraph += $line
				#endregion Process paragraph
			}
			
			#region Ensure final paragraph is taken care of
			if ($paragraph) {
				$class = 'text'
				if ($firstPar) {
					$class = 'firstpar'
					$firstPar = $false
				}
				
				$null = $stringBuilder.AppendLine("<p class=`"$class`">$(($paragraph -join " ") -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', '<i>$1</i>')</p>")
			}
			#endregion Ensure final paragraph is taken care of
			
			New-Object EbookBuilder.Page -Property @{
				Index = $Index
				Name  = (Get-Item -Path $Path).BaseName
				Content = Close-SBStringBuilder -Name ebook
				SourceName = $Path
				TimeCreated = Get-Date
				MetaData = @{ }
			}
		}
		
		function New-Block {
			[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
			[CmdletBinding()]
			param (
				[string]
				$Line,
				
				[string]
				$Path
			)
			
			$type = $Line -replace '## <(\w+).+$', '$1'
			$attributes = @{ }
			$entries = $Line | Select-String '(\w+)="(.+?)"' -AllMatches
			foreach ($match in $entries.Matches) {
				$attributes[$match.Groups[1].Value] = $match.Groups[2].Value
			}
			
			[pscustomobject]@{
				Attributes = $attributes
				Type	   = $type
				Lines	   = @()
				File	   = $Path
			}
		}
		
		$Index = 1
	}
	process {
		foreach ($pathItem in $Path) {
			Write-PSFMessage -Message "Processing: $pathItem"
			ConvertFrom-Markdown -Path $pathItem -Index $Index
			$Index++
		}
	}
}