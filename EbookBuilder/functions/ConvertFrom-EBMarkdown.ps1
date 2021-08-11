function ConvertFrom-EBMarkdown {
<#
	.SYNOPSIS
		A limited convertion from markdown to html.
	
	.DESCRIPTION
		A limited convertion from markdown to html.
		This command will process multiple lines into useful html.
		It is however limited in scope:
	
		+ Paragraphs
		+ Italic/emphasized text
		+ Bold text
		+ Bullet Points
	
		Other elements, such as comments (">") or headers ("#") are being ignored.
	
		This is due to this command being scoped not to converting whole pages, but instead for fairly small passages of markdown.
		Especially as a tool used within Blocks.
	
	.PARAMETER Line
		The lines of markdown string to convert.
	
	.PARAMETER EmphasisClass
		Which class to use for emphasized pieces of text.
		This is particularly intended for emphasis in text that is in italics by default.
	
		By default, emphasized text is wrapped into "<i>" and "</i>".
		However, when offerign a class instead a span tag is used:
		'<span class="EmphasisClass">' and '</span>'.
	
	.PARAMETER ClassFirstParagraph
		Which class to use for the first paragraph found.
		This affects the very first paragraph as well as any first paragraph after bulletpoints.
		Defaults to the same class as used for the ClassParagraph parameter.
	
	.PARAMETER ClassParagraph
		Which class to use for all paragraph but the first one.
		Defaults to: No class at all.
	
	.PARAMETER Classes
		A hashtable for mapping html tags to class names.
		Ignored for paragraphs, italic and bold, but can be used for example to add a class to "<li>" items.
	
	.PARAMETER AlwaysBreak
		By default, common markdown practice is to build a paragraph from multiple lines of text.
		Only on an empty line would a new paragraph be created.
		This can be disabled with this switch, causing every end of line to be treated as the end of a paragraph.
	
	.EXAMPLE
		PS C:\> ConvertFrom-EBMarkdown -Line $Data.Lines
	
		Converts all the lines of text in $Data.Lines without assigning special classes to any text.
	
	.EXAMPLE
		PS C:\> ConvertFrom-EBMarkdown -Line $Data.Lines -ClassParagraph blockOther -ClassFirstParagraph blockFirst -EmphasisClass blockEmphasis
	
		Converts all the lines of text in $Data.Lines, assigning the specified classes as applicable.
#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true)]
		[AllowEmptyString()]
		[string[]]
		$Line,
		
		[string]
		$EmphasisClass,
		
		[string]
		$ClassFirstParagraph,
		
		[string]
		$ClassParagraph,
		
		[hashtable]
		$Classes = @{ },
		
		[switch]
		$AlwaysBreak
	)
	
	begin {
		#region Utility Functions
		function Get-ClassString {
			[CmdletBinding()]
			param (
				[string]
				$Name,
				
				[hashtable]
				$Classes
			)
			
			if (-not $Classes.$Name) { return '' }
			
			' class="{0}"' -f $Classes.$Name
		}
		
		function Write-Paragraph {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[string[]]
				$Text,
				
				[string]
				$FirstParagraph = $ClassFirstParagraph,
				
				[string]
				$Paragraph = $ClassParagraph,
				
				[bool]
				$First = $isFirstParagraph
			)
			
			Set-Variable -Name isFirstParagraph -Scope 1 -Value $false
			Set-Variable -Name currentParagraph -Scope 1 -Value @()
			
			$class = $Paragraph
			if ($First -and $FirstParagraph) { $class = $FirstParagraph }
			$classString = Get-ClassString -Name p -Classes @{ p = $class }
			
			"<p$($classString)>$($Text -join " ")</p>"
		}
		#endregion Utility Functions
		
		$currentParagraph = @()
		$inBullet = $false
		$isFirstParagraph = $true
		
		$convertParam = $PSBoundParameters | ConvertTo-PSFHashtable -Include EmphasisClass
	}
	process {
		foreach ($string in $Line) {
			#region Empty Line
			if (-not $string) {
				if ($currentParagraph) { Write-Paragraph -Text $currentParagraph }
				if ($AlwaysBreak -and -not $inBullet) { Write-Paragraph -Text '&nbsp;' }
				if ($inBullet) {
					'</ul>'
					$inBullet = $false
				}
				continue
			}
			#endregion Empty Line
			
			#region Bullet Lists
			if ($string -match '^- |^\+ ') {
				$isFirstParagraph = $true
				if (-not $inBullet) {
					if ($currentParagraph) { Write-Paragraph -Text $currentParagraph }
					"<ul$(Get-ClassString -Name ul -Classes $Classes)>"
					$inBullet = $true
				}
				"<li$(Get-ClassString -Name li -Classes $Classes)>$($string | Set-String -OldValue '^- |^\+ ' | ConvertFrom-EBMarkdownLine @convertParam)</li>"
				continue
			}
			#endregion Bullet Lists
			
			#region Default: paragraph
			$currentParagraph += $string | ConvertFrom-EBMarkdownLine @convertParam
			
			if ($AlwaysBreak) { Write-Paragraph -Text $currentParagraph }
			#endregion Default: paragraph
		}
	}
	end {
		if ($inBullet) {
			'</ul>'
		}
		if ($currentParagraph) { Write-Paragraph -Text $currentParagraph }
	}
}