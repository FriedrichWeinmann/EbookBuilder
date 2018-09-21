function Read-EBMicrosoftDocsIndexPage
{
<#
	.SYNOPSIS
		Converts an index page of a Microsoft Docs into a book.
	
	.DESCRIPTION
		Converts an index page of a Microsoft Docs into a book.
		Resolves all links in the index.
	
	.PARAMETER Url
		The Url to the index page.
	
	.PARAMETER StartIndex
		Start Index the pages will begin with.
		Index is what Export-EBBook will use to determine page order.
	
	.EXAMPLE
		PS C:\> Read-EBMicrosoftDocsIndexPage -Url https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory
	
		Parses the Active Directory Security Best Practices into page and image objects.
#>
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
