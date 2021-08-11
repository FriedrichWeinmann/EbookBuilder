Register-EBMarkdownBlock -Name charactersheet -Converter {
    param ($Data)

    $PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
    $blockCfg = Get-PSFTaskEngineCache -Module EBookBuilder -Name blockCfg
    $header = '>'
    if ($blockCfg.CharacterSheet.SectionIdentifier) { $header = $blockCfg.CharacterSheet.SectionIdentifier }

    #region Functions
    function Write-Line {
        [CmdletBinding()]
        param (
            [string]
            $Line,

            [switch]
            $Section
        )

        $class = 'characterContent'
        if ($Section) { $class = 'characterSection' }

        Add-SBLine "<p class=`"$class`">$Line</p>"
    }

    function Write-Section {
        [CmdletBinding()]
        param (
            [string]
            $Name,

            [hashtable]
            $Components
        )

        if (-not $components.$Name) { return }

        Write-Line "$Name" -Section
        foreach ($line in $components.$Name | Set-String -OldValue '^- |^\+ ') {
            Write-Line $line
        }
    }
    #endregion Functions

    $components = Read-EBMdBlockData -Lines $Data.Lines -Header $header

    Add-SBLine '<div class="character">'

    #region Process Group Sections
    if ($components.$($blockCfg.CharacterSheet.Header)) {
        Write-Line -Line ($components.$($blockCfg.CharacterSheet.Header) | Set-String -OldValue '^- |^\+ ' | Join-String '<br />') -Section
    }

    foreach ($section in $blockCfg.CharacterSheet.Sections) {
        Write-Section -Name $section -Components $components
    }
    #endregion Process Group Sections

    Add-SBLine '</div>'

    # Set FirstPar
    $true
}