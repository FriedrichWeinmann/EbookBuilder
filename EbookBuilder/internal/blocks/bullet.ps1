Register-EBMarkdownBlock -Name bullet -Converter {
	param ($Data)
	
	[System.Text.StringBuilder]$sb = $Data.StringBuilder
	
	switch ($Data.Attributes.type) {
		'simple'
		{
			$null = $sb.AppendLine('<ul>')
			foreach ($line in $Data.Lines) {
				$null = $sb.AppendLine("<li>$($line.Trim(" +") | Convert-MarkdownLine)</li>")
			}
			$null = $sb.AppendLine('</ul>')
		}
		default
		{
			$null = $sb.AppendLine('<table class="systemdata">')
			#region Create header
			if ($Data.Attributes.title) {
				$null = $sb.AppendLine('<tr>')
				$null = $sb.AppendLine("<th>$($Data.Attributes.title | Convert-MarkdownLine)</th>")
				$null = $sb.AppendLine('</tr>')
			}
			#endregion Create header
			
			$null = $sb.AppendLine('<tr>')
			$null = $sb.AppendLine('<td>')
			$null = $sb.AppendLine('<ul>')
			foreach ($line in $Data.Lines) {
				$null = $sb.AppendLine("<li>$($line.Trim(" +") | Convert-MarkdownLine)</li>")
			}
			$null = $sb.AppendLine('</ul>')
			
			$null = $sb.AppendLine('</td>')
			$null = $sb.AppendLine('</tr>')
			$null = $sb.AppendLine('</table>')
		}
	}
	
	# Create new firstpar
	$true
}