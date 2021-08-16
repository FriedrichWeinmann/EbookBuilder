# Ebook Builder

A module that is designed to build Ebooks from Html or MarkDown input.
Also a full EBook authoring toolkit.

## Installation

To install the module, run:

```powershell
Install-Module EbookBuilder
```

## Use

> Create new book Project

This will create a new book project:

```powershell
New-EBBookProject -Name InfernalAdventures -Author 'Fred' -Publisher 'Fred'
```

It can be used to build author ebooks or publish to [Royal Road](https://www.royalroad.com/).
For an optimal authoring experience, it is recommended to use Visual Studio Code and install the recommended extensions.

> Convert Microsoft Docs Page

```powershell
$url = 'https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory'
Read-EBMicrosoftDocsIndexPage -Url $url | Export-EBBook -Path . -Name ads-best-practices.epub -Author "Friedrich Weinmann" -Publisher "Infernal Press"
```

> Build from Markdown

```powershell
Get-ChildItem -Path *.md | Read-EBMarkdown | Export-EBBook -Path C:\Ouput -Name MyBook -Author 'Friedrich Weinmann' -Publisher 'Infernal Press'
```
