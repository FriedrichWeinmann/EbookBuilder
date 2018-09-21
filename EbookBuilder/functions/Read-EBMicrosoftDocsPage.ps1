function Read-EBMicrosoftDocsPage
{
<#
	.SYNOPSIS
		Parses a web document from the Microsoft documents.
	
	.DESCRIPTION
		Parses a web document from the Microsoft documents.
	
	.PARAMETER Url
		The url of the website to parse.
	
	.PARAMETER StartIndex
		The index of the page. Used for sorting the pages when building the ebook.
	
	.EXAMPLE
		PS C:\> Read-EBMicrosoftDocsPage -Url https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory
	
		Parses the file of the specified link and converts it into a page.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]
		$Url,
		
		[int]
		$StartIndex = 1
	)
	
	begin
	{
		$index = $StartIndex
	}
	process
	{
		foreach ($weblink in $Url)
		{
			$data = Invoke-WebRequest -UseBasicParsing -Uri $weblink
			$main = ($data.RawContent | Select-String "(?ms)<main.*?>(.*?)</main>").Matches.Groups[1].Value
			$source, $title = ($main | Select-String '<h1.*?sourceFile="(.*?)".*?>(.*?)</h1>').Matches.Groups[1 .. 2].Value
			$text = ($main | Select-String '(?ms)<!-- <content> -->(.*?)<!-- </content> -->').Matches.Groups[1].Value.Trim()
			$content = "<h1>{0}</h1> {1}" -f $title, $text
			$webClient = New-Object System.Net.WebClient
			foreach ($imageMatch in ($content | Select-String '(<img.*?src="(.*?)".*?alt="(.*?)".*?>)' -AllMatches).Matches)
			{
				$relativeImagePath = $imageMatch.Groups[2].Value
				$imageName = $imageMatch.Groups[3].Value
				$imagePath = "{0}/{1}" -f ($weblink -replace '/[^/]*?$', '/'), $relativeImagePath
				$image = New-Object EbookBuilder.Image -Property @{
					Data = $webClient.DownloadData($imagePath)
					Name = $imageName
					TimeCreated = Get-Date
					Extension = $imagePath.Split(".")[-1]
					MetaData = @{ WebLink = $imagePath }
				}
				$image
				$content = $content -replace ([regex]::Escape($relativeImagePath)), "../Images/$($image.FileName)"
			}
			
			New-Object EbookBuilder.Page -Property @{
				Index = $index++
				Name  = $title
				Content = $content
				SourceName = $weblink
				TimeCreated = Get-Date
				MetaData = @{ GithubPath = $source }
			}
		}
	}
}
