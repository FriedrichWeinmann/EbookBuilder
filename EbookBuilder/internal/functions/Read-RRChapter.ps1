function Read-RRChapter {
<#
	.SYNOPSIS
		Reads a Royal Road chapter and breaks it down into its components.
	
	.DESCRIPTION
		Reads a Royal Road chapter and breaks it down into its components.
		Part of the parsing process to convert Royal Road books into eBooks.
	
	.PARAMETER Url
		Url to the specific RR page to process.
	
	.PARAMETER Index
		The chapter index to include in the return object
	
	.EXAMPLE
		PS C:\> Read-RRChapter -Url https://www.royalroad.com/fiction/12345/evil-incarnate/chapter/666666/1-end-of-all-days
	
		Reads and converts the first chapter of evil incarnate (hint: does not exist)
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Url,
		
		[int]
		$Index
	)
	
	begin {
		#region functions
		function Get-NextLink {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[parameter(ValueFromPipeline = $true)]
				[string]
				$Line
			)
			process {
				if ($Line -notlike '*<a class="btn btn-primary*>Next <br class="visible-xs" />Chapter</a>*') { return }
				$Line -replace '^.+href="(.+?)".+$', 'https://www.royalroad.com$1'
			}
		}
		
		function ConvertTo-Markdown {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[string]
				$Line
			)
			
			begin {
				$firstLineCompleted = $false
				
				$badQuotes = @(
					[char]8220
					[char]8221
					[char]8222
					[char]8223
				)
				$badQuotesPattern = $badQuotes -join "|"
				$badSingleQuotes = @(
					[char]8216
					[char]8217
					[char]8218
					[char]8219
				)
				$badSingleQuotesPattern = $badSingleQuotes -join "|"
			}
			process {
				$lineNormalized = ($Line -replace $badQuotesPattern, '"' -replace $badSingleQuotesPattern, "'").Trim()
				if (-not $firstLineCompleted) {
					'# {0}' -f ($lineNormalized -replace '</{0,1}p.{0,}?>' -replace '</{0,1}b>' -replace '</{0,1}strong>' -replace '<br>', '<br />')
					''
					$firstLineCompleted = $true
					return
				}
				
				if ($lineNormalized -eq '<p style="text-align: center">* * *</p>') {
					@'
## <divide>
  * * *
## </divide>

'@
					return
				}
				
				$lineNormalized | ConvertTo-MarkdownLine
				''
			}
		}
		#endregion functions
	}
	process {
		$found = $false
		$allLines = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content -split "`n"
		$lines = $allLines | Where-Object {
			if ($_ -like '*<div class="chapter-inner chapter-content">*') {
				$found = $true
			}
			if ($_ -like '*<h6 class="bold uppercase text-center">Advertisement</h6>*') {
				$found = $false
			}
			
			# Remove all pictures, they don't close the tags correctly
			if (
				$_ -like '*<img*' -or
				$_ -like '*<input*'
			) { return }
			$found
		}
		[pscustomobject]@{
			Index   = $Index
			RawText = $allLines -join "`n"
			Text    = $lines -join "`n" -replace '<br>', '<br />' -replace '<div class="chapter-inner chapter-content">', '<div>'
			TextMD  = $lines[1 .. ($lines.Length - 2)] | ConvertTo-Markdown | Join-String "`n"
			NextLink = $allLines | Get-NextLink
		}
	}
}