//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Room class test cases
//

import "gUnit" as gu
import "rooms" as rooms

def roomTest = object {
    class forMethod(m) {
        inherits gu.testCaseNamed(m)

        method testBasicDirections {
            def r = object {
                inherit rooms.Room
                method destinationFrom (direction) {
                    match (direction)
                        case { "north" -> s }
                        case { _ -> rooms.noExit }
                }
            }
            def s = object {
                inherit rooms.Room
                method destinationFrom (direction) {
                    match (direction) 
                        case { "south" -> r }
                        case { _ -> rooms.noExit }
                }
            }
            def t = object {
                inherit rooms.Room
            }

            assert (r.destinationFrom("north")) shouldBe (s)
            assert (r.destinationFrom("south")) shouldBe (rooms.noExit)
            assert (s.destinationFrom("north")) shouldBe (rooms.noExit)
            assert (s.destinationFrom("south")) shouldBe (r)
            assert (t.destinationFrom("south")) shouldBe (rooms.noExit)
            assert (t.destinationFrom("up")) shouldBe (rooms.noExit)
            assert (t.destinationFrom("down")) shouldBe (rooms.noExit)
        }

        method testDefaultRoom {
            def r = rooms.Room
            assert (r.canMoveHere) shouldBe (true)
            assert (r.destinationFrom("north")) shouldBe (rooms.noExit)
            assert (r.destinationFrom("south")) shouldBe (rooms.noExit)
            assert (r.destinationFrom("east")) shouldBe (rooms.noExit)
            assert (r.destinationFrom("west")) shouldBe (rooms.noExit)
            assert (r.destinationFrom("up")) shouldBe (rooms.noExit)
            assert (r.destinationFrom("down")) shouldBe (rooms.noExit)
        }

        method testMoveToNowhere {
            def r = rooms.noExit
            assert (r.canMoveHere) shouldBe (false)
        }
    }
}

gu.testSuite.fromTestMethodsIn(roomTest).runAndPrintResults
