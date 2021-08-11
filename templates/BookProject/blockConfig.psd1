@{
    CharacterSheet = @{
        # The string at the beginning of the line of text identifying a section header
        SectionIdentifier = '>'

        # The Header Section defines the section in the character sheet shown at the beginning.
        # All entries will be written without indent.
        Header = 'Header'

        # Additional Sections supported.
        # Section Labels will be used as header, content will be indented
        Sections = @(
            'Classes'
            'Skills'
            'Traits'
            'Titles'
        )
    }
    Skill = @{
        # The string at the beginning of the line of text identifying a section header
        SectionIdentifier = '>'

        # The Data Section defines the section in the skill covering the metadata.
        # Metadata can be accessed in the Header & Footer lines.
        Data = 'Data'

        # The line to use for the header of the Skill notification
        # Data generated in the Data section can be inserted here
        # Comment out to disable element
        Header = '%Name% (Level %Level%)'

        # The line to use for the footer of the Skill notification
        # Data generated in the Data section can be inserted here
        # Comment out to disable element
        Footer = 'Category: %Category%'

        # Additional Sections supported.
        Sections = @(
            'Quote'
            'Description'
        )

        <#
        Define the styling of the section and whether its name should be included as a header
        Default behavior/style: No Header, italic, justify, first paragraph without indent.
        Available Styles:
        + Default / Justify
        + Left
        + Center
        + Right
        + LeftNormal
        + CenterNormal
        + RightNormal
        + JustifyNormal
        #>
        SectionStyle = @{
            Quote = @{ Header = $false; Style = 'Center'; IncludeEmptyLine = $false }
        }
    }
    SkillUpgrade = @{
        # The message to show when displaying skill upgrades
        <#
        Use "<br />" (without quotes) for linebreaks
        Enclose values you want inserted as %ValueName%
        They then need to be provided either as attribute or as enclosed

        Examples:

        1)
        ## <skillupgrade Name="Tracking" Level="12">
        ## </skillupgrade>

        2)
        ## <skillupgrade>
        Name: Tracking
        Level: 12
        ## </skillupgrade>
        #>
        Message = "You have raised the skill: %Name% to level %Level%!"
    }
    SystemMessage = @{
        # What style do you want your system messages to be in by default?
        <#
        Available Styles:
        + Italic: Regular, resolved markdown text, italic, margins above and beneath
        + Boxed: Regular, resolved markdown text, wrapped in a display box.
                 Very distinct "system"-look, but large boxes can cause issues on readers.
        #>
        DefaultStyle = 'Italic'
    }
}