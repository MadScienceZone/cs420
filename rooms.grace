// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Room definitions
//
import "formatting" as fmt
import "things"     as things

class Room {
    def name = "Non-descript room."
    def description = "Nothing to see here. Move along."
    def canMoveHere is readable = true
    var visited := false
    var contents := []

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
    method canMoveHere {
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
There is an open door to the east, leading to a small room.›
    var contents := [
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

    var contents := [things.anteroomSign, things.anteroomWalls]

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
}

def deposit = object {
    inherit Room
}
