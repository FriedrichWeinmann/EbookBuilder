Register-EBMarkdownBlock -Name divide -Converter {
	param ($Data)
	
	$PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
	$blockCfg = Get-PSFTaskEngineCache -Module EBookBuilder -Name blockCfg
	
	Add-SBLine '<div class="divide">'
	if ($blockCfg.Divide.Image) {
		Add-SBLine '<div class="picture"><img class="pictureCenter" alt="Divider Symbol" src="../Images/{0}]" /></div>' -Values $blockCfg.Divide.Image
	}
	else {
		Add-SBLine '<p class="divide">* * *</p>'
	}
	Add-SBLine '</div>'
	
	# Create new firstpar
	$true
}