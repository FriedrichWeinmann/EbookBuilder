Register-EBMarkdownBlock -Name SystemMessage -Converter {
	param ($Data)
	
	$PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
	$supportedStyles = 'Italic', 'Boxed'

	$blockCfg = Get-PSFTaskEngineCache -Module EBookBuilder -Name blockCfg
	$style = $blockCfg.SystemMessage.DefaultStyle
	if ($Data.Attributes.Style) { $style = $Data.Attributes.Style }
	if ($style -notin $supportedStyles) {
		if ($blockCfg.SystemMessage.DefaultStyle -in $supportedStyles) { $style = $Data.Attributes.Style }
		else { $style = 'Italic' }
	}

	switch ($style) {
		#region Italic
		'Italic' {
			Add-SBLine '<div class="systemmessageItalic">'

			$param = @{
				ClassParagraph = 'systemmessageItalicOther'
				ClassFirstParagraph = 'systemmessageItalicFirst'
				EmphasisClass = 'systemmessageItalicEmphasis'
			}

			foreach ($entry in $Data.Lines | ConvertFrom-EBMarkdown @param) {
				Add-SBLine $entry
			}

			Add-SBLine '</div>'
		}
		#endregion Italic

		#region Boxed
		'Boxed' {
			Add-SBLine '<table class="systemmessageBlock"><tr><td>'

			$param = @{
				ClassParagraph = 'systemmessageBlockOther'
				ClassFirstParagraph = 'systemmessageBlockFirst'
				EmphasisClass = 'systemmessageBlockEmphasis'
			}

			foreach ($entry in $Data.Lines | ConvertFrom-EBMarkdown @param) {
				Add-SBLine $entry
			}

			Add-SBLine '</td></tr></table>'
		}
		#endregion Boxed
	}
	
	# Create new firstpar
	$true
}