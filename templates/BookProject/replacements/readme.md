# Replacements

This is the location for all the custom replacements to execute within each chapter.
Create as many psd1 files as needed.
All files are merged.

Replacement happens as final stage before creating markdown documents from the RR source.

## Syntax

Each psd1 file is a hashtable at the root level.
You can either specify global string replacements or for individual files / chapters.

> Global

The global node is a hashtable of keys with arbitrary name containing yet another hashtable each.
The nested hashtable contains three keys:

+ Pattern: The regex pattern to match in the text source.
+ Text: The text to replace the matched content with.
+ Weight: Numeric value governing the processing order. The lower the number, the sooner it is applied

Example Replacement:

```powershell
@{
    Global = @{
        'ListItem' = @{
            Pattern = '<li><span style="color: rgba\(0, 128, 128, 1\)">(.+?)</span></li>'
            Text    = '+ $1'
            Weight  = 20
        }
    }
}
```

> Per Chapter

The "per-chapter" logic works pretty much the same way, only instead of the "Global" key, provide the chapter number.
Note: This is the number of post from the starting page, which depending on the author may or may not match the official chapter number from a book perspective.
