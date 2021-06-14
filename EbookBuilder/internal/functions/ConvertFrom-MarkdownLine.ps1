function ConvertFrom-MarkdownLine
{
<#
	.SYNOPSIS
		Converts markdown notation of bold and cursive to html.
	
	.DESCRIPTION
		Converts markdown notation of bold and cursive to html.
	
	.PARAMETER Line
		The line of text to convert.
	
	.EXAMPLE
		PS C:\> Convert-MarkdownLine -Line '_value1_'
	
		Will convert "_value1_" to "<i>value1</i>"
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		[string[]]
		$Line
	)
	
	process
	{
		foreach ($string in $Line) {
			$string -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', '<i>$1</i>'
		}
	}
}