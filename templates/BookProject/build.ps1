if (Test-Path -Path "$PSScriptRoot\blockConfig.psd1") {
    $blockCfg = Import-PSFPowerShellDataFile -Path "$PSScriptRoot\blockConfig.psd1"
    Set-PSFTaskEngineCache -Module EBookBuilder -Name blockCfg -Value $blockCfg
}

$data = Import-PSFPowerShellDataFile -Path "$PSScriptRoot\config.psd1"
if ($data.Url) {
    Read-EBRoyalRoad -ConfigFile "$PSScriptRoot\config.psd1"
}
Export-EBMdBook -ConfigFile "$PSScriptRoot\config.psd1"