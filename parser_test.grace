//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Parser module test cases
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

    }
}

gu.testSuite.fromTestMethodsIn(parserTest).runAndPrintResults
