Register-EBMarkdownBlock -Name skill -Converter {
    param ($Data)
    $PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'

    #region Style-Class Mapping
    $styleMapping = @{
        Default       = @{ First = 'skillFirstJustify'; Other = 'skillFirstJustify'; Italic = $true }
        Justify       = @{ First = 'skillFirstJustify'; Other = 'skillOtherJustify'; Italic = $true }
        Left          = @{ First = 'skillFirstLeft'; Other = 'skillOtherLeft'; Italic = $true }
        Center        = @{ First = 'skillFirstCenter'; Other = 'skillOtherCenter'; Italic = $true }
        Right         = @{ First = 'skillFirstRight'; Other = 'skillOtherRight'; Italic = $true }
        LeftNormal    = @{ First = 'skillFirstLeftNormal'; Other = 'skillOtherLeftNormal' }
        CenterNormal  = @{ First = 'skillFirstCenterNormal'; Other = 'skillOtherCenterNormal' }
        RightNormal   = @{ First = 'skillFirstRightNormal'; Other = 'skillOtherRightNormal' }
        JustifyNormal = @{ First = 'skillFirstJustifyNormal'; Other = 'skillOtherJustifyNormal' }
    }
    #endregion Style-Class Mapping

    #region Functions
    function Write-Section {
        [CmdletBinding()]
        param (
            [string]
            $Name,

            [bool]
            $Header,

            [Hashtable]
            $Styles,

            [string[]]
            $Lines,

            [bool]
            $IncludeEmptyLine
        )

        $emphasis = 'skillEmphasis'
        if ($Styles.Italic) { $emphasis = 'skillEmphasisReverse' }

        Add-SBLine '<div class="skillSection">'
        if ($Header) { Add-SBLine "<p class=`"skillSectionHeader`">$Name</p>" }
        $first = $true
        foreach ($line in $Lines) {
            if ($line.Trim() -eq '') {
                if (-not $IncludeEmptyLine) { continue }
                $line = '&nbsp;'
            }
            $effectiveLine = $line -replace '\*\*(.+?)\*\*','<b>$1</b>' -replace '_(.+?)_',"<span class=`"$emphasis`">`$1</span>"
            $style = $Styles.Other
            if ($first) { $style = $Styles.First }
            Add-SBLine "<p class=`"$style`">$effectiveLine</p>"
            $first = $false
        }

        Add-SBLine '</div>'
    }

    function Resolve-String {
        [OutputType([string])]
        [CmdletBinding()]
        param (
            [string]
            $String,

            [hashtable]
            $DataHash
        )

        $tempString = $String
        foreach ($key in $DataHash.Keys) {
            $tempString = $tempString -replace "%$key%", $DataHash[$key]
        }
        $tempString
    }
    #endregion Functions

    $blockCfg = Get-PSFTaskEngineCache -Module EBookBuilder -Name blockCfg
    $header = '>'
    if ($blockCfg.Skill.SectionIdentifier) { $header = $blockCfg.Skill.SectionIdentifier }
    $components = Read-EBMdBlockData -Lines $Data.Lines -Header $header

    $dataHash = $components.$($blockCfg.Skill.Data) | Read-EBMdDataSection -Data $Data.Attributes
    

    Add-SBLine '<div class="skill">'

    if ($blockCfg.Skill.Header) {
        $headerString = Resolve-String -String $blockCfg.Skill.Header -DataHash $dataHash
        Add-SBLine "<p class=`"skillHeader`">$headerString</p>"
    }

    foreach ($section in $blockCfg.Skill.Sections) {
        if (-not $components.$section) { continue }

        $header = $false
        $includeEmptyLine = $false
        if ($blockCfg.Skill.SectionStyle[$section]) {
            $header = $blockCfg.Skill.SectionStyle[$section].Header -as [bool]
            $includeEmptyLine = $blockCfg.Skill.SectionStyle[$section].IncludeEmptyLine -as [bool]
            $mode = $blockCfg.Skill.SectionStyle[$section].Style
        }
        if (-not $mode) { $mode = "default" }
        $styles = $styleMapping[$mode]
        if (-not $styles) { $styles = $styleMapping['default'] }

        Write-Section -Name $section -Header $header -Styles $styles -Lines $components.$section -IncludeEmptyLine $includeEmptyLine
    }

    if ($blockCfg.Skill.Footer) {
        $footerString = Resolve-String -String $blockCfg.Skill.Footer -DataHash $dataHash
        Add-SBLine "<p class=`"skillFooter`">$footerString</p>"
    }

    Add-SBLine '</div>'

    # Set FirstPar
    $true
}