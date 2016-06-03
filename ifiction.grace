// vi:set ai sm nu ts=4 sw=4 expandtab:

import "sys"        as sys
import "io"         as io
import "rooms"      as rooms
import "formatting" as fmt
import "parser"     as parser

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

print "Interactive Fiction demonstration project by Steve Willoughby"
print "Portland State University, Spring 2016, CS 420"
print "Type “HELP” for assistance."
print ""

def player = object {
    var currentLocation := rooms.lobby

    method complain (message) {
        print(message)
    }
    method quit {
        takeAction "score"
        sys.exit
    }
    method look {
        currentLocation.fullLook
    }

    method moveDirection (direction) {
        moveTo(currentLocation.destinationFrom(direction))
    }

    method moveTo (location) {
        if (location.canMoveHere) then {
            currentLocation := location
            currentLocation.look
            currentLocation.visitedHere
            setParserContext
        }
    }

    method setParserContext {
        parser.vocabulary.clear
        currentLocation.updateVocabulary(parser.vocabulary)
    }

    method takeAction (verb) {
        match (verb)
            case {"inventory" → print "You are empty-handed." }
            case {"score"     → print "You scored 0 out of 10,000,000 possible. You are a complete loser." }
            case {_           → print ‹I'm not sure how to just “{verb}”. 
Do you perhaps need a noun in that sentence somewhere?›}
    }

    method takeAction (verb) on (anObject) {
        anObject.doAction(verb)
    }

    method takeAction (verb) on (directObject) indirect (preposition) with (indirectObject) {
        print "I don't know how to {verb} anything {preposition} anything else yet."
        print "My programmer needs to teach me how to do that soon."
    }

    method takeAction (verb) indirect (preposition) with (indirectObject) {
        print "I don't know how to {verb} {preposition} anything yet."
        print "My programmer needs to teach me how to do that soon."
    }
}

player.moveTo (rooms.lobby)

while {io.input.eof.not} do {
   io.output.write(fmt.style.enter (fmt.boldYellow) with "> ")
   var userInput := io.input.getline()
   io.output.write(fmt.style.exit)
   parser.parse (userInput) forPlayer (player)
}
player.quit
