function ConvertTo-EBHtmlInlineStyle {
<#
	.SYNOPSIS
		Converts html documents from using classes to inline style attributes.
	
	.DESCRIPTION
		Converts html documents from using classes to inline style attributes.
		Needed in situations where the target system doesn't support use of stylesheets.
	
	.PARAMETER Text
		The text to convert.
	
	.PARAMETER CssData
		CSS text to use for resolving classes to style attributes.
	
	.PARAMETER Style
		CSS style objects as resolved by Read-EBCssStyleSheet
		Note: The command should be used with the "-Merge" option to include the defautl settings for its html tag.
	
	.EXAMPLE
		PS C:\> ConvertTo-EBHtmlInlineStyle -Text $htmlContent -Style $styleObjects
	
		Convert the text in $htmlContent using the styles in $styleObjects.
		This will replace all style attributes with fitting style attributes.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[string[]]
		$Text,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Text')]
		[string]
		$CssData,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Object')]
		[EbookBuilder.StyleObject[]]
		$Style
	)
	
	begin {
		$styleObjects = $Style
		if ($CssData) { $styleObjects = Read-EBCssStyleSheet -CssData $CssData }
		
		$stylesRoot = $styleObjects | Where-Object Class -EQ ''
		$stylesClass = $styleObjects | Where-Object Class
	}
	process {
		foreach ($textItem in $Text) {
			foreach ($styleItem in $stylesClass) {
				$textItem = $textItem -replace "<$($styleItem.Tag) ([^>]{0,})class=`"$($styleItem.Class)`"([^>]{0,})>", "<$($styleItem.Tag) `$1$($styleItem.ToInline($true))`$2>"
			}
			foreach ($styleItem in $stylesRoot) {
				$textItem = $textItem -replace "<$($styleItem.Tag)>", "<$($styleItem.Tag) $($styleItem.ToInline($true))>"
			}
			$textItem
		}
	}
}