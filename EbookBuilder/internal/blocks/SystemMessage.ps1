Register-EBMarkdownBlock -Name SystemMessage -Converter {
	param ($Data)
	
	[System.Text.StringBuilder]$sb = $Data.StringBuilder
	
	$null = $sb.AppendLine('<table class="systemmessage">')
	$null = $sb.AppendLine('<tr>')
	
	$string = ($Data.Lines -join "<br/>") -replace '\*\*(.+?)\*\*', '<b>$1</b>' -replace '_(.+?)_', '<i>$1</i>'
	$null = $sb.AppendLine(('<td><p class="systemmessage">{0}</p></td>' -f $string))
	
	$null = $sb.AppendLine('</tr>')
	$null = $sb.AppendLine('</table>')
	
	# Create new firstpar
	$true
}