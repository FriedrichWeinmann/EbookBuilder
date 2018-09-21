function Read-EBMicrosoftDocsIndexPage
{
	[CmdletBinding()]
	Param (
		[string]
		$Url,
		
		[int]
		$StartIndex = 0
	)
	
	begin
	{
		$index = $StartIndex
	}
	process
	{
		$indexPage = Read-EBMicrosoftDocsPage -Url $Url -StartIndex $index
		$indexPage
		$index++
		
		$pages = $indexPage.Content | Select-String '<a href="(.*?)"' -AllMatches | Select-Object -ExpandProperty Matches | ForEach-Object { $_.Groups[1].Value }
		$basePath = (Split-Path $indexPage.SourceName) -replace "\\", "/"
		
		foreach ($page in $pages)
		{
			$tempPath = $basePath
			while ($page -like "../*")
			{
				$tempPath = (Split-Path $tempPath) -replace "\\", "/"
				$page = $page -replace "^../", ""
			}
			Read-EBMicrosoftDocsPage -Url ("{0}/{1}" -f $tempPath, $page) -StartIndex $index
			$index++
		}
	}
}
