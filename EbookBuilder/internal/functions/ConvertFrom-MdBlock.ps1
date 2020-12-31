function ConvertFrom-MdBlock
{
<#
	.SYNOPSIS
		Converts special blocks defined in markdown into html.
	
	.DESCRIPTION
		Converts special blocks defined in markdown into html.
		The resultant html is appended to the stringbuilder specified.
		The conversion logic is provided by Register-EBMarkdownBlock.
		Returns whether the next line should be a first paragraph or a regular paragraph.
	
	.PARAMETER Type
		What kind of block is this?
	
	.PARAMETER Lines
		The lines of text contained in the block.
	
	.PARAMETER Attributes
		Any attributes provided to the block.
	
	.PARAMETER StringBuilder
		The stringbuilder containing the overall html string being built.
	
	.EXAMPLE
		PS C:\> ConvertFrom-MdBlock -Type $type -Lines $lines -Attributes @{ } -StringBuilder $builder
	
		Converts the provided block data to html and appends it to the stringbuilder.
		Returns whether the next line should be a first paragraph or a regular paragraph.
#>
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true)]
		[string]
		$Type,
		
		[parameter(Mandatory = $true)]
		[string[]]
		$Lines,
		
		[parameter(Mandatory = $true)]
		[System.Collections.Hashtable]
		$Attributes,
		
		[parameter(Mandatory = $true)]
		[System.Text.StringBuilder]
		$StringBuilder
	)
	
	process
	{
		$converter = $script:mdBlockTypes[$Type]
		if (-not $converter)
		{
			Stop-PSFFunction -Message "Converter for block $Type not found! Make sure it is properly registered using Register-EBMarkdownBlock" -EnableException $true -Cmdlet $PSCmdlet -Category InvalidArgument
		}
		
		$data = [pscustomobject]($PSBoundParameters | ConvertTo-PSFHashtable)
		$converter.Invoke($data) -as [bool]
	}
}