//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo project 
// Steve Willoughby, CS 420, Portland State University, Spring 2016
// Formatting module test cases
//

import "gUnit" as gu
import "formatting" as fmt

def fmtTest = object {
    class forMethod(m) {
        inherits gu.testCaseNamed(m)

        method testColors {
            assert (fmt.style.render("RED!")as("31")) shouldBe ("\u001b[31mRED!\u001b[0m")
            assert (fmt.style.render("BOLD!")as("1")) shouldBe ("\u001b[1mBOLD!\u001b[0m")
        }

        method testInhibitColors {
            fmt.switchToPlainStyle
            assert (fmt.style.render("RED!")as("31")) shouldBe ("RED!")
            assert (fmt.style.render("BOLD!")as("1")) shouldBe ("BOLD!")
            fmt.switchToFancyStyle
            assert (fmt.style.render("RED!")as("31")) shouldBe ("\u001b[31mRED!\u001b[0m")
        }

        method testPartial {
            assert (fmt.style.enter("44;33")with("xxx")++"yyy"++fmt.style.exit) shouldBe ("\u001b[44;33mxxxyyy\u001b[0m")
            assert (fmt.style.enter("5;1;4")++"zzz") shouldBe ("\u001b[5;1;4mzzz")
        }

    }
}

gu.testSuite.fromTestMethodsIn(fmtTest).runAndPrintResults
