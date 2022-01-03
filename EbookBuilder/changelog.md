# Changelog

## 2.4.24 (2022-01-03)

+ New: Command: Read-EBEpub - extracts chapters from an epub ebook and converts them to markdown
+ New: Block: Hidden - adds a way to include notes in chapters that simply don't show in the output.
+ Upd: Converter HTML->MD - improved parsing of italics and bold styles to improve Markdown formatting compliance
+ Fix: Stylesheet to inline style conversion now follows a deterministic order, avoiding unexpected updates to unchanged chapters in HTML export.

## 2.3.20 (2021-09-21)

+ Fix: Read-EBCssStyleSheet - throws error on empty class

## 2.3.19 (2021-09-17)

+ New: Authoring - Added ability to add inline styles
+ New: Authoring - Added support for markdown-native bullet points, code blocks and notes
+ Upd: Book Project configuration - changed the default setting for importing from RoyalRoad to expect no chapter title within the text body
+ Fix: Error exporting to RoyalRoad html format when split into multiple books

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