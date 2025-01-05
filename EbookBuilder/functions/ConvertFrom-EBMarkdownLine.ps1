function ConvertFrom-EBMarkdownLine
{
<#
	.SYNOPSIS
		Converts markdown notation of bold and cursive to html.
	
	.DESCRIPTION
		Converts markdown notation of bold and cursive to html.
	
	.PARAMETER Line
		The line of text to convert.
	
	.PARAMETER EmphasisClass
		The tag to wrap text in that was marked in markdown with "_" symbols
		By default it encloses with italic tags ("<i>Test</i>"), specifying a class will change it to a span instead.
	
	.EXAMPLE
		PS C:\> ConvertFrom-EBMarkdownLine -Line '_value1_'
		
		Will convert "_value1_" to "<i>value1</i>"
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		[string[]]
		$Line,
		
		[string]
		$EmphasisClass
	)
	
	begin {
		$emphasis = '<i>$1</i>'
		if ($EmphasisClass) {
			$emphasis = '<span class="{0}">$1</span>' -f $EmphasisClass
		}
	}
	process
	{
		foreach ($string in $Line) {
			$string -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', $emphasis -replace '\\\*', '*'
		}
	}
}