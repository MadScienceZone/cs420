// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- tangible objects
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
//
//

import "parser" as parser

class Thing {
    def actions = dictionary []
    def indirectActions = dictionary []
    def adjectives = list []
    def nouns = list []
    def longDescription is readable = ""
    def shortDescription is readable = ""
    def isLargeObject is readable = false
    var isBeingCarried is readable := false
    def takeScore is readable = 0
    def depositScore is readable = 0

    // Return true if ok to move into player's inventory
    method pickUp { pickUp' }       // because "alias" not yet supported in C minigrace
    method pickUp' { 
        if (isBeingCarried) then {
            print "You're already carrying the {shortDescription}."
            false
        }
        else {
            isBeingCarried := true
            true
        }
    }

    // Return true if ok to move out of player's inventory
    method drop { drop' }       // because "alias" not yet supported in C minigrace
    method drop' {
        if (isBeingCarried) then {
            isBeingCarried := false
            true
        }
        else {
            print "You're not carrying it."
            false
        }
    }

    method look {required}


    method updateVocabulary (vocab) {
        for (actions.keys) do { verb → vocab.addVerb(verb) }
        for (indirectActions.keys) do { verb → vocab.addVerb(verb) }
        for (nouns) do { noun →
            if (adjectives.size == 0) then {
                vocab.addNoun (noun) forObject (self)
            } 
            else {
                for (adjectives) do { adj → 
                    vocab.addNoun (noun) withAdjective (adj) forObject (self)
                }
            }
        }
    }

    method doAction (verb) forPerson (who) {
        if (verb == "examine") then {print(longDescription)}
        else {actions.at (verb) ifAbsent {{print "I don't see how you can do that to the {shortDescription}."}}.apply(who)}
    }

    method doIndirectAction (verb) forPerson (who) with (otherObject) andPreposition (prep) {
        indirectActions.at (verb) ifAbsent {parser.ActionNotResolved.raise (verb++" "++prep)}.apply(who, otherObject, prep)
    }

    method doAction (verb) forPerson (who) withIndirectObject (otherObject) andPreposition (prep) {
        parser.ActionNotResolved.raise (verb++" "++prep)
    }

    method doIndirectAction (verb) forPerson (who) withPreposition (prep) {
        doAction (verb++" "++prep) forPerson (who)
    }
}

class Scenery {
    inherit Thing
    method look {}

    method pickUp {
        print "You can't take the {shortDescription}, don't be silly."
        false
    }
}

def floorTiles = object {
    inherit Scenery

    def shortDescription is readable = "floor tiles"
    def longDescription is readable = ‹The polished floor tiles are of exquisite workmanship, the marbled contours
intertwining in patterns which no two tiles repeat.  You waste an inordinate
amount of time staring at them and comparing them to one another, lost in awe
at the workmanship.  Eventually, it occurs to you that you probably have better
things to do and once again start paying attention to the rest of your 
surroundings.›
    def actions = dictionary [
        "count"::{p → print "There are 4,267 floor tiles."},
        "touch"::{p → print "The floor tiles are very smooth."}
    ]
    def nouns = list ["tiles", "tile"]
    def adjectives = list ["floor", "marble", "polished"]
}

def chandeliers = object {
    inherit Scenery

    def shortDescription is readable = "chandeliers"
    def longDescription is readable = ‹The chandeliers are a splendor to behold, made from purest clear crystal shards
suspended in mid-air on metal cables.  You can't quite make out the light 
source because staring at them too long makes your eyes hurt.›

    def actions = dictionary [ 
        "count"::{p → print ‹The fact that there are seven chandeliers in the room is probably less 
impressive than the fact that in total, they contain 3,584 individual shards
of crystal.  You feel silly for bothering to count them, however.›},
        "touch"::{p → print "I don't recommend it. They are fragile."}
    ]
    def nouns = list ["chandelier", "chandeliers", "shards", "shard", "light", "lights", "cable", "cables"]
    def adjectives = list ["crystal"]
}

def ceiling = object {
    inherit Scenery

    def shortDescription is readable = "ceiling"
    def longDescription is readable = ‹The vaulted ceiling towers above the floor here, causing you to wonder at the
sheer cost of construction for a building of this type.›

    def actions = dictionary [
        "touch"::{p → print "Don't be silly.  There's no way you're that tall."}
    ]
    def nouns = list ["ceiling"]
    def adjectives = list ["vaulted"]
}

def walls = object {
    inherit Scenery

    def shortDescription is readable = "walls"
    def longDescription is readable = ‹You see nothing remarkable about the walls here.›
    def actions = dictionary [
        "touch"::{p → print "The walls are smooth and slightly cool to the touch."},
        "push"::{p → print "The wall doesn't budge."}
    ]
    def nouns = list ["wall", "walls"]
    def adjectives = list ["smooth", "cool"]
}

def anteroomWalls = object {
    inherit Scenery

    def shortDescription is readable = "walls"
    def longDescription is readable = ‹The only thing you notice about the walls here is a sign engraved in one of them.›
    def actions = dictionary [
        "touch"::{p → print "The walls are smooth (except for the sign) and slightly cool to the touch."},
        "push"::{p → print "The wall doesn't budge."},
        "read"::{p → print "Try reading the sign, not the wall."}
    ]
    def nouns = list ["wall", "walls"]
    def adjectives = list ["smooth", "cool"]
}

def anteroomSign = object {
    inherit Scenery

    def shortDescription is readable = "sign"
    def longDescription is readable = "The sign is carved directly into the wall surface."
    def actions = dictionary [
        "read"::{p → print ‹The sign reads:
 _____________________________________________________________________________
|                                                                             |
|                           VAULT INSTRUCTIONS                                |
|                                                                             |
| Deposit your items into the recepticles in the Deposit Room to the north.   |
| Authorized personnel may access the vault to the east to obtain the highly  |
| valuable items stored there, which may be of interest to deposit.           |
|_____________________________________________________________________________|›}
    ]
    def nouns = list ["sign", "letters", "engraving", "instructions"]
    def adjectives = list ["engraved"]
}

def suctionCups = object {
    inherit Thing
    var worn is readable := false
    def takeScore is readable = 5

    method look {print "There is a pair of suction cups here."}
    method shortDescription {
        if (worn) then {"suction cups (worn)"}
        else {"suction cups"}
    }
    method longDescription {
        if (worn) then { "A pair of suction cups, curently being worn." }
        else { "A pair of suction cups. They look like you could wear them." }
    }

    def actions = dictionary [
        "wear"::{p → self.putOnCups(p)},
        "put on"::{p → self.putOnCups(p)},
        "weild"::{p → self.putOnCups(p)},
        "remove"::{p → self.removeCups},
        "take off"::{p → self.removeCups}
    ]
    def adjectives = list ["suction"]
    def nouns = list ["cup", "cups"]

    method putOnCups (player) {
        if (isBeingCarried.not) then {
            print "You'll have to pick them up first."
        }
        else {
            if (worn) then { print "You're already wearing them." }
            else { 
                worn := true; 
                print "You place the suction cups on your hands." 
                player.addToScore 10 for "wearing the suction cups"
            }
        }
    }

    method drop {
        if (worn) then {
            print "(Removing them from your hands first.)"
            worn := false
        }
        drop'
    }

    method removeCups {
        if (worn) then { worn := false; print "You remove the suction cups." }
        else { print "You aren't wearing them right now." }
    }
}

def leaflet = object {
    inherit Thing

    method look {print "There is a leaflet here."}
    def shortDescription is readable = "leaflet"
    def longDescription is readable = "This is a small leaflet, which you can read if you like."
    def actions = dictionary [
        "read"::{p → print ‹Welcome to the Small Object Bank.
This state-of-the art facility was created to provide a safe place to stash
your valuables, such as shiny rocks of various sizes.  These may be deposited
in the Deposit Room beyond the lobby area.  If you don't have any valuable
rocks with you, that's unfortunate.  We do keep a supply of such things in the
vault but that's off-limits to the likes of you.

Enjoy your banking experience with us!

(This tiny interactive fiction game was created as a term project for CS 420,
“Object Oriented Programming” at Portland State University, Spring 2016, to
demonstrate how object-oriented design can be employed to parse simple English
sentences, as well as how OOP can be used to model a “real-world” environment
containing such things as rooms to explore, objects with which to interact, and
how the language parser can adapt the semantics of sentences typed to cause 
actions to take place in this little arena of objects.)›}
    ]
    def adjectives = list ["small"]
    def nouns = list ["leaflet", "pamphlet", "brochure"]
}

def smallRock = object {
    inherit Thing
    def takeScore is readable = 5
    def depositScore is readable = 10

    method look { print "There is a small rock here." }
    def shortDescription is readable = "small rock"
    def longDescription is readable = ‹This small rock is a cut, polished semiprecious stone of good workmanship.
It looks quite valuable.›
    def actions = dictionary [
        "appraise"::{p → print "It would be worth about 1200 Zorkmids if you were playing a different game right now."}
    ]
    def nouns = list ["rock", "stone"]
    def adjectives = list ["small", "semiprecious"]
}

def largeRock = object {
    inherit Thing
    def takeScore is readable = 5
    def depositScore is readable = 10

    method look { print "There is a large rock here." }
    def isLargeObject is readable = true
    def shortDescription is readable = "large rock"
    def longDescription is readable = ‹This large rock is a dull gray color.  You know the local townsfolk consider
it to be quite valuable for no adequately explained reason.›
    def actions = dictionary [
        "appraise"::{p → print "It doesn't look like much, to be honest."}
    ]
    def nouns = list ["rock", "stone"]
    def adjectives = list ["large", "gray", "worthless", "dull"]
}

def lockBoxes = object {
    inherit Scenery

    def shortDescription is readable = "lock boxes"
    def longDescription is readable = ‹Countless little boxes, row by row, column by column, covering every wall
surface in the vault.›
    def actions = dictionary [
        "open"::{p → print "I don't see any means of opening the boxes. They're not yours, anyway."},
        "force"::{p → print "I don't see any means of opening the boxes. They're not yours, anyway."},
        "break"::{p → print "I don't see any means of opening the boxes. They're not yours, anyway."},
        "count"::{p → print "I already told you they're countless."}
    ]
    def nouns = list ["box", "boxes"]
    def adjectives = list ["lock", "little"]
}

def smallHole = object {
    inherit Scenery

    def shortDescription is readable = "small hole"
    def longDescription is readable = ‹This is a smooth, square hole carved into the wall, approximately 1.5 meters
from the floor.  If you look very carefully, you can just make out the words
“DEPOSIT VALUABLE ROCKS HERE” engraved around the edge of the hole.›
    def actions = dictionary [
        "open"::{p → print "It's already open. In fact, it's not possible for it not to be."}
    ]
    def indirectActions = dictionary [
        "drop"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) },
        "put"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) },
        "deposit"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) }
    ]
    def nouns = list ["hole", "receptacle", "slot"]
    def adjectives = list ["small", "smooth"]

    method put (dobj) intoMeWith (prep) forPerson (actor) {
        if (dobj.isBeingCarried.not) then {
            print "I don't see how you can do that when you're not even carrying the {dobj.shortDescription}."
        }
        elseif (dobj.isLargeObject) then {
            print "The {dobj.shortDescription} is too large to fit in there."
        }
        else {
            if (actor.giveUpObject(dobj)) then {
                print "You place the {dobj.shortDescription} into the small hole."
                print "It noisily clatters as it drops through a chute into some"
                print "hidden storage container far below this room."
                if (dobj.depositScore > 0) then {
                    actor.addToScore (dobj.depositScore) for "depositing the {dobj.shortDescription}"
                }
                actor.setParserContext
            }
        }
    }
}

def largeHole = object {
    inherit Scenery

    def shortDescription is readable = "large hole"
    def longDescription is readable = ‹This is a rough, round hole carved into the wall, approximately 1.5 meters
from the floor.  If you look very carefully, you can just make out the words
“DEPOSIT LESS VALUABLE ROCKS HERE” engraved around the edge of the hole.›
    def actions = dictionary [
        "open"::{p → print "It's already open. In fact, it's not possible for it not to be."}
    ]
    def indirectActions = dictionary [
        "drop"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) },
        "put"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) },
        "deposit"::{actor, dobj, prep → put (dobj) intoMeWith (prep) forPerson (actor) }
    ]
    def nouns = list ["hole", "receptacle", "slot"]
    def adjectives = list ["large", "rough"]

    method put (dobj) intoMeWith (prep) forPerson (actor) {
        if (dobj.isBeingCarried.not) then {
            print "I don't see how you can do that when you're not even carrying the {dobj.shortDescription}."
        }
        else {
            if (actor.giveUpObject(dobj)) then {
                print "You place the {dobj.shortDescription} into the large hole."
                print "It noisily clatters as it drops through a chute into some"
                print "hidden storage container far below this room."
                if (dobj.depositScore > 0) then {
                    actor.addToScore (dobj.depositScore) for "depositing the {dobj.shortDescription}"
                }
                actor.setParserContext
            }
        }
    }
}
