Register-EBMarkdownBlock -Name divide -Converter {
	param ($Data)
	
	[System.Text.StringBuilder]$sb = $Data.StringBuilder
	
	$null = $sb.AppendLine('<p class="divide">* * *</p>')
	
	# Create new firstpar
	$true
}