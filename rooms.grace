// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- room definitions
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
//
//
import "formatting" as fmt
import "things"     as things

class Room {
    def name = "Non-descript room."
    def description = "Nothing to see here. Move along."
    method canMoveHere (player) { true }
    method canLeaveHere (player) { true }
    var visited := false
    var contents := list []

    method acceptObject (obj) { contents.add(obj) }
    method yieldObject (obj) { contents.remove(obj) }

    method updateVocabulary (vocab) {
        for (contents) do { item → item.updateVocabulary(vocab) }
    }

    method look {
        if (visited.not) then {
            fullLook
        }
        else {
            print (fmt.style.render(name) as (fmt.underlinedCyan))
            for (contents) do { item → item.look }
        }
    }

    method fullLook {
        print (fmt.style.render(name) as (fmt.underlinedCyan))
        print (description)
        for (contents) do { item → item.look }
    }

    method visitedHere { visited := true }

    method destinationFrom (direction) {
        noExit
    }
}

def noExit = object {
    inherit Room
    method canMoveHere (player) {
        print "I don't see any way you can move that direction."
        false
    }
}

def lobby = object {
    inherit Room
    def name        is readable = "Lobby"
    def description is readable = ‹This is the ostentatious lobby of an old bank building.  No expense has been
spared, from the marble floor tiles to the crystal chandeliers suspended from
the ceiling.
There is an open doorway to the east, leading to a small room.›
    var contents := list [
        things.floorTiles, 
        things.chandeliers, 
        things.ceiling, 
        things.walls, 
        things.leaflet,
        things.suctionCups
    ]

    method destinationFrom (direction) {
        match (direction)
            case { ‹east› → anteroom }
            case { _      → noExit   }
    }
}

def anteroom = object {
    inherit Room
    def name        is readable = "Anteroom"
    def description is readable = ‹This is a more austere room, compared to the opulence of the lobby (which you
can still see through the open doorway to the west).  You can see a brightly-
lit room to the north, while to the east there is a doorway to a dim, shadowy
chamber beyond.
There is a sign here, engraved on the wall.›

    var contents := list [
        things.anteroomSign, 
        things.anteroomWalls,
        things.ceiling
    ]

    method destinationFrom (direction) {
        match (direction)
            case { ‹west›  → lobby   }
            case { ‹east›  → vault   }
            case { ‹north› → deposit }
            case { _       → noExit  }
    }
}

def vault = object {
    inherit Room
    def name        is readable = "Vault"
    def description is readable = ‹This dimly-lit chamber is a perfect cube 20' on each side. Countless lock
boxes are embedded into the walls here.
To the west is the exit back to the anteroom.›
    var contents := list [
        things.smallRock, 
        things.largeRock, 
        things.lockBoxes
    ]

    method destinationFrom (direction) {
        match (direction)
            case { ‹west› → anteroom }
            case { _      → noExit   }
    }

    method canMoveHere (player) {
        if (player.isCarrying(things.suctionCups).not) then {
            print "You run smack into an invisible wall as you try to enter."
            print "The wall feels smooth as glass to your touch."
            print "(So THAT's what an invisible wall looks like!)"
            false
        }
        elseif (things.suctionCups.worn.not) then { 
            print "You run smack into an invisible wall as you try to enter."
            print "You have a nagging sense that something you're carrying would help."
            false
        }
        else {
            print ‹As you encounter the invisible wall, the suction cups on your hands stick to
its smooth, glass-like surface.  Experimenting a little, you find you can use
them to climb up the wall, which you discover does not extend all the way to
the ceiling.  You climb up, over, and down the other side, into the vault.›
            player.addToScore 5 for "scaling the invisible wall"
            true
        }
    }

    method canLeaveHere (player) {
        if (player.isCarrying(things.suctionCups).not) then {
            print "You run smack into an invisible wall as you try to leave."
            false
        }
        elseif (things.suctionCups.worn.not) then { 
            print "You run smack into an invisible wall as you try to leave."
            print "How did you get IN here, anyway?"
            false
        }
        else {
            print ‹You climb back over the wall again, using the suction cups.›
            true
        }
    }
}

def deposit = object {
    inherit Room

    def name        is readable = "Deposit Room"
    def description is readable = ‹This brightly illuminated room is featureless except for a pair of holes,
one large and the other small, which bank patrons use to deposit their
valuable rocks for secure storage.
To the south is the exit back to the anteroom.›
    var contents := list [
        things.largeHole, 
        things.smallHole,
        things.walls,
        things.ceiling
    ]

    method destinationFrom (direction) {
        match (direction)
            case { ‹south› → anteroom }
            case { _       → noExit   }
    }
}
