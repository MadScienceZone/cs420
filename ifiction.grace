// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- main module (RUN THIS)
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
//

import "sys"        as sys
import "io"         as io
import "rooms"      as rooms
import "formatting" as fmt
import "parser"     as parser
import "people"     as people

//
// We use ANSI codes to add a little color to the game experience.
// It's been a few decades now since that was a novelty, so hopefully
// that won't be an issue, but just in case it might be, we'll allow
// a way to run the game without any ANSI escape sequences being sent.
//
// Of course, we'll just unapologetically make gratuitous use of Unicode
// characters.  It's 2016.  I'm going to bet you're not running this code
// on a PDP-11 via ASR-33 teletype.  If you are, here's a nickel to buy 
// yourself a real computer (h/t to Scott Adams; see 
// http://dilbert.com/strip/1995-06-24 ).
//
if (((sys.argv.size) > 1) && {(sys.argv[2]) == "-a"}) then {
    fmt.switchToPlainStyle
} else {
    print "*** IF YOU CAN READ THIS, you aren't using an ANSI-compatible terminal emulator."
    print "In that case, type “quit” and re-start the program with the “-a” option."
    io.output.write("\u001b[H\u001b[2J")
}

print (fmt.style.render "Interactive Fiction demonstration project" as (fmt.titleStyle))
print (fmt.style.render "Steve Willoughby, Portland State University, CS 420, Spring 2016" as (fmt.subTitleStyle))
print (fmt.style.render "Type “HELP” for assistance." as (fmt.subTitleStyle))
print ""

people.player.moveTo (rooms.lobby)

while {io.input.eof.not} do {
   io.output.write(fmt.style.enter (fmt.boldYellow) with "> ")
   var userInput := io.input.getline()
   io.output.write(fmt.style.exit)
   parser.parse (userInput) forPlayer (people.player)
}
print "Well, if you're going to hang up on me, I guess this is over now."
people.player.quit
