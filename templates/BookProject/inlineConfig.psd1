<#
In order to enable inline styles, in a way that is quick, simple and reliable,
A compromise between readability and convenience must be met.

Within the markdown text, new inline notations are supported like this:

Text outside #1#enclosed text#1# more text outside.

Basically, the text must be enclosed in "#number#" tags, the numbers available defined here.
They will then be inserted and replaced automatically when building the markdown into html.
#>
@{
    # 1 = 'nameOfSpanClass'
}