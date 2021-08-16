@{
	# Script module or binary module file associated with this manifest
	ModuleToProcess = 'EbookBuilder.psm1'
	
	# Version number of this module.
	ModuleVersion = '2.3.15'
	
	# ID used to uniquely identify this module
	GUID = '6dd367f3-da8b-48ae-8198-ce2b709cb1a4'
	
	# Author of this module
	Author = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName = ' '
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) Friedrich Weinmann'
	
	# Description of the functionality provided by this module
	Description = 'Build ebooks from data sources'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.6.205' }
		@{ ModuleName = 'string'; ModuleVersion = '1.0.0' }
		@{ ModuleName = 'StringBuilder'; ModuleVersion = '1.0.0' }
		@{ ModuleName = 'PSModuleDevelopment'; ModuleVersion = '2.2.10.120' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\EbookBuilder.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\EbookBuilder.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\EbookBuilder.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport  = @(
		'ConvertFrom-EBMarkdown'
		'ConvertFrom-EBMarkdownLine'
		'ConvertTo-EBHtmlInlineStyle'
		'Export-EBBook'
		'Export-EBMdBook'
		'New-EBBookProject'
		'Read-EBCssStyleSheet'
		'Read-EBMarkdown'
		'Read-EBMdBlockData'
		'Read-EBMdDataSection'
		'Read-EBMicrosoftDocsIndexPage'
		'Read-EBMicrosoftDocsPage'
		'Read-EBRoyalRoad'
		'Register-EBMarkdownBlock'
	)
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('book')
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/FriedrichWeinmann/EbookBuilder/blob/development/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/FriedrichWeinmann/EbookBuilder'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			# ReleaseNotes = ''
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}