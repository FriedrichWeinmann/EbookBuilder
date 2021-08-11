function New-EBBookProject
{
<#
	.SYNOPSIS
		Create a new ebook project.
	
	.DESCRIPTION
		Create a new ebook project.
		This project will be designed for authoring in markdown.
		Recommended editor is VSCode, automation requires PowerShell and this module even after creation.
		All three can be installed on any common client Operating System, such as Windows, Linux or MacOS.
	
		It is recommended, but not required, to use a source control service such as GitHub to host your project (for free and not necessarily public).
	
	.PARAMETER Path
		The path where the project should be created.
		Defaults to the current path.
	
	.PARAMETER Name
		The name of the series / book.
		(This project template is designed with a series in mind, but can be used for a single book just as well)
	
	.PARAMETER Author
		The Author of the book.
	
	.PARAMETER Publisher
		The Publisher for this book.
	
	.EXAMPLE
		PS C:\> New-EBBookProject -Name 'Genesis'
	
		Creates a new book project named "Genesis" in the current path.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$Path = '.',
		
		[string]
		$Author,
		
		[string]
		$Publisher
	)
	
	process
	{
		$parameters = @{
			TemplateName = 'BookProject'
			NoFolder	 = $true
			OutPath	     = $Path
			Parameters = $PSBoundParameters | ConvertTo-PSFHashtable -Include Name, Author, Publisher
		}
		Invoke-PSMDTemplate @parameters
		Write-PSFMessage -Level Host -Message "Book Project $Name created under $(Resolve-PSFPath $Path)"
	}
}