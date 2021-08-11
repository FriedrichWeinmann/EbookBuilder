@{
    Global = @{
        'ListItem' = @{
            Pattern = '<li><span style="color: rgba\(0, 128, 128, 1\)">(.+?)</span></li>'
            Text    = '+ $1'
            Weight  = 20
        }
    }
}