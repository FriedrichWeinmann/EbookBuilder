Register-EBMarkdownBlock -Name skillupgrade -Converter {
    param ($Data)

    $PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'

    #region Functions
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
    $message = $blockCfg.SkillUpgrade.Message
    $dataHash = $Data.Lines | Read-EBMdDataSection -Data $Data.Attributes
    $resolvedMessage = Resolve-String -String $message -DataHash $dataHash

    Add-SBLine -Text "<p class=`"skillUpgrade`">$resolvedMessage</p>"
}