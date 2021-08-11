function Read-EBMdDataSection {
<#
	.SYNOPSIS
		A simple string-data parser.
	
	.DESCRIPTION
		A simple string-data parser.
		Ignores empty lines.
		Skips lines that do not contain a ":" symbol.
		Will process each other line into key/value pairs, reading them as:
		<key>:<value>
		Each value will be trimmed and processed as string.
		Each key will be trimmed and have any leading "- " or "+ " elements removed.
	
	.PARAMETER Lines
		The lines of text to process.
	
	.PARAMETER Data
		An extra hashtable to merge with the parsing results.
	
	.EXAMPLE
		PS C:\> $Data.Lines | Read-EBMdDataSection -Data $Data.Attributes
	
		Parses all lines, merges them with the hashtable in $Data.Attributes and returns the resultant hashtable.
#>
	[OutputType([hashtable])]
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[string[]]
		$Lines,
		
		[hashtable]
		$Data = @{ }
	)
	
	begin
	{
		$result = @{ }
		$result += $Data
	}
	process
	{
		foreach ($line in $Lines | Get-SubString) {
			if (-not $line) { continue }
			if ($line -notlike "*:*") { continue }
			$name, $value = $line -split ":", 2
			$result[$name.Trim('-+ ')] = $value.Trim()
		}
	}
	end
	{
		$result
	}
}