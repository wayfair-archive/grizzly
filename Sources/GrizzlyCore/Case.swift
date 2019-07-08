//
// This source file is part of Grizzly, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

import Parsers
import Prelude

/*
 Test Case '-[ModelsTests.AddressTest testExample]' started.
 Test Case '-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]' started.
 */
public struct CaseStarted {
    public let name: String
}

let parseCaseStarted = pure(CaseStarted.init)
    <* stringIgnoringTrailingWhitespace("Test Case")
    <*> parseQuotedName
    <* stringIgnoringTrailingWhitespace("started")

/*
 Test Case '-[ModelsTests.AddressTest testExample]' passed (0.026 seconds).
 Test Case '-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]' passed (0.002 seconds).
 */
public struct CaseCompleted {
    public let elapsed: Double
    public let name: String
    public let passed: Bool
}

private extension CaseCompleted {
    /// convenience `init` with the arguments in a different order; used in the parser below
    init(_ name: String, _ passed: Bool, _ elapsed: Double) {
        self.init(elapsed: elapsed, name: name, passed: passed)
    }
}

let parseElapsed: StringParser<Double> = (
    double <* whitespace.zeroOrMore <* stringIgnoringTrailingWhitespace("seconds")
    ).between(string("("), string(")"))

let parseCaseCompleted = stringIgnoringTrailingWhitespace("Test Case")
    *> liftA(CaseCompleted.init, parseQuotedName, parsePassed, parseElapsed)
