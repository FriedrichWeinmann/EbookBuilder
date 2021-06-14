﻿# Add all things you want to run after importing the main code

# Load Configurations
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\configurations\*.ps1" -ErrorAction Ignore)) {
	. Import-ModuleFile -Path $file.FullName
}

# Load Tab Expansion
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\tepp\*.tepp.ps1" -ErrorAction Ignore)) {
	. Import-ModuleFile -Path $file.FullName
}

# Load Tab Expansion Assignment
. Import-ModuleFile -Path "$ModuleRoot\internal\tepp\assignment.ps1"

# Load License
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\license.ps1"

# Initialize Stuff
. Import-ModuleFile -Path "$ModuleRoot\internal\scripts\initialize.ps1"

# Load block conversions
foreach ($file in (Get-ChildItem "$ModuleRoot\internal\blocks\*.ps1" -ErrorAction Ignore))
{
	. Import-ModuleFile -Path $file.FullName
}