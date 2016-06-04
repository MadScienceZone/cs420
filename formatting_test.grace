//
// vi:set ai sm nu ts=4 sw=4 expandtab:
//
// Interactive Fiction demo program -- formatting test cases
// CS 420 term project to demonstrate an object-oriented parser design
// Steve Willoughby, Portland State University, Spring 2016
//
// ©2016 Steven L. Willoughby, All Rights Reserved. May be distributed and used
// under the terms of the Simplified (2-clause) BSD open-source license (See the
// LICENSE file for details.)
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
