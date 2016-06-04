// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- player object
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
//

import "rooms"      as rooms
import "parser"     as parser
import "sys"        as sys

def player = object {
    var currentLocation := rooms.lobby
    var inventory := list []
    var scores := dictionary []

    method isCarrying (obj) { inventory.contains(obj) }
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

    method addToScore (points) for (reason) {
        if (scores.containsKey(reason).not) then {
            scores.at(reason)put(points)
            print "You hear the faint sound of a chime in the distance. (+{points} points)"
        }
    }
    method totalScore { scores.fold({a, b → a + b}) startingWith (0) }
    method printScore {
        def total = totalScore
        def maxScore = 50

        print "You scored {total} out of a possible {maxScore} points."
        printRank(total) of (maxScore)
        scores.keysAndValuesDo({reason, points →
            print "   {reason}: {points} points"
        })
    }
    method printRank (total) of (maxScore) {
        def pct = (total*100) / maxScore
        if (pct == 0) then {print "You are a complete loser."}
        elseif (pct < 40) then {print "That gives you the rank of Amateur Adventurer."}
        elseif (pct < 60) then {print "That gives you the rank of Intermediate Adventurer."}
        elseif (pct < 99) then {print "That gives you the rank of Advanced Adventurer."}
        else                   {print "That gives you the rank of Super Adventuring Genius!"}
    }


    method moveTo (location) {
        if (currentLocation.canLeaveHere(self)) then {
            if (location.canMoveHere(self)) then {
                currentLocation := location
                currentLocation.look
                currentLocation.visitedHere
                setParserContext
            }
        }
    }

    method setParserContext {
        parser.vocabulary.clear
        currentLocation.updateVocabulary(parser.vocabulary)
        for (inventory) do { item → item.updateVocabulary(parser.vocabulary) }
    }

    method takeObject (obj) {
        if (obj.pickUp) then {
            currentLocation.yieldObject(obj)
            inventory.add(obj)
            if (obj.takeScore > 0) then {
                addToScore (obj.takeScore) for ("picked up {obj.shortDescription}")
            }
        }
    }

    method dropObject (obj) {
        if (giveUpObject(obj)) then {
            currentLocation.acceptObject(obj)
        }
    }

    method giveUpObject (obj) {
        if (inventory.contains(obj)) then {
            if (obj.drop) then {
                inventory.remove(obj)
                return true
            }
        }
        return false
    }
        

    method showInventory {
        if (inventory.size == 0) then {
            print "You are empty-handed."
        }
        else {
            print "You are carrying:"
            for (inventory) do { item → 
                print "   {item.shortDescription}"
            }
        }
    }

    method takeAction (verb) {
        match (verb)
            case {"inventory" → showInventory }
            case {"score"     → printScore }
            case {_           → print ‹I'm not sure how to just “{verb}”. 
Do you perhaps need a noun in that sentence somewhere?›}
    }

    method takeAction (verb) on (anObject) {
        match (verb) 
            case { "take" → takeObject(anObject) }
            case { "drop" → dropObject(anObject) }
            case { _      → anObject.doAction(verb) forPerson (self) }
    }

    method takeAction (verb) on (directObject) indirect (preposition) with (indirectObject) {
        try { indirectObject.doIndirectAction (verb) forPerson (self) with (directObject) andPreposition (preposition) }
            catch { parser.ActionNotResolved → 
                try {directObject.doAction (verb) forPerson (self) withIndirectObject (indirectObject) andPreposition (preposition) }
                    catch { parser.ActionNotResolved →
                        print "I don't know how to use “{verb} {preposition}” in that manner."
                    }
            }
    }

    method takeAction (verb) indirect (preposition) with (indirectObject) {
        try { indirectObject.doIndirectAction (verb) forPerson (self) withPreposition (preposition) }
            catch { parser.ActionNotResolved → print "I don't know how to {verb} {preposition} that." }
    }
}
