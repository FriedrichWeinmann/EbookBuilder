# Ebook Builder

A module that is designed to build Ebooks from Html or MarkDown input.

## Installation

To install the module, run:

```powershell
Install-Module EbookBuilder
```

## Use

> Convert Microsoft Docs Page

```powershell
$url = 'https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory'
Read-EBMicrosoftDocsIndexPage -Url $url | Export-EBBook -Path . -Name ads-best-practices.epub -Author "Friedrich Weinmann" -Publisher "Infernal Press"
```

> Build from Markdown

```powershell
Get-ChildItem -Path *.md | Read-EBMarkdown | Export-EBBook -Path C:\Ouput -Name MyBook -Author 'Friedich Weinmann' -Publisher 'Infernal Press'
```
