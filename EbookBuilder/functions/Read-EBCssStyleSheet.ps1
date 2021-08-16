function Read-EBCssStyleSheet
{
<#
	.SYNOPSIS
		Parse a stylesheet and convert it into an object model.
	
	.DESCRIPTION
		Parse a stylesheet and convert it into an object model.
	
	.PARAMETER CssData
		CSS data provided as a string.
	
	.PARAMETER Path
		Path to CSS stylesheets to parse.
	
	.PARAMETER Merge
		For all styles bound to a class, merge in the settings of the base styles for the tag the class applies to.
	
	.EXAMPLE
		PS C:\> Read-EBCssStyleSheet -CssData $content
	
		Parses the CSS styles contained as string in $content
	
	.EXAMPLE
		PS C:\> Get-ChildItem *.css | Read-EBCssStyleSheet
	
		Parses all CSS stylesheets in the current folder.
#>
	[OutputType([EbookBuilder.StyleObject])]
	[CmdletBinding(DefaultParameterSetName = 'Text')]
	param (
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Text')]
		[string]
		$CssData,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'File')]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[switch]
		$Merge
	)
	
	begin{
		#region Functions
		function Convert-StyleSheet {
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[string[]]
				$Text,
				
				[hashtable]
				$ResultHash
			)
			
			begin {
				$currentTag = ''
				$currentClass = '_default'
				$inComment = $false
			}
			process {
				foreach ($line in $Text | Get-SubString -Trim " " | Split-String "`n" | Get-SubString -Trim " " | Remove-PSFNull) {
					Write-PSFMessage -Level InternalComment -Message ' {0}' -StringValues $line
					#region Comments
					if ($line -match "^/\*") { $inComment = $true }
					if ($line -match "\*/") { $inComment = $false }
					if ($inComment -or $line -match "^/\*" -or $line -match "\*/") { continue }
					#endregion Comments
					
					#region Close CSS
					if ($line -eq "}") {
						$currentTag = ''
						$currentClass = '_default'
						
						continue
					}
					#endregion Close CSS
					
					#region Open CSS
					if ($line -like "*{") {
						$tempLine = $line | Get-SubString -TrimEnd " {"
						$segments = $tempLine -split "\.",2
						$currentTag = $segments[0]
						if ($segments[1]) { $currentClass = $segments[1] }
						else { $currentClass = '_default' }
						continue
					}
					#endregion Open CSS
					
					#region Content
					if (-not $ResultHash[$currentTag]) { $ResultHash[$currentTag] = @{ } }
					if (-not $ResultHash[$currentTag][$currentClass]) { $ResultHash[$currentTag][$currentClass] = @{ } }
					
					$key, $value = $line -split ":", 2
					Write-PSFMessage -Level InternalComment -Message '  {0} : {1}' -StringValues $key, $value
					$ResultHash[$currentTag][$currentClass][$key.Trim()] = $value.Trim(" ;")
					#endregion Content
				}
			}
		}
		
		function Resolve-StyleHash {
			[OutputType([EbookBuilder.StyleObject])]
			[CmdletBinding()]
			param (
				[hashtable]
				$ResultHash,
				
				[bool]
				$Merge
			)
			
			foreach ($pair in $ResultHash.GetEnumerator()) {
				$tagName = $pair.Key
				
				$defaultStyle = @{ }
				if ($Merge -and $pair.Value._Default) {
					$defaultStyle = $pair.Value._Default
				}
				
				foreach ($entry in $pair.Value.GetEnumerator()) {
					$style = [EbookBuilder.StyleObject]::new()
					$style.Tag = $tagName
					if ($entry.Key -ne '_default') { $style.Class = $entry.Key }
					
					$hash = $defaultStyle.Clone()
					foreach ($attribute in $entry.Value.GetEnumerator()) { $hash[$attribute.Key] = $attribute.Value }
					foreach ($attribute in $hash.GetEnumerator()) { $style.Attributes[$attribute.Key] = $attribute.Value }
					$style
				}
			}
		}
		#endregion Functions
		
		$resultHash = @{ }
	}
	process
	{
		if ($CssData) { $CssData | Convert-StyleSheet -ResultHash $resultHash }
		foreach ($filePath in $Path) {
			Write-PSFMessage -Message 'Loading style file: {0}' -StringValues $filePath
			Get-Content -Path $filePath | Convert-StyleSheet -ResultHash $resultHash
		}
	}
	end
	{
		Resolve-StyleHash -ResultHash $resultHash -Merge $Merge
	}
}