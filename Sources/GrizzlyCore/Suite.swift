//
// This source file is part of Grizzly, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

import Foundation
import Parsers
import Prelude

/*
 Test Suite 'AddressTest' passed at 2018-03-19 14:46:47.403.
 Test Suite 'AttributeOptionTest' passed at 2018-03-19 14:46:47.406.
 */
public struct SuiteCompleted {
    public let name: String
    public let passed: Bool
    public let endedAt: Date
}

let parseSuiteCompleted = stringIgnoringTrailingWhitespace("Test Suite")
    *> liftA(
        SuiteCompleted.init, 
        parseQuotedName, 
        parsePassed <* stringIgnoringTrailingWhitespace("at"), 
        parseDate)

/*
 Test Suite 'All tests' started at 2018-03-19 14:46:47.375
 Test Suite 'ModelsTests.xctest' started at 2018-03-19 14:46:47.375
 Test Suite 'AddressTest' started at 2018-03-19 14:46:47.376
 Test Suite 'AttributeOptionTest' started at 2018-03-19 14:46:47.404
 */
public struct SuiteStarted {
    public let name: String
    public let startedAt: Date
}

let parseSuiteStarted = stringIgnoringTrailingWhitespace("Test Suite")
    *> liftA(
        SuiteStarted.init,
        parseQuotedName <* stringIgnoringTrailingWhitespace("started") <* stringIgnoringTrailingWhitespace("at"),
        parseDate)
