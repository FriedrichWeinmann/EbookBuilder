# Clean Up previous template versions
Remove-Item -Path "$PSScriptRoot\..\EbookBuilder\internal\templateStore\*"

foreach ($folder in Get-ChildItem -Path "$PSScriptRoot" -Directory) {
    New-PSMDTemplate -ReferencePath $folder.FullName -OutPath "$PSScriptRoot\..\EbookBuilder\internal\templateStore"
}