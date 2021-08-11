Register-EBMarkdownBlock -Name picture -Converter {
    param ($Data)
	
    $PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
	
    $alignment = 'center'
    if ($Data.Attributes.align) { $alignment = $Data.Attributes.align }

    foreach ($line in $Data.Lines | ForEach-Object Trim) {
        if (-not $line) { continue }

        Add-SBLine '<div class="picture"><img class="picture{0}" alt="{1}" src="../Images/{2}" /></div>' -Values $alignment, ($line -replace '\.(.+?)$'), $line
    }
	
    # Create new firstpar
    $true
}