Register-EBMarkdownBlock -Name table -Converter {
	param ($Data)
	
	[System.Text.StringBuilder]$sb = $Data.StringBuilder
	$null = $sb.AppendLine('<table class="systemdata">')
	
	#region Create header
	if ($Data.Attributes.title)
	{
		$null = $sb.AppendLine('<tr>')
		$null = $sb.AppendLine("<th>$($Data.Attributes.title | Convert-MarkdownLine)</th>")
		$null = $sb.AppendLine('</tr>')
	}
	#endregion Create header
	
	#region Creat Body
	foreach ($line in $Data.Lines)
	{
		$null = $sb.AppendLine('<tr>')
		switch ($Data.Attributes.Type)
		{
			#region Default markdown table
			'markdown'
			{
				$entries = $line.Trim('|') -split '\|'
				foreach ($entry in $entries) { $null = $sb.AppendLine("<td>$($entry.Trim() | Convert-MarkdownLine)</td>") }
			}
			#endregion Default markdown table
			
			#region Default Table Style
			default
			{
				$entries = $line -split ":", 2
				$null = $sb.AppendLine("<td>$($entries[0].Trim() | Convert-MarkdownLine)</td>")
				$null = $sb.AppendLine("<td>$($entries[1].Trim() | Convert-MarkdownLine)</td>")
			}
			#endregion Default Table Style
		}
		$null = $sb.AppendLine('</tr>')
	}
	#endregion Creat Body
	
	$null = $sb.AppendLine('</table>')
	
	# Create new firstpar
	$true
}