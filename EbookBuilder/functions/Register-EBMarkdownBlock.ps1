function Register-EBMarkdownBlock
{
<#
	.SYNOPSIS
		Register a converter scriptblock for parsing block data with Read-EBMarkdown
	
	.DESCRIPTION
		Register a converter scriptblock for parsing block data with Read-EBMarkdown
	
		These allow you to custom-tailor and extend how special blocks are converted from markdown to html.
	
		The converter script receives one input object, which will contain three properties:
		- Type : What kind of block is being provided
		- Lines : The lines of text within the block
		- Attributes : Any attributes provided to the block
		- StringBuilder : The StringBuilder that you should append any lines of html to
	
		Your scriptblock should return a boolean value - whether the next paragraph should have the default indentation or be treated as a first line.
	
	.PARAMETER Name
		Name of the block.
		Equal to the html tag name used within markdown.
	
	.PARAMETER Converter
		Script logic performing the conversion.
	
	.EXAMPLE
		PS C:\> Register-EBMarkdownBlock -Name Warning -Converter $warningScript
	
		Registers a converter that will convert warning blocks to useful html.
#>
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[parameter(Mandatory = $true)]
		[System.Management.Automation.ScriptBlock]
		$Converter
	)
	
	process
	{
		$script:mdBlockTypes[$Name] = $Converter
	}
}