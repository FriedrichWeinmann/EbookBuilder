<#
Body:
Regular Bullet-Points as in Markdown

Attributes:

# Type
Options: Frame, fullFrame
Adding this option in either mode will wrap a colored frame around the bullet-points.
"Frame" will be as small as needed, "fullFrame" is set to 100% width.

# Title
Adds a title above the bullet-points.
#>

Register-EBMarkdownBlock -Name bullet -Converter {
	param ($Data)
	
	$PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
	
	switch -regex ($Data.Attributes.type) {
		frame {
			if ($Data.Attributes.type -eq 'fullFrame') { Add-SBLine '<table class="bulletFrameMaxWidth">' }
			else { Add-SBLine '<table class="bulletFrameNormal">' }

			#region Create header
			if ($Data.Attributes.title) {
				Add-SBLine '<tr>'
				Add-SBLine "<th>$($Data.Attributes.title | ConvertFrom-EBMarkdownLine)</th>"
				Add-SBLine '</tr>'
			}
			#endregion Create header
			
			Add-SBLine '<tr><td><ul>'
			foreach ($line in $Data.Lines) {
				Add-SBLine "<li>$($line.Trim(" +-") | ConvertFrom-EBMarkdownLine)</li>"
			}
			Add-SBLine '</ul></td></tr>'

			Add-SBLine '</table>'
		}
		default {
			#region Create header
			if ($Data.Attributes.title) {
				Add-SBLine "<p class`"bulletHeader`">$($Data.Attributes.title | ConvertFrom-EBMarkdownLine)</p>"
			}
			#endregion Create header

			Add-SBLine '<ul>'
			foreach ($line in $Data.Lines) {
				Add-SBLine "<li>$($line.Trim(" +-") | ConvertFrom-EBMarkdownLine)</li>"
			}
			Add-SBLine '</ul>'
		}
	}
	
	# Create new firstpar
	$true
}