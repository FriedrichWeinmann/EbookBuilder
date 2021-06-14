function Read-EBRoyalRoad {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Url,
		
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[hashtable]
		$Books = @{ },
		
		[string]
		$OutPath
	)
	
	begin {
		$index = 1
		$bookCount = 1
		
		if (-not $Books[1]) {
			$Books[1] = $Name
		}
		$currentBook = '{0} {1} - {2}' -f $Name, $bookCount, $Books[1]
		$currentBookPath = Join-Path -Path $OutPath -ChildPath $currentBook
		
		if (-not (Test-Path -Path $currentBookPath)) {
			$null = New-Item -Path $currentBookPath -Force -ItemType Directory -ErrorAction Stop
		}
	}
	process {
		$nextLink = $Url
		while ($nextLink) {
			Write-PSFMessage -Message 'Processing {0} Chapter {1} : {2}' -StringValues $Name, $index, $nextLink
			$page = Read-RRChapter -Url $nextLink -Index $index
			$index++
			$nextLink = $page.NextLink
			
			$page.TextMD | Set-Content -Path ("{0}\{1}-{2:D4}-{3:D4}.md" -f $currentBookPath, $Name, $bookCount, $index) -Encoding UTF8
			
			if ($Books[$index]) {
				$bookCount++
				$currentBook = '{0} {1} - {2}' -f $Name, $bookCount, $Books[$index]
				$currentBookPath = Join-Path -Path $OutPath -ChildPath $currentBook
				
				if (-not (Test-Path -Path $currentBookPath)) {
					$null = New-Item -Path $currentBookPath -Force -ItemType Directory -ErrorAction Stop
				}
			}
		}
	}
}