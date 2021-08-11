Register-EBMarkdownBlock -Name letter -Converter {
    param ($Data)
	
    $PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
    $components = Read-EBMdBlockData -Lines $Data.Lines -Header '>' -IncludeEmpty

    Add-SBLine '<div class="letter">'

    if ($components.Appellation) {
        Add-SBLine '<p class="letterAppellation">{0}</p>' -Values ($components.Appellation | Remove-PSFNUll | Join-String "<br />")
    }

    if ($components.Body) {
        $param = @{
            ClassParagraph      = 'letterBodyOther'
            ClassFirstParagraph = 'letterBodyFirst'
            EmphasisClass       = 'letterBodyEmphasis'
        }
        foreach ($entry in $components.Body | ConvertFrom-EBMarkdown @param) {
            Add-SBLine $entry
        }
    }

    if ($components.Signed) {
        Add-SBLine '<p class="letterSigned">{0}</p>' -Values ($components.Signed | Remove-PSFNUll | Join-String "<br />")
    }

    Add-SBLine '</div>'
	
    # Create new firstpar
    $true
}