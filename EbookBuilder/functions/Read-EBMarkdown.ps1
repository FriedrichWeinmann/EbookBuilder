function Read-EBMarkdown
{
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	
	begin
	{
		function ConvertFrom-Markdown
		{
			[CmdletBinding()]
			param (
				[string]
				$Path,
				
				[int]
				$Index
			)
			
			$lines = Get-Content -Path $Path -Encoding UTF8
			$stringBuilder = [System.Text.StringBuilder]::new()
			
			$inBlock = $false
			$blockData = [pscustomobject]@{
				Attributes = @{ }
				Type = $null
				Lines = @()
			}
			$paragraph = @()
			$firstPar = $true
			
			foreach ($line in $lines)
			{
				#region Process Block Content
				if ($inBlock)
				{
					if ($line -like '## <*')
					{
						$firstPar = ConvertFrom-MdBlock -Type $blockData.Type -Lines $blockData.Lines -Attributes $blockData.Attributes -StringBuilder $stringBuilder
						$inBlock = $false
					}
					else { $blockData.Lines += $line }
					
					continue
				}
				#endregion Process Block Content
				
				# Handle Chapter Title
				if ($line -like '# *')
				{
					$null = $stringBuilder.AppendLine("<h2>$line</h2>")
					continue
				}
				
				# Handle begin of a Block
				if ($line -like '## <*')
				{
					$inBlock = $true
					$blockData = New-Block -Line $line
					continue
				}
				
				#region Process paragraph
				if ($line.Trim() -eq "")
				{
					if (-not $paragraph) { continue }
					
					$class = 'text'
					if ($firstPar)
					{
						$class = 'firstpar'
						$firstPar = $false
					}
					
					$null = $stringBuilder.AppendLine("<p class=`"$class`">$(($paragraph -join " ") -replace '\*\*(.+?)\*\*','<b>$1</b>' -replace '_(.+?)_','<i>$1</i>')</p>")
					$paragraph = @()
					continue
				}
				
				$paragraph += $line
				#endregion Process paragraph
			}
			
			#region Ensure final paragraph is taken care of
			if ($paragraph)
			{
				$class = 'text'
				if ($firstPar)
				{
					$class = 'firstpar'
					$firstPar = $false
				}
				
				$null = $stringBuilder.AppendLine("<p class=`"$class`">$(($paragraph -join " ") -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', '<i>$1</i>')</p>")
			}
			#endregion Ensure final paragraph is taken care of
			
			New-Object EbookBuilder.Page -Property @{
				Index = $Index
				Name  = (Get-Item -Path $Path).BaseName
				Content = $stringBuilder.ToString()
				SourceName = $Path
				TimeCreated = Get-Date
				MetaData = @{ }
			}
		}
		
		function New-Block
		{
			[CmdletBinding()]
			param (
				[string]
				$Line
			)
			
			$type = $Line -replace '## <(\w+).+$', '$1'
			$attributes = @{ }
			$entries = $Line | Select-String '(\w+)="(.+?)"' -AllMatches
			foreach ($match in $entries.Matches)
			{
				$attributes[$match.Groups[1].Value] = $match.Groups[2].Value
			}
			
			[pscustomobject]@{
				Attributes = $attributes
				Type	   = $type
				Lines	   = @()
			}
		}
		
		$Index = 1
	}
	process
	{
		foreach ($pathItem in $Path)
		{
			ConvertFrom-Markdown -Path $pathItem -Index $Index
			$Index++
		}
	}
}