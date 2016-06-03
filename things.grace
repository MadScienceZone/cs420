//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Thing definitions
//

class Thing {
    def actions = dictionary []
    def adjectives = list []
    def nouns = list []
    def longDescription is readable = ""
    def shortDescription is readable = ""
    method look {required}

    method updateVocabulary (vocab) {
        for (actions.keys) do { verb → vocab.addVerb(verb) }
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

    method doAction (verb) {
        if (verb == "examine") then {print(longDescription)}
        else {actions.at (verb) ifAbsent {{print "I don't see how you can do that to the {shortDescription}."}}.apply}
    }
}

class Scenery {
    inherit Thing
    method look {}
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
        "count"::{print "There are 4,267 floor tiles."},
        "touch"::{print "The floor tiles are very smooth."}
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
        "count"::{print ‹The fact that there are seven chandeliers in the room is probably less 
impressive than the fact that in total, they contain 3,584 individual shards
of crystal.  You feel silly for bothering to count them, however.›},
        "touch"::{print "I don't recommend it. They are fragile."}
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
        "touch"::{print "Don't be silly.  There's no way you're that tall."}
    ]
    def nouns = list ["ceiling"]
    def adjectives = list ["vaulted"]
}

def walls = object {
    inherit Scenery

    def shortDescription is readable = "walls"
    def longDescription is readable = ‹You see nothing remarkable about the walls here.›
    def actions = dictionary [
        "touch"::{print "The walls are smooth and slightly cool to the touch."},
        "push"::{print "The wall doesn't budge."}
    ]
    def nouns = list ["wall", "walls"]
    def adjectives = list ["smooth", "cool"]
}

def anteroomWalls = object {
    inherit Scenery

    def shortDescription is readable = "walls"
    def longDescription is readable = ‹The only thing you notice about the walls here is a sign engraved in one of them.›
    def actions = dictionary [
        "touch"::{print "The walls are smooth (except for the sign) and slightly cool to the touch."},
        "push"::{print "The wall doesn't budge."},
        "read"::{print "Try reading the sign, not the wall."}
    ]
    def nouns = list ["wall", "walls"]
    def adjectives = list ["smooth", "cool"]
}

def anteroomSign = object {
    inherit Scenery

    def shortDescription is readable = "sign"
    def longDescription is readable = "The sign is carved directly into the wall surface."
    def actions = dictionary [
        "read"::{print ‹The sign reads:
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
    var worn := false

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
        "wear"::{self.putOnCups},
        "weild"::{self.putOnCups},
        "remove"::{self.removeCups}
    ]
    def adjectives = list ["suction"]
    def nouns = list ["cup", "cups"]

    method putOnCups {
        if (worn) then { print "You're already wearing them." }
        else { worn := true; print "You place the suction cups on your hands." }
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
        "read"::{print ‹Welcome to the Small Object Bank.
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
