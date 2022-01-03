function Read-EBMarkdown {
	<#
	.SYNOPSIS
		Reads a markdown file and converts it to a page to be built into an ebook
	
	.DESCRIPTION
		Reads a markdown file and converts it to a page to be built into an ebook
	
	.PARAMETER Path
		Path to the file to read.
		
	.PARAMETER InlineStyles
		Hashtable mapping inline decorators to span classes.
		Used to enable inline style customizations.
		For example, when providing a hashtable like this:
		@{ 1 = 'spellcast' }
		It will convert this line:
		"Let me show you my #1#Fireball#1#!"
		into
		"Let me show you my <span class="spellcast">Fireball</span>!"
	
	.EXAMPLE
		PS C:\> Get-ChildItem *.md | Read-EBMarkdown

		Reads and converts all markdown files in he current folder
	#>
	[OutputType([EbookBuilder.Page])]
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,
		
		[hashtable]
		$InlineStyles = @{ }
	)
	
	begin {
		function ConvertFrom-Markdown {
			[OutputType([EbookBuilder.Page])]
			[CmdletBinding()]
			param (
				[string]
				$Path,
				
				[int]
				$Index,
				
				[hashtable]
				$InlineStyles = @{ }
			)
			
			$lines = Get-Content -Path $Path -Encoding UTF8 | ConvertFrom-InlineStyle -InlineStyles $InlineStyles
			$stringBuilder = New-SBStringBuilder -Name ebook
			$PSDefaultParameterValues['Add-SBLine:Name'] = 'ebook'
			
			$inBlock = $false
			$inCode = $false
			$inBullet = $false
			$inNote = $false
			$inParagraph = $false
			
			$blockData = [pscustomobject]@{
				Attributes = @{ }
				Type	   = $null
				Lines	   = @()
				File	   = $Path
			}
			$paragraph = @()
			$firstPar = $true
			
			foreach ($line in $lines) {
				#region Process Block Content
				if ($inBlock) {
					if ($line -like '## <*') {
						try { $firstPar = ConvertFrom-MdBlock -Type $blockData.Type -Lines $blockData.Lines -Attributes $blockData.Attributes -StringBuilder $stringBuilder }
						catch { Stop-PSFFunction -Message 'Failed to convert block' -ErrorRecord $_ -Target $blockData -EnableException $true -Cmdlet $PSCmdlet }
						$inBlock = $false
					}
					else { $blockData.Lines += $line }
					
					continue
				}
				#endregion Process Block Content
				
				#region Process Code Content
				if ($inCode) {
					if ($line -like '``````*') {
						$paragraph = @()
						Add-SBLine '</pre>'
						$inCode = $false
						$firstPar = $true
						continue
					}
					Add-SBLine $line
					continue
				}
				#endregion Process Code Content
				
				#region Process Bullet Point
				if ($inBullet) {
					if (-not $line.Trim()) {
						Add-SBLine '<li class="defaultLI">{0}</li>' -Values ($paragraph -join ' ')
						Add-SBLine '</ul>'
						$paragraph = @()
						$inBullet = $false
						$firstPar = $true
						continue
					}
					if ($line -notlike '+ *') {
						$paragraph += $line
						continue
					}
					
					if ($paragraph) {
						Add-SBLine '<li class="defaultLI">{0}</li>' -Values ($paragraph -join ' ')
						$paragraph = @()
					}
					$paragraph += $line -replace '^\+ '
					continue
				}
				#endregion Process Bullet Point
				
				#region Process Notes
				if ($inNote) {
					if ($line.Trim()) {
						$paragraph += $line -replace '^>\s{0,1}'
						continue
					}
					
					foreach ($text in ConvertFrom-EBMarkdown -Line $paragraph -ClassFirstParagraph noteFirstPar -ClassParagraph noteText -EmphasisClass noteEmphasis) {
						Add-SBLine $text
					}
					Add-SBLine '<hr/></div>'
					$inNote = $false
					$firstPar = $true
					$paragraph = @()
					continue
				}
				#endregion Process Notes
				
				#region Process Paragraph
				if ($inParagraph) {
					if ($line.Trim()) {
						$paragraph += $line
						continue
					}
					
					$class = 'text'
					if ($firstPar) {
						$class = 'firstpar'
						$firstPar = $false
					}
					
					foreach ($text in ConvertFrom-EBMarkdown -Line $paragraph -ClassFirstParagraph $class -ClassParagraph $class) {
						Add-SBLine $text
					}
					$paragraph = @()
					$inParagraph = $false
					continue
				}
				#endregion Process Paragraph
				
				#region Region Starters
				# Handle begin of a Block
				if ($line -like '## <*') {
					$inBlock = $true
					$blockData = New-Block -Line $line -Path $Path
					continue
				}
				
				# Handle begin of a Code section
				if ($line -like '``````*') {
					$inCode = $true
					$firstPar = $true
					Add-SBLine '<pre>'
					continue
				}
				
				# Handle begin of a Bullet-Points section
				if ($line -like '+ *') {
					$inBullet = $true
					Add-SBLine '<ul>'
					$paragraph += $line -replace '^\+ '
					continue
				}
				
				# Handle begin of a Notes section
				if ($line -like '> *') {
					$inNote = $true
					Add-SBLine '<div class="notes"><hr/>'
					$paragraph += $line -replace '^> '
					continue
				}
				
				# Handle Chapter Title
				if ($line -like '# *') {
					$null = $stringBuilder.AppendLine("<h2>$($line -replace '^# ')</h2>")
					continue
				}
				
				# Handle begin of a Paragraph section
				if ($line.Trim()) {
					$inParagraph = $true
					$paragraph += $line
				}
				#endregion Region Starters
			}
			
			#region Cleanup
			
			#region Process Block Content
			if ($inBlock) {
				try { $firstPar = ConvertFrom-MdBlock -Type $blockData.Type -Lines $blockData.Lines -Attributes $blockData.Attributes -StringBuilder $stringBuilder }
				catch { Stop-PSFFunction -Message 'Failed to convert block' -ErrorRecord $_ -Target $blockData -EnableException $true -Cmdlet $PSCmdlet }
				$inBlock = $false
			}
			#endregion Process Block Content
			
			#region Process Code Content
			if ($inCode) {
				Add-SBLine '</pre>'
				$inCode = $false
				$firstPar = $true
			}
			#endregion Process Code Content
			
			#region Process Bullet Point
			if ($inBullet) {
				Add-SBLine '<li class="defaultLI">{0}</li>' -Values ($paragraph -join ' ')
				Add-SBLine '</ul>'
				$paragraph = @()
				$inBullet = $false
				$firstPar = $true
			}
			#endregion Process Bullet Point
			
			#region Process Notes
			if ($inNote) {
				foreach ($text in ConvertFrom-EBMarkdown -Line $paragraph -ClassFirstParagraph noteFirstPar -ClassParagraph noteText -EmphasisClass noteEmphasis) {
					Add-SBLine $text
				}
				Add-SBLine '<hr/></div>'
				$inNote = $false
				$firstPar = $true
				$paragraph = @()
			}
			#endregion Process Notes
			
			#region Process Paragraph
			if ($inParagraph) {
				$class = 'text'
				if ($firstPar) {
					$class = 'firstpar'
					$firstPar = $false
				}
				
				foreach ($text in ConvertFrom-EBMarkdown -Line $paragraph -ClassFirstParagraph $class -ClassParagraph $class) {
					Add-SBLine $text
				}
				$paragraph = @()
				$inParagraph = $false
			}
			#endregion Process Paragraph
			#endregion Cleanup
			
			New-Object EbookBuilder.Page -Property @{
				Index = $Index
				Name  = (Get-Item -Path $Path).BaseName
				Content = Close-SBStringBuilder -Name ebook
				SourceName = $Path
				TimeCreated = Get-Date
				MetaData = @{ }
			}
		}
		
		function ConvertFrom-InlineStyle {
			[OutputType([string])]
			[CmdletBinding()]
			param (
				[Parameter(ValueFromPipeline = $true)]
				[string[]]
				$Line,
				
				[hashtable]
				$InlineStyles = @{ }
			)
			
			begin {
				$replaceHash = @{ }
				
				foreach ($pair in $InlineStyles.GetEnumerator()) {
					if ($pair.Value -is [string]) {
						$replaceHash["#$($pair.Key)#(.+?)#$($pair.Key)#"] = '<span class="{0}">$1</span>' -f $pair.Value
					}
					else {
						$newValue = '<span class="{0}">' -f $pair.Value.Class
						if ($pair.Value.Prepend) { $newValue += $pair.Value.Prepend }
						$newValue += '$1'
						if ($pair.Value.Append) { $newValue += $pair.Value.Append }
						$newValue += '</span>'
						$replaceHash["#$($pair.Key)#(.+?)#$($pair.Key)#"] = $newValue
					}
				}
			}
			process {
				foreach ($string in $Line) {
					foreach ($pair in $replaceHash.GetEnumerator()) {
						$string = $string -replace $pair.Key, $pair.Value
					}
					$string
				}
			}
		}
		
		function New-Block {
			[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
			[CmdletBinding()]
			param (
				[string]
				$Line,
				
				[string]
				$Path
			)
			
			$type = $Line -replace '## <(\w+).+$', '$1'
			$attributes = @{ }
			$entries = $Line | Select-String '(\w+)="(.+?)"' -AllMatches
			foreach ($match in $entries.Matches) {
				$attributes[$match.Groups[1].Value] = $match.Groups[2].Value
			}
			
			[pscustomobject]@{
				Attributes = $attributes
				Type	   = $type
				Lines	   = @()
				File	   = $Path
			}
		}
		
		$Index = 1
	}
	process {
		foreach ($pathItem in $Path) {
			Write-PSFMessage -Message "Processing: $pathItem"
			ConvertFrom-Markdown -Path $pathItem -Index $Index -InlineStyles $InlineStyles
			$Index++
		}
	}
}