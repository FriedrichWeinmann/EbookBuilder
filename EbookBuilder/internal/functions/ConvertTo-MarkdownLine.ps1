function ConvertTo-MarkdownLine {
<#
	.SYNOPSIS
		Converts an input html paragraph to a markdown line of text.
	
	.DESCRIPTION
		Converts an input html paragraph to a markdown line of text.
	
	.PARAMETER Line
		The line of text to convert.
	
	.EXAMPLE
		PS C:\> ConvertTo-MarkdownLine -Line $Line
	
		Converts the HTML $Line to markdown
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		[AllowEmptyString()]
		[string[]]
		$Line
	)
	
	begin {
		$mapping = @{
			'</{0,1}em>'	 = '_'
			'</{0,1}i>'	     = '_'
			'</{0,1}strong>' = '**'
			'</{0,1}b>'	     = '**'
			'<br>'		     = '<br />'
			'<span style="font-weight: 400">(.+?)</span>' = '$1'
		}
	}
	process {
		foreach ($string in $Line -replace ' </i>', '</i> ' -replace ' </em>', '</em> ') {
			foreach ($pair in $mapping.GetEnumerator()) {
				$string = $string -replace $pair.Key, $pair.Value
			}
			($string -replace '</{0,1}p.{0,}?>').Trim()
		}
	}
}