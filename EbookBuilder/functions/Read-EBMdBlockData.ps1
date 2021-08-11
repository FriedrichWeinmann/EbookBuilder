function Read-EBMdBlockData {
<#
	.SYNOPSIS
		Parses lines of a markdown block into a structured content set.
	
	.DESCRIPTION
		Parses lines of a markdown block into a structured content set.
		This assumes the lines of strings provided are shaped in a structured manner.
	
		Example Input:
	
		> Classes
	
		+ Hunter Level 10
		+ Warrior Level 12
	
		> Skills
	
		Bash
		Slash
		Shoot
	
		
		This would then become a hashtable with two keys: Classes & Skills.
		Each line within each section would become the values of these keys.
	
	.PARAMETER Lines
		The lines of string to parse.
	
	.PARAMETER Header
		What constitutes a section header.
		This expects each header line to start with this sequence, followed by a whitespace.
	
	.PARAMETER IncludeEmpty
		Whether empty lines are included or not.
	
	.EXAMPLE
		PS C:\> $components = $Data.Lines | Read-EBMdBlockData
	
		Read all lines of string available in $Data, returns them as a components hashtable.
#>
	[OutputType([hashtable])]
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true)]
		[AllowEmptyCollection()]
		[string[]]
		$Lines,
		
		[string]
		$Header = '>',
		
		[switch]
		$IncludeEmpty
	)
	
	begin {
		$components = @{
			'_default' = @()
		}
		$currentComponent = '_default'
	}
	process {
		foreach ($line in $Lines) {
			if (-not $IncludeEmpty -and $line.Trim() -eq "") { continue }
			if ($line -notlike "$Header *") {
				$components.$currentComponent += $line
				continue
			}
			
			$componentName = $line -replace "^$Header "
			
			$currentComponent = $componentName
			$components[$currentComponent] = @()
		}
	}
	end {
		if (-not $components['_default']) { $components.Remove('_default') }
		$components
	}
}