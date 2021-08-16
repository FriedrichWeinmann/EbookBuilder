# Changelog

## 2.3.15 (2021-08-16)

+ New: Command Export-EBRoyalRoadPage - export chapters as html document for pasting into Royal Road
+ New: Command Read-EBCssStyleSheet - read/parse css stylesheets and generate resulting class-style mappings
+ New: Command ConvertTo-EBHtmlInlineStyle - converts html  text, replacing classes with their associated styles
+ Upd: Config schema - added RRStyle setting to point at custom folder for CSS styles used when exproting to Rooyal Road
+ Upd: Config schema - added RRExportPath setting to point at output folder for exporting to Royal Road Html format

## 2.2.10 (2021-08-11)

+ New: Integration into PSModuleDevelopment templates
+ New: Command New-EBBookProject - create a project scaffold for authoring books
+ New: Command Export-EBMdBook - build a book project project (as generated from scaffold) into an ebook series
+ New: Command ConvertFrom-EBMarkdownLine - Converts markdown notation of bold and cursive to html.
+ New: Command Read-EBMdDataSection - Converts markdown data notation into a hashtable
+ New: Command Read-EBMdBlockData
+ Upd: Improved Royal Road synchronization
+ Upd: Export-EBBook - added improved metadata support, including metadata recognized by Calibre (Series, Tags, etc.).
+ Removed: Built-in markdown blocks were removed (and are now part of the project scaffold)

## 2.1.1 (2021-07-20)

+ New: Markdown-based authoring
+ New: Synchronizing from Royal Road

## 1.0.0 (2019-11-??)

+ Initial Release