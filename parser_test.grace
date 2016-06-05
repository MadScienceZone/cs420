// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- parser test cases
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
//

import "gUnit" as gu
import "parser" as parser

def parserTest = object {
    class forMethod(m) {
        inherits gu.testCaseNamed(m)

        method testTrim {
            assert(parser.trimLeadingSpace("   hello")) shouldBe ("hello")
            assert(parser.trimLeadingSpace("hello")) shouldBe ("hello")
            assert(parser.trimLeadingSpace("hello   ")) shouldBe ("hello   ")
            assert(parser.trimLeadingSpace("   hello   ")) shouldBe ("hello   ")
            assert(parser.trimLeadingSpace("   hello world   ")) shouldBe ("hello world   ")
        }

        method testBreakOut {
            assert(parser.breakOutNextWord("a b c")) shouldBe ("a")
            assert(parser.breakOutNextWord("magic word xyxzzy")) shouldBe ("magic")
            assert(parser.breakOutNextWord(" magic word")) shouldBe ("")
            assert(parser.breakOutNextWord("  ")) shouldBe ("")
            assert(parser.breakOutNextWord("")) shouldBe ("")
        }

        method testRemoveLeading {
            assert(parser.removeLeading (1) charactersFrom ("xyzzy")) shouldBe ("yzzy")
            assert(parser.removeLeading (3) charactersFrom ("xyzzy")) shouldBe ("zy")
            assert(parser.removeLeading (5) charactersFrom ("xyzzy")) shouldBe ("")
            assert(parser.removeLeading (10) charactersFrom ("xyzzy")) shouldBe ("")
        }

        method testAsLower {
            assert(parser.asLower ("HeLlOWorLD")) shouldBe "helloworld"
            assert(parser.asLower ("éÉHeLlOWorLD")) shouldBe "éÉhelloworld"
        }

        method testNonsense {
            def me = object {
                var error is readable := ""
                method complain (message) {
                    error := message
                }
            }
                    
            parser.parse("magic word xyzzy")forPlayer(me)
            assert(me.error) shouldBe ("I have no idea what you mean by “magic”.")
        }

        method testSimpleVerbs {
            def me = object {
                var error is readable := ""
                var verb is readable := ""
                method complain (message) {
                    error := message
                }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
            }
            parser.parse("quit") forPlayer(me)
            assert (me.verb) shouldBe "◊quit"
            parser.parse("HELP") forPlayer(me)
            assert (me.error) shouldBe ‹Helpful Hints:
To move around, type compass directions such as GO NORTH, GO SOUTH, etc.
To see your progress, type SCORE.
To give up entirely, type QUIT.
Most commands can be abbreviated in reasonably obvious ways.
Good Luck!›
            parser.parse("Inventory") forPlayer(me)
            assert (me.verb) shouldBe "inventory"
            parser.parse("examine") forPlayer(me)
            assert (me.verb) shouldBe "examine"
            parser.parse("take") forPlayer(me)
            assert (me.verb) shouldBe "take"
            parser.parse("get") forPlayer(me)
            assert (me.verb) shouldBe "take"
            parser.parse("drop") forPlayer(me)
            assert (me.verb) shouldBe "drop"
            parser.parse("score") forPlayer(me)
            assert (me.verb) shouldBe "score"
        }
        method testDirections {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method moveDirection (dir) { verb := "dir◊"++dir }
            }

            parser.parse "go" forPlayer(me)
            assert(me.verb) shouldBe "err◊Which direction do you want to move?"
            parser.parse "MOVE" forPlayer(me)
            assert(me.verb) shouldBe "err◊Which direction do you want to move?"
            parser.parse "MOVE TO" forPlayer(me)
            assert(me.verb) shouldBe "err◊Which direction do you want to move?"
            parser.parse "MOVE TO SOUTH" forPlayer(me)
            assert(me.verb) shouldBe "dir◊south"
            parser.parse "MOVE TO THE WEST" forPlayer(me)
            assert(me.verb) shouldBe "dir◊west"
            parser.parse "MOVE EAST" forPlayer(me)
            assert(me.verb) shouldBe "dir◊east"
            parser.parse "WEST" forPlayer(me)
            assert(me.verb) shouldBe "dir◊west"
        }

        method testLooks {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method moveDirection (dir) { verb := "dir◊"++dir }
                method look { verb := "◊look" }
            }

            parser.parse "LOOK" forPlayer(me)
            assert(me.verb) shouldBe "◊look"
            parser.parse "LOOK AT" forPlayer(me)
            assert(me.verb) shouldBe "examine"
            parser.parse "LOOK AT OBJECT" forPlayer(me)
            assert(me.verb) shouldBe "err◊I'm not really sure what object you're referring to here."
        }

        method testNull {
            def me = object {}      // should be NO method calls at all into me
            assert({parser.parse "" forPlayer (me)}) shouldntRaise (Exception)
        }

        method testVerbObject {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method takeAction (verb') on (dobj) { verb := "VO◊"++verb'++"◊"++(dobj.name) }
                method moveDirection (dir) { verb := "dir◊"++dir }
                method look { verb := "◊look" }
            }
            def obj  = object { 
                def name is readable = "#red obj" 
                method shortDescription { "red object" }
            }
            def obj2 = object { 
                def name is readable = "#blue obj" 
                method shortDescription { "blue object" }
            }
            def obj3 = object { 
                def name is readable = "#red thing" 
                method shortDescription { "red thing" }
            }
            def obj4 = object { 
                def name is readable = "#the cat" 
                method shortDescription { "cat" }
            }
            parser.vocabulary.clear
            parser.vocabulary.addNoun "object" withAdjective "red" forObject (obj)
            parser.vocabulary.addNoun "object" withAdjective "blue" forObject (obj2)
            parser.vocabulary.addNoun "thing" withAdjective "red" forObject (obj3)
            parser.vocabulary.addNoun "cat" forObject (obj4)
            parser.vocabulary.addVerb "frob"
            parser.parse "LOOK AT Object" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which object are you referring to?"
            parser.parse "LOOK AT THE RED OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VO◊examine◊#red obj"
            parser.parse "LOOK AT BLUE OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VO◊examine◊#blue obj"
            parser.parse "LOOK AT THE THING" forPlayer (me)
            assert (me.verb) shouldBe "VO◊examine◊#red thing"
            parser.parse "LOOK AT BLUE" forPlayer (me)
            assert (me.verb) shouldBe "VO◊examine◊#blue obj"
            parser.parse "LOOK AT RED" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which red thing are you referring to?"
            parser.parse "LOOK AT RED CAT" forPlayer (me)
            assert (me.verb) shouldBe "err◊no such noun: I don't see any red cat here."
            parser.parse "LOOK AT THE CAT" forPlayer (me)
            assert (me.verb) shouldBe "VO◊examine◊#the cat"
            parser.parse "FROB THE RED THING" forPlayer (me)
            assert (me.verb) shouldBe "VO◊frob◊#red thing"
            parser.parse "FROB A" forPlayer (me)
            assert (me.verb) shouldBe "err◊You didn't specify a complete object to frob"
        }

        method testVerbIndirectObject {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method takeAction (verb') on (dobj) { verb := "VO◊"++verb'++"◊"++(dobj.name) }
                method takeAction (verb') indirect (prep) with (iobj) { verb := "VPO◊"++verb'++"◊"++prep++"◊"++(iobj.name) }
                method moveDirection (dir) { verb := "dir◊"++dir }
                method look { verb := "◊look" }
            }
            def obj  = object { 
                def name is readable = "#red obj" 
                method shortDescription { "red object" }
            }
            def obj2 = object { 
                def name is readable = "#blue obj" 
                method shortDescription { "blue object" }
            }
            def obj3 = object { 
                def name is readable = "#red thing" 
                method shortDescription { "red thing" }
            }
            def obj4 = object { 
                def name is readable = "#the cat" 
                method shortDescription { "cat" }
            }
            parser.vocabulary.clear
            parser.vocabulary.addNoun "object" withAdjective "red" forObject (obj)
            parser.vocabulary.addNoun "object" withAdjective "blue" forObject (obj2)
            parser.vocabulary.addNoun "thing" withAdjective "red" forObject (obj3)
            parser.vocabulary.addNoun "cat" forObject (obj4)
            parser.vocabulary.addVerb "frob"
            parser.parse "FROB WITH Object" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which object are you referring to?"
            parser.parse "FROB WITH THE RED OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VPO◊frob◊with◊#red obj"
            parser.parse "FROB WITH BLUE OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VPO◊frob◊with◊#blue obj"
            parser.parse "FROB WITH THE THING" forPlayer (me)
            assert (me.verb) shouldBe "VPO◊frob◊with◊#red thing"
            parser.parse "FROB WITH BLUE" forPlayer (me)
            assert (me.verb) shouldBe "VPO◊frob◊with◊#blue obj"
            parser.parse "FROB WITH RED" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which red thing are you referring to?"
            parser.parse "FROB WITH RED CAT" forPlayer (me)
            assert (me.verb) shouldBe "err◊no such noun: I don't see any red cat here."
            parser.parse "FROB WITH THE CAT" forPlayer (me)
            assert (me.verb) shouldBe "VPO◊frob◊with◊#the cat"
            parser.parse "FROB WITH A" forPlayer (me)
            assert (me.verb) shouldBe "err◊You didn't specify a complete object to frob with"
        }

        method testVerbObjectIndirectObject {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method takeAction (verb') on (dobj) { verb := "VO◊"++verb'++"◊"++(dobj.name) }
                method takeAction (verb') indirect (prep) with (iobj) { verb := "VPO◊"++verb'++"◊"++prep++"◊"++(iobj.name) }
                method takeAction (verb') on (dobj) indirect (prep) with (iobj) { 
                    verb := "VOPO◊"++verb'++"◊"++(dobj.name)++"◊"++prep++"◊"++(iobj.name) 
                }
                method moveDirection (dir) { verb := "dir◊"++dir }
                method look { verb := "◊look" }
            }
            def obj  = object { 
                def name is readable = "#red obj" 
                method shortDescription { "red object" }
            }
            def obj2 = object { 
                def name is readable = "#blue obj" 
                method shortDescription { "blue object" }
            }
            def obj3 = object { 
                def name is readable = "#red thing" 
                method shortDescription { "red thing" }
            }
            def obj4 = object { 
                def name is readable = "#the cat" 
                method shortDescription { "cat" }
            }
            parser.vocabulary.clear
            parser.vocabulary.addNoun "object" withAdjective "red" forObject (obj)
            parser.vocabulary.addNoun "object" withAdjective "blue" forObject (obj2)
            parser.vocabulary.addNoun "thing" withAdjective "red" forObject (obj3)
            parser.vocabulary.addNoun "cat" forObject (obj4)
            parser.vocabulary.addVerb "frob"
            parser.parse "FROB THING WITH Object" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which object are you referring to?"
            parser.parse "FROB A THING WITH THE RED OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VOPO◊frob◊#red thing◊with◊#red obj"
            parser.parse "FROB A THING WITH BLUE OBJECT" forPlayer (me)
            assert (me.verb) shouldBe "VOPO◊frob◊#red thing◊with◊#blue obj"
            parser.parse "FROB THE CAT WITH THE THING" forPlayer (me)
            assert (me.verb) shouldBe "VOPO◊frob◊#the cat◊with◊#red thing"
            parser.parse "FROB THE CAT WITH BLUE" forPlayer (me)
            assert (me.verb) shouldBe "VOPO◊frob◊#the cat◊with◊#blue obj"
            parser.parse "FROB A CAT WITH RED" forPlayer (me)
            assert (me.verb) shouldBe "err◊ambiguous noun: Which red thing are you referring to?"
            parser.parse "FROB A CAT WITH RED CAT" forPlayer (me)
            assert (me.verb) shouldBe "err◊no such noun: I don't see any red cat here."
            parser.parse "FROB A BLUE OBJECT WITH THE CAT" forPlayer (me)
            assert (me.verb) shouldBe "VOPO◊frob◊#blue obj◊with◊#the cat"
            parser.parse "FROB THING WITH A" forPlayer (me)
            assert (me.verb) shouldBe "err◊You didn't specify a complete object to frob with"
        }

        method testPickUpPutDown {
            def me = object {
                var verb is readable := ""
                method complain (message) { verb := "err◊"++message }
                method quit { verb := "◊quit" }
                method takeAction (verb') { verb := verb' }
                method takeAction (verb') on (dobj) { verb := "VO◊"++verb'++"◊"++(dobj.name) }
                method takeAction (verb') indirect (prep) with (iobj) { verb := "VPO◊"++verb'++"◊"++prep++"◊"++(iobj.name) }
                method takeAction (verb') on (dobj) indirect (prep) with (iobj) { 
                    verb := "VOPO◊"++verb'++"◊"++(dobj.name)++"◊"++prep++"◊"++(iobj.name) 
                }
                method moveDirection (dir) { verb := "dir◊"++dir }
                method look { verb := "◊look" }
            }
            def obj  = object { 
                def name is readable = "#red obj" 
                method shortDescription { "red object" }
            }
            def obj2 = object { 
                def name is readable = "#blue obj" 
                method shortDescription { "blue object" }
            }
            def obj3 = object { 
                def name is readable = "#red thing" 
                method shortDescription { "red thing" }
            }
            def obj4 = object { 
                def name is readable = "#the cat" 
                method shortDescription { "cat" }
            }
            parser.vocabulary.clear
            parser.vocabulary.addNoun "object" withAdjective "red" forObject (obj)
            parser.vocabulary.addNoun "object" withAdjective "blue" forObject (obj2)
            parser.vocabulary.addNoun "thing" withAdjective "red" forObject (obj3)
            parser.vocabulary.addNoun "cat" forObject (obj4)

            parser.parse "PICK THE RED OBJECT" forPlayer(me)
            assert (me.verb) shouldBe "VO◊pick◊#red obj"
            parser.parse "PICK UP THE RED OBJECT" forPlayer(me)
            assert (me.verb) shouldBe "VO◊take◊#red obj"
            parser.parse "PUT THE RED OBJECT" forPlayer(me)
            assert (me.verb) shouldBe "VO◊put◊#red obj"
            parser.parse "PUT DOWN THE RED OBJECT" forPlayer(me)
            assert (me.verb) shouldBe "VO◊drop◊#red obj"
            parser.parse "PICK IT UP" forPlayer(me)
            assert (me.verb) shouldBe "VO◊take◊#red obj"
            parser.parse "PUT IT DOWN" forPlayer(me)
            assert (me.verb) shouldBe "VO◊drop◊#red obj"
        }
    }
}

gu.testSuite.fromTestMethodsIn(parserTest).runAndPrintResults
