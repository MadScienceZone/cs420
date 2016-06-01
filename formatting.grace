// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// ANSI Terminal formatting is available using the "style" variable which is an object
// instance that handles escape codes for colors and such:
//      style.render(<some text>) as (<ansi mode(s)>)
// If the user specified that they don't want to see ANSI codes, then style.render()as()
// will just display <some text> without any escape codes added to it.
// 

class FancyStyling {
    method render (text) as (styling)  { "\u001b["++styling++"m"++text++"\u001b[0m" }
    method enter (styling)             { "\u001b["++styling++"m" }
    method enter (styling) with (text) { "\u001b["++styling++"m"++text }
    method exit                        { "\u001b[0m" }
}

class PlainStyling {
    method render (text) as (styling) { text }
    method enter (styling) { "" }
    method enter (styling) with (text) { text }
    method exit { "" }
}

method switchToPlainStyle {
    style := PlainStyling
}

method switchToFancyStyle {
    style := FancyStyling
}

var style := FancyStyling

// Some interesting pre-defined coloring styles
def underlinedCyan = "1;4;36"
def boldYellow     = "1;33"
def reverse        = "7"
def errorStyle     = "1;37;41"
