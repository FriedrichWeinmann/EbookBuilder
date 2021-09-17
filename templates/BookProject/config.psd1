@{
    # Shared settings
    
    # Relative path to where to store the Markdown version of the book
    OutPath         = '\books'
    # Path to the file mapping inline style tags to span classes
    InlineConfig    = '\inlineConfig.psd1'

    # Settings for Markdown --> Epub
    Name            = 'þnameþ'
    Author          = 'þauthorþ'
    Publisher       = 'þpublisherþ'
    Tags            = @()
    Blocks          = "\blocks"
    Style           = '\styles'
    ExportPath      = '\epub'

    # Settings for Markdown --> Royal Road Html
    RRExportPath    = '\rrExport'
    RRStyle         = '\rrStyles'
    

    # Settings for Royal Road --> Markdown
    
    # Insert link to starting chapter.
    Url             = ''
    # Chapter Number of the first chapter
    StartIndex      = 1
    # Book number of the first book. Use if not starting with the first book
    BookIndex       = 1
    # Whether each chapter includes its own title header
    HasTitle        = $false
    
    # Explicit list of books. Map chapter index to name of book.
    # Example:
    <#
        @{
              1 = 'Adventurer'
             33 = 'Taleen Misadventures'
             74 = 'Lady in Black'
            120 = 'War'
        }
    #>
    Books           = @{ }
    # Relative path to the folder containing replacements used to process the web source.
    Replacements    = "\replacements"

    # Chapters which will not be synced from RR due to manual edits in markdown
    ChapterOverride = @( )
}