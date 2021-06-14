function Read-EBRoyalRoad {
	<#
	.SYNOPSIS
		Reads an entire series from Royal Road.
	
	.DESCRIPTION
		Reads an entire series from Royal Road.
		Converts it into the markdown format expected by Read-EBMarkdown.
	
	.PARAMETER Url
		The Url to the first chapter of a given Royal Road series
	
	.PARAMETER Name
		Name of the series
	
	.PARAMETER Books
		A hashtable mapping page numbers as the start of a book to the name of that book.
		If left empty, there will only be one book, named for the series.
		Each page number key must an integer type.
	
	.PARAMETER OutPath
		The folder in which to create one subfolder per book, in which the chapter files will be created.
	
	.EXAMPLE
		PS C:\> Read-EBRoyalRoad -Url https://www.royalroad.com/fiction/12345/evil-incarnate/chapter/666666/1-end-of-all-days -Name 'Evil Incarnate' -OutPath .

		Downloads the specified series, creates a folder in the current path and writes each chapter as its own .md file into that folder.
	#>
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