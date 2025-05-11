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

	.PARAMETER NoHeader
		The book does not include a header in the text portion.
		Will take the chapter-name as header instead.

	.PARAMETER Replacements
		A hashtable with replacements.
		At the root level, either use the "Global" index for replacements that apply to all chapters or the number of the chapter it applies to.
		Each value of those key/value pairs contains yet another hashtable, using a label as key (they label is ignored, use this for human documentation in the file) and yet another hashtable as value.
		That hashtable may contain three keys:
		- Pattern (mandatory)
		- Text (mandatory)
		- Weight (optional)
		The Pattern is a piece of text used to find matching text within the current chapter. Uses Regex.
		The Text is what we replace matched content with.
		The Weight - if specified - is the processing order in case of multiple replacements - the lower the number, the earlier is it processed.
	
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
		$Index,

		[switch]
		$NoHeader,

		[hashtable]
		$Replacements
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
				if ($Line -notlike '*<a class="btn btn-primary*>Next <br class="visible-xs"/>Chapter</a>*') { return }
				$Line -replace '^.+href="(.+?)".+$', 'https://www.royalroad.com$1'
			}
		}

		function Get-Title {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[parameter(ValueFromPipeline = $true)]
				[string]
				$Line
			)
			process {
				if ($Line -notmatch '<h1 .+?>(.+?)</h1>') { return }
				$matches[1]
			}
		}
		
		function ConvertTo-Markdown {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[string]
				$Line,

				[switch]
				$NoHeader,

				[string]
				$Title
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

				if ($NoHeader) {
					'# {0}' -f $Title
					''
				}
			}
			process {
				$lineNormalized = ($Line -replace $badQuotesPattern, '"' -replace $badSingleQuotesPattern, "'").Trim()
				if (-not $firstLineCompleted -and -not $NoHeader) {
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

		function ConvertTo-MarkdownFinal {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[string]
				$Text,

				[Hashtable]
				$Replacements,

				[int]
				$ChapterIndex
			)
			begin {
				$mapping = @($Replacements.Global.Values) + @($Replacements[$ChapterIndex].Values) | Sort-Object Weight
			}
			process {
				foreach ($item in $mapping) {
					$Text = $Text -replace $item.Pattern, $item.Text
				}
				$Text
			}
		}
		#endregion functions
	}
	process {
		$found = $false
		try { $allLines = (Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop).Content -split "`n" }
		catch {
			if ($_.ErrorDetails.Message -ne 'Slow down!') { throw }
			Start-Sleep -Seconds 1
			$allLines = (Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop).Content -split "`n"
		}
		$lines = $allLines | Where-Object {
			if ($_ -like '*<div class="chapter-inner chapter-content">*') {
				$found = $true
			}
			if ($_ -like '*<h6 class="*">Advertisement</h6>*') {
				$found = $false
			}
			if ($_ -like '*<div class="bold uppercase">Advertisement</div>*') {
				$found = $false
			}
			
			# Remove all pictures, they don't close the tags correctly
			if (
				$_ -like '*<img*' -or
				$_ -like '*<input*'
			) { return }
			$found
		}
		$title = $allLines | Get-Title
		[pscustomobject]@{
			Index    = $Index
			Title    = $title
			RawText  = $allLines -join "`n"
			Text     = $lines -join "`n" -replace '<br>', '<br />' -replace '<div class="chapter-inner chapter-content">', '<div>'
			TextMD   = $lines[1 .. ($lines.Length - 2)] | ConvertTo-Markdown -NoHeader:$NoHeader -Title $Title | Join-String "`n" | ConvertTo-MarkdownFinal -Replacements $Replacements -ChapterIndex $Index
			NextLink = $allLines | Get-NextLink
		}
	}
}