# Description

A module that is designed to build Ebooks from Html input.

Initial code is aimed at the Microsoft documentation system:

```powershell
$url = 'https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory'
Read-EBMicrosoftDocsIndexPage -Url $url | Export-EBBook -Path . -Name ads-best-practices.epub -Author "Friedrich Weinmann" -Publisher "Infernal Press"
```