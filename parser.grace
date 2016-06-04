//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Input Parser
//
// parse <input> forPlayer <player>
//      This is the main entry point for parsing user input.  We take a full string
//      of input as <input>.  The result is that the message is interpreted and based
//      on its semantic meaning, appropriate methods in <player> are invoked to 
//      carry out what the human is asking for <player> to do.  The possibilities
//      are:
//          <player>.complain(<message>)
//              the sentence couldn't be understood for reasons explained in <message>
//
//          <player>.moveDirection(<direction>)
//              the player is to move in a direction, which is a normalized string
//              "north", "south", "east", "west".
//
//          <player>.look
//              print a description of the surroundings of the player
//
//          <player>.quit
//              terminate playing the game
//
//          <player>.inventory
//              print a list of what's in the player's possession
//
//          <player>.takeAction <verb>
//          <player>.takeAction <verb> on <obj>
//          <player>.takeAction <verb> indirect <preposition> with <obj>
//          <player>.takeAction <verb> on <obj> indirect <preposition> with <obj>
//              cause arbitrary actions to be initiated by the player in the game environment
//
// Some standard vocabulary is built-in here, as described below.  The rest is
// dynamically added to the parser as the player moves through the game, adapting
// to his/her surroundings.  Note that in some cases alternative words are normalized
// to a given standard verb to simpify how objects react to the verbs.
//
//  A
//  AN
//  THE
//  DROP   
//  EXAMINE
//  GET                (→ TAKE)
//  GO
//  HELP
//  IN
//  INTO
//  INVENTORY
//  IT
//  LOOK
//  LOOK AT            (→ EXAMINE)
//  MOVE
//  OFF
//  ON
//  ONTO
//  PICK               
//  PICK UP            (→ TAKE)
//  PICK {IT|THEM} UP  (→ TAKE {IT|THEM})
//  PUT                
//  PUT DOWN           (→ DROP)
//  PUT {IT|THEM} DOWN (→ DROP {IT|THEM})
//  QUIT
//  SCORE
//  TAKE
//  THE
//  THEM
//  TO
//  TOWARD
//  WITH
//
// Abbreviations allowed:
//      EXA for EXAMINE
//      I for INVENTORY
//      N, S, E, W for NORTH, SOUTH, EAST, WEST
//

import "unicode" as unicode

def AmbiguousNounError = Exception.refine "ambiguous noun"
def NoSuchNounError = Exception.refine "no such noun"
def ActionNotResolved = Exception.refine "action not resolved"

def noLastObject = object {
}

def vocabulary = object {
    var nouns := dictionary []
    var verbs := list []
    var adjectives := dictionary []
    var lastObject is readable := noLastObject

    method clear {
        nouns := dictionary []
        verbs := list []
        adjectives := dictionary []
    }

    method lastObjectWas    (o)          { lastObject := o }
    method isKnownAdjective (adj:String) { adjectives.containsKey(adj) }
    method isKnownNoun      (n:String)   { nouns.containsKey(n)        }
    method isKnownVerb      (v:String)   { verbs.contains(v)           }

    method addVerb (v:String) { verbs.add(v) }
    method addNoun (n:String) withAdjective (adj:String) forObject (o) { 
        nouns.at (n) ifAbsent {nouns.at (n) put (dictionary []); nouns.at(n)}.at (adj) put (o)
        adjectives.at (adj) ifAbsent {adjectives.at (adj) put (dictionary []); adjectives.at(adj)}.at (n) put (o)
    }
    method addNoun (n:String) forObject (o) {
        addNoun (n) withAdjective "◊" forObject (o)
    }

    // A noun alone is ok if there's no competing nouns in scope
    method resolveNounToObject (n:String) {
        if (nouns.containsKey(n)) then {
            var dobj := nouns.at(n).values.first
            if (nouns.at(n).size ≠ 1) then {
                // but it's ok if they all refer to the same actual object
                for (nouns.at(n)) do { candidate →
                    if (candidate ≠ dobj) then {
                        AmbiguousNounError.raise "Which {n} are you referring to?"
                    }
                }
            }
            dobj
        }
        else {
            NoSuchNounError.raise "I don't see any {n} here."
        }
    }

    // Otherwise we need to figure out which thing they're talking about
    method resolveNounToObject (n:String) withAdjective (adj:String) {
        if (nouns.containsKey(n)) then {
            if (nouns.at(n).containsKey(adj)) then {
                nouns.at(n).at(adj)
            }
            else {
                NoSuchNounError.raise "I don't see any {adj} {n} here."
            }
        }
        else {
            NoSuchNounError.raise "I don't see any {n} here of any sort."
        }
    }

    method resolveAdjectiveToObject (adj:String) {
        var dobj := adjectives.at(adj).values.first
        if (adjectives.at(adj).size ≠ 1) then {
            // we'll still allow this if all the competing objects are in fact the same
            // object under different names.
            for (adjectives.at(adj)) do { candidate →
                if (candidate ≠ dobj) then {
                    AmbiguousNounError.raise "Which {adj} thing are you referring to?"
                }
            }
        }
        print "(I assume you mean the {dobj.shortDescription}.)"
        dobj
    }
}

def pickState = object {
    method accept (word:String) {
        match (word)
            case {"up"        → state := verbStateForVerb "take" }
            case {"it"|"them" → 
                if (vocabulary.lastObject ≠ noLastObject) then {
                    state := pickItState
                }
                else {
                    state := rejectStateBecause "I don't know what you're indirectly referring to as “{word}”."
                }
            }
            case {_ →
                state := verbStateForVerb "pick"    // not "pick up"... must be a verb "pick"
                state.accept (word)
            }
    }

    method terminate (player) {
        state := rejectStateBecause "Pick what?"
    }
}

def pickItState = object {
    method accept (word:String) {
        if (word == "up") then { // pick it up
            state := directObjectState (vocabulary.lastObject) forVerb "take"
        }
        else { // pick it ... (something)
            state := rejectStateBecause "I'm not sure what you mean, I don't understand “pick it” in that context."
        }
    }

    method terminate (player) {
        state := rejectStateBecause "I don't understand. I think there's more you wanted to put at the end of that sentence."
    }
}
            

def putState = object {
    method accept (word:String) {
        match (word)
            case {"down"      → state := verbStateForVerb "drop" }
            case {"it"|"them" →
                if (vocabulary.lastObject ≠ noLastObject) then {
                    state := putItState
                }
                else {
                    state := rejectStateBecause "I don't know what you're indirectly referring to as “{word}”."
                }
            }
            case {_ →
                state := verbStateForVerb "put"  // not "put down"... must be a verb "put"
                state.accept (word)
            }
    }

    method terminate (player) {
        state := rejectStateBecause "Put what? Where?"
    }
}

def putItState = object {
    method accept (word:String) {
        if (word == "down") then { // put it down
            state := directObjectState (vocabulary.lastObject) forVerb "drop"
        }
        else { // put it ... (something)
            state := rejectStateBecause "I don't know what you mean by using “put it” in that context."
        }
    }

    method terminate (player) {
        state := rejectStateBecause "I don't understand. I think there's more you wanted to put at the end of that sentence."
    }
}

def startState = object {
    method accept (word:String) {
        match (word)
            case { "exa"|"examine" → state := verbStateForVerb "examine" }
            case { "help"          → state := helpState }
            case { "look"          → state := lookState }
            case { "quit"          → state := quitState }
            case { "pick"          → state := pickState }
            case { "take"|"get"    → state := verbStateForVerb "take" }
            case { "put"           → state := putState }
            case { "drop"          → state := verbStateForVerb "drop" }
            case { "go"|"move"     → state := moveState }
            case { "n"|"north"     → state := moveDirState "north" }
            case { "s"|"south"     → state := moveDirState "south" }
            case { "e"|"east"      → state := moveDirState "east"  }
            case { "w"|"west"      → state := moveDirState "west"  }
            case { "i"|"inventory" → state := verbStateForVerb "inventory" }
            case { "score"         → state := verbStateForVerb (word) }
            case { _ → 
                if (vocabulary.isKnownVerb(word)) then {
                    state := verbStateForVerb(word)
                }
                else {
                    state := rejectStateBecause("I have no idea what you mean by “{word}”.") 
                }
            }
    }
    method terminate (player) { }
}

var state := startState

def moveState = object {
    method accept (word:String) {
        match (word) 
            case { "to"|"toward" → state := moveToState            }
            case { "n"|"north"   → state := moveDirState ("north") }
            case { "s"|"south"   → state := moveDirState ("south") }
            case { "e"|"east"    → state := moveDirState ("east")  }
            case { "w"|"west"    → state := moveDirState ("west")  }
            case { _             → state := rejectStateBecause("That doesn't make sense as a direction to move.") }
    }
    method terminate (player) {
        player.complain("Which direction do you want to move?")
    }
}

def moveToState = object {
    method accept (word:String) {
        match (word) 
            case { "the"       → state := moveToTheState         }
            case { "n"|"north" → state := moveDirState ("north") }
            case { "s"|"south" → state := moveDirState ("south") }
            case { "e"|"east"  → state := moveDirState ("east")  }
            case { "w"|"west"  → state := moveDirState ("west")  }
            case { _           → state := rejectStateBecause("That doesn't make sense as a direction to move.") }
    }
    method terminate (player) {
        player.complain("Which direction do you want to move?")
    }
}

def moveToTheState = object {
    method accept (word:String) {
        match (word) 
            case { "n"|"north" → state := moveDirState ("north") }
            case { "s"|"south" → state := moveDirState ("south") }
            case { "e"|"east"  → state := moveDirState ("east")  }
            case { "w"|"west"  → state := moveDirState ("west")  }
            case { _           → state := rejectStateBecause("That doesn't make sense as a direction to move.") }
    }
    method terminate (player) {
        player.complain("Which direction do you want to move?")
    }
}

class moveDirState (direction') {
    def direction = direction'
    method accept (word:String) {
        state := rejectStateBecause("You should have stopped at “{direction}”.")
    }
    method terminate (player) {
        player.moveDirection(direction)
        vocabulary.lastObjectWas(noLastObject)
    }
}


def helpState = object {
    method accept (word:String) { 
        state := rejectStateBecause(‹I don't understand. You seem to have extra words at the end of that sentence
that aren't necessary. To get help, just type “help” all by itself.›)
    }
    method terminate (player) {
        player.complain(‹Helpful Hints:
To move around, type compass directions such as GO NORTH, GO SOUTH, etc.
To see your progress, type SCORE.
To give up entirely, type QUIT.
Most commands can be abbreviated in reasonably obvious ways.
Good Luck!›)
    }
}

def lookState = object {
    method accept (word:String) {
        match (word) 
            case { "at" → state := verbStateForVerb "examine" }
            case { _    → state := rejectStateBecause "Look AT something, or just LOOK to see your surroundings." }
    }

    method terminate (player) {
        player.look
        vocabulary.lastObjectWas(noLastObject)
    }
}

class articleStateForVerb (verb') {
    def verb = verb'
    method accept (word:String) {
        if (vocabulary.isKnownAdjective(word)) then { state := adjectiveState (word) forVerb (verb) }
        elseif (vocabulary.isKnownNoun(word)) then { 
            try {state := directObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) }
                catch { e → state := rejectStateBecause (e) }
        }
        else { state := rejectStateBecause "I'm not really sure what object you're referring to here." }
    }
    method terminate (player) {
        player.complain("You didn't specify a complete object to {verb}")
    }
}

class indirectArticleStateForVerb (verb') andForPreposition (prep') andForObject (dobj') {
    def verb = verb'
    def prep = prep'
    def dobj = dobj'
    method accept (word:String) {
        if (vocabulary.isKnownAdjective(word)) then { 
            state := indirectAdjectiveState (word) forVerb (verb) andForPreposition (prep) andForObject (dobj) 
        }
        elseif (vocabulary.isKnownNoun(word)) then {
            try { state := indirectObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) andForPreposition (prep) andForObject (dobj) }
                catch {e → state := rejectStateBecause (e)}
        }
        else { state := rejectStateBecause "I'm not really sure what object you're referring to here, after “{prep}”." }
    }
    method terminate (player) {
        player.complain("You didn't specify a complete object to {verb} {prep}")
    }
}

class indirectArticleStateForVerb (verb') andForPreposition (prep') {
    def verb = verb'
    def prep = prep'
    method accept (word:String) {
        if (vocabulary.isKnownAdjective(word)) then { 
            state := indirectAdjectiveState (word) forVerb (verb) andForPreposition (prep)
        }
        elseif (vocabulary.isKnownNoun(word)) then {
            try { state := indirectObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) andForPreposition (prep) }
                catch {e → state := rejectStateBecause (e)}
        }
        else { state := rejectStateBecause "I'm not really sure what object you're referring to here, after “{prep}”." }
    }
    method terminate (player) {
        player.complain("You didn't specify a complete object to {verb} {prep}")
    }
}

class prepositionStateForPreposition (prep') forVerb (verb') {
    def prep = prep'
    def verb = verb'
    method accept (word:String) {
        match (word)
            case {"a"|"an"|"the" → state := indirectArticleStateForVerb (verb) andForPreposition (prep)}
            case { "it"|"them"          → 
                if (vocabulary.lastObject ≠ noLastObject) then {
                    state := indirectObjectState (vocabulary.lastObject) forVerb (verb) andForPreposition (prep)
                }
                else {
                    state := rejectStateBecause "That's a bit vague. I don't know what you mean by “{word}”."
                }
            }
            case {_ →
                if (vocabulary.isKnownAdjective(word)) then { 
                    state := indirectAdjectiveState (word) forVerb (verb) andForPreposition (prep)
                }
                elseif (vocabulary.isKnownNoun(word)) then {
                    try {
                        state := indirectObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) andForPreposition (prep)
                    }
                        catch {e → state := rejectStateBecause (e) }
                }
                else {
                    state := rejectStateBecause "You lost me after “{prep}”."
                }
            }
    }
    method terminate (player) {
        player.complain("You seem to have a dangling preposition there.  Try finishing your sentence.")
    }
}

class prepositionStateForPreposition (prep') forVerb (verb') andForObject (dobj') {
    def prep = prep'
    def verb = verb'
    def dobj = dobj'
    method accept (word:String) {
        match (word)
            case {"a"|"an"|"the" → state := indirectArticleStateForVerb (verb) andForPreposition (prep) andForObject (dobj)}
            case {"it"|"them" → state := rejectStateBecause "I think pronouns such as “{word}” are best used for direct objects in the sentence, if it's all the same to you."}
            case {_ → 
                if (vocabulary.isKnownAdjective(word)) then { 
                    state := indirectAdjectiveState (word) forVerb (verb) andForPreposition (prep) andForObject (dobj)
                }
                elseif (vocabulary.isKnownNoun(word)) then {
                    try {
                        state := indirectObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) andForPreposition (prep) andForObject (dobj)
                    }
                        catch {e → state := rejectStateBecause (e) }
                }
                else {
                    state := rejectStateBecause "You lost me after “{prep}”."
                }
            }
    }
    method terminate (player) {
        player.complain("You seem to have a dangling preposition there.  Try finishing your sentence.")
    }
}

class indirectAdjectiveState (adj') forVerb (verb') andForPreposition (prep') andForObject (dobj') {
    def adj = adj'
    def verb = verb'
    def prep = prep'
    def dobj = dobj'
    method accept (word:String) {
        if (vocabulary.isKnownNoun(word)) then {
            try { state := indirectObjectState (vocabulary.resolveNounToObject (word) withAdjective (adj)) forVerb (verb) andForPreposition (prep) andForObject (dobj)}
                catch {e → state := rejectStateBecause (e)}
        }
        else { state := rejectStateBecause "I'm not really sure what object you're trying to {verb} {prep}." }
    }

    method terminate (player) {
        try { 
            state := indirectObjectState (vocabulary.resolveAdjectiveToObject (adj)) forVerb (verb) andForPreposition (prep) andForObject (dobj)
            state.terminate(player)
            vocabulary.lastObjectWas(dobj)
        }
            catch { e → player.complain(e) }
    }
}

class indirectAdjectiveState (adj') forVerb (verb') andForPreposition (prep') {
    def adj = adj'
    def verb = verb'
    def prep = prep'
    method accept (word:String) {
        if (vocabulary.isKnownNoun(word)) then {
            try { state := indirectObjectState (vocabulary.resolveNounToObject (word) withAdjective (adj)) forVerb (verb) andForPreposition (prep) }
                catch {e → state := rejectStateBecause (e)}
        }
        else { state := rejectStateBecause "I'm not really sure what object you're trying to {verb} {prep}." }

    }

    method terminate (player) {
        try { 
            var dobj := vocabulary.resolveAdjectiveToObject(adj)
            state := indirectObjectState (dobj) forVerb (verb) andForPreposition (prep)
            state.terminate(player)
            vocabulary.lastObjectWas(dobj)
        }
            catch { e → player.complain(e) }
    }
}
        
class indirectObjectState (iobj') forVerb (verb') andForPreposition (prep') andForObject (dobj') {
    def iobj = iobj'
    def dobj = dobj'
    def verb = verb'
    def prep = prep'

    method accept (word:String) {
        state := rejectStateBecause "You have extra stuff at the end of the sentence. Try ending it sooner."
    }

    method terminate (player) {
        player.takeAction (verb) on (dobj) indirect (prep) with (iobj)
        vocabulary.lastObjectWas(dobj)
    }
}
        
class indirectObjectState (iobj') forVerb (verb') andForPreposition (prep') {
    def iobj = iobj'
    def verb = verb'
    def prep = prep'

    method accept (word:String) {
        state := rejectStateBecause "You have extra stuff at the end of the sentence. Try ending it sooner."
    }

    method terminate (player) {
        player.takeAction (verb) indirect (prep) with (iobj)
        vocabulary.lastObjectWas(iobj)
    }
}
        

class adjectiveState (adj') forVerb (verb') {
    def verb = verb'
    def adj = adj'
    method accept (word:String) {
        match (word)
            case { "with"|"on"|"off"|"onto"|"into"|"in" → 
                try { state := prepositionStateForPreposition (word) forVerb (verb) andForObject (vocabulary.resolveAdjectiveToObject (adj)) }
                    catch {e → state := rejectStateBecause (e)}
            }
            case { _ →
                if (vocabulary.isKnownNoun(word)) then { 
                    try { state := directObjectState (vocabulary.resolveNounToObject (word) withAdjective (adj)) forVerb (verb) }
                        catch { e → state := rejectStateBecause (e) }
                }
                else { state := rejectStateBecause "I'm not really sure what object you're referring to here." }
            }
    }
    method terminate (player) {
        try { 
            var dobj := vocabulary.resolveAdjectiveToObject(adj)
            state := directObjectState (dobj) forVerb (verb) 
            state.terminate(player)
            vocabulary.lastObjectWas(dobj)
        }
            catch { e → player.complain(e) }
    }
}

class directObjectState (theObject') forVerb (verb') {
    def verb = verb'
    def theObject = theObject'
    method accept (word:String) { 
        match (word)
            case {"with"|"in"|"into"|"onto"|"on"|"off" → state := prepositionStateForPreposition (word) forVerb (verb) andForObject (theObject)}
            case {_                    → state := rejectStateBecause "You put extra words after the object of your sentence." }
    }
    method terminate (player) {
        player.takeAction (verb) on (theObject)
        vocabulary.lastObjectWas(theObject)
    }
}

def quitState = object {
    method accept (word:String) {
        state := rejectStateBecause(‹I don't understand. You seem to have extra words at the end of that sentence
that aren't necessary.  To quit the game, just type “quit” by itself.›)
    }
    method terminate (player) {
        player.quit
    }
}

class verbStateForVerb (verb') {
    def verb = verb'
    method accept (word:String) {
        match (word) 
            case { "a"|"an"|"the"       → state := articleStateForVerb (verb) }
            case { "with"|"onto"|"in"|"into"|"on"|"off" → state := prepositionStateForPreposition (word) forVerb (verb) }
            case { "it"|"them"          → 
                if (vocabulary.lastObject ≠ noLastObject) then {
                    state := directObjectState (vocabulary.lastObject) forVerb (verb)
                }
                else {
                    state := rejectStateBecause "That's a bit vague. I don't know what you mean by “{word}”."
                }
            }
            case { _ →
                if (vocabulary.isKnownAdjective(word)) then { state := adjectiveState (word) forVerb (verb) }
                elseif (vocabulary.isKnownNoun(word)) then { 
                    try { state := directObjectState (vocabulary.resolveNounToObject(word)) forVerb (verb) }
                        catch { e → state := rejectStateBecause (e) }
                }
                else { state := rejectStateBecause "I'm not really sure what object you're referring to here." }
            }
    }
    method terminate (player) {
        player.takeAction(verb)
        vocabulary.lastObjectWas(noLastObject)
    }
}

class rejectStateBecause (reason') {
    def reason = reason'
    method accept (word:String) {}
    method terminate (player) {
        player.complain(reason)
    }
}

// the C version of the Grace string library lacks asUpper, asLower, map, trim, substring, etc., etc.
// so we have to do this the hard way...

method trimLeadingSpace (in:String) {
    var out := ""
    var leading := true
    for (1..(in.size)) do { i →
        if (leading.not || (in[i] ≠ " ")) then {
            out := out ++ in[i]
            leading := false
        }
    }
    out
}

method breakOutNextWord (in:String) {
    var out := ""
    for (1..(in.size)) do { i →
        if (in[i] == " ") then {
            return out
        }
        out := out ++ in[i]
    }
    out
}

method removeLeading (n) charactersFrom (in:String) {
    var out := ""
    for ((n+1)..(in.size)) do { i →
        out := out ++ in[i]
    }
    out
}

method asLower (s:String) {
    var newValue := ""
    for (1..(s.size)) do { i →
        if ((s[i].ord ≥ "A".ord) && (s[i].ord ≤ "Z".ord)) then {
            newValue := newValue ++ (unicode.create(s[i].ord + 32))
        }
        else {
            newValue := newValue ++ s[i]
        }
    }
    newValue
}

method parse (input:String) forPlayer (player) {
    var inputRemaining := asLower(input)

    while {inputRemaining.size > 0} do {
        inputRemaining := trimLeadingSpace(inputRemaining)
        if (inputRemaining.size > 0) then {
            var currentWord := breakOutNextWord(inputRemaining)
            inputRemaining := removeLeading (currentWord.size) charactersFrom (inputRemaining)
            if (currentWord.size > 0) then {
                state.accept(currentWord)
            }
        }
    }
    state.terminate(player)
    state := startState
}
