//
// This source file is part of Grizzly, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

@testable import GrizzlyCore
import Parsers
import XCTest

class DataTests: XCTestCase {
    func parseDateString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        return formatter.date(from: dateString)
    }

    func testSuiteStartedParser() {
        assertSucceeds(parseSuiteStarted, forInput: "Test Suite 'All tests' started at 2018-03-19 14:46:47.375") { tuple in
            XCTAssertEqual("All tests", tuple.0.name)
            XCTAssertEqual(parseDateString("2018-03-19 14:46:47.375")!, tuple.0.startedAt)
            XCTAssertEqual("", tuple.1)
        }
        assertSucceeds(parseSuiteStarted, forInput: "Test Suite 'ModelsTests.xctest' started at 2018-03-19 14:46:47.375") { tuple in
            XCTAssertEqual("ModelsTests.xctest", tuple.0.name)
            XCTAssertEqual(parseDateString("2018-03-19 14:46:47.375")!, tuple.0.startedAt)
            XCTAssertEqual("", tuple.1)
        }
        assertSucceeds(parseSuiteStarted, forInput: "Test Suite 'AddressTest' started at 2018-03-19 14:46:47.376") { tuple in
            XCTAssertEqual("AddressTest", tuple.0.name)
            XCTAssertEqual(parseDateString("2018-03-19 14:46:47.376")!, tuple.0.startedAt)
            XCTAssertEqual("", tuple.1)
        }
        assertSucceeds(parseSuiteStarted, forInput: "Test Suite 'AttributeOptionTest' started at 2018-03-19 14:46:47.404") { tuple in
            XCTAssertEqual("AttributeOptionTest", tuple.0.name)
            XCTAssertEqual(parseDateString("2018-03-19 14:46:47.404")!, tuple.0.startedAt)
            XCTAssertEqual("", tuple.1)
        }
    }

    func testSuiteCompletedParser() {
        assertSucceeds(parseSuiteCompleted, forInput: "Test Suite 'AddressTest' passed at 2018-03-19 14:46:47.403.") { tuple in
            XCTAssertEqual("AddressTest", tuple.0.name)
            XCTAssertEqual(true, tuple.0.passed)
            XCTAssertEqual(1521485207.403, tuple.0.endedAt.timeIntervalSince1970)
            XCTAssertEqual(".", tuple.1)
        }
        assertSucceeds(parseSuiteCompleted, forInput: "Test Suite 'AttributeOptionTest' passed at 2018-03-19 14:46:47.406.") { tuple in
            XCTAssertEqual("AttributeOptionTest", tuple.0.name)
            XCTAssertEqual(true, tuple.0.passed)
            XCTAssertEqual(1521485207.406, tuple.0.endedAt.timeIntervalSince1970)
            XCTAssertEqual(".", tuple.1)
        }
        assertSucceeds(parseSuiteCompleted, forInput: "Test Suite 'BadTests' failed at 2018-03-19 14:46:47.406.") { tuple in
            XCTAssertEqual("BadTests", tuple.0.name)
            XCTAssertEqual(false, tuple.0.passed)
            XCTAssertEqual(1521485207.406, tuple.0.endedAt.timeIntervalSince1970)
            XCTAssertEqual(".", tuple.1)
        }
    }

    func testCaseStartedParser() {
        assertSucceeds(parseCaseStarted, forInput: "Test Case '-[ModelsTests.AddressTest testExample]' started.") { tuple in
            XCTAssertEqual("-[ModelsTests.AddressTest testExample]", tuple.0.name)
            XCTAssertEqual(".", tuple.1)
        }
        assertSucceeds(parseCaseStarted, forInput: "Test Case '-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]' started.") { tuple in
            XCTAssertEqual("-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]", tuple.0.name)
            XCTAssertEqual(".", tuple.1)
        }
    }

    func testCaseCompletedParser() {
        assertSucceeds(parseCaseCompleted, forInput: "Test Case '-[ModelsTests.AddressTest testExample]' passed (0.026 seconds).") { tuple in
            XCTAssertEqual("-[ModelsTests.AddressTest testExample]", tuple.0.name)
            XCTAssertEqual(true, tuple.0.passed)
            XCTAssertEqual(0.026, tuple.0.elapsed)
            XCTAssertEqual(".", tuple.1)
        }
        assertSucceeds(parseCaseCompleted, forInput: "Test Case '-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]' passed (0.002 seconds).") { tuple in
            XCTAssertEqual("-[ModelsTests.AttributeOptionTest testAttributeOptionUnbox]", tuple.0.name)
            XCTAssertEqual(true, tuple.0.passed)
            XCTAssertEqual(0.002, tuple.0.elapsed)
            XCTAssertEqual(".", tuple.1)
        }
    }
}

func assertSucceeds<A>(
    _ parser: StringParser<A>,
    forInput input: String,
    file: StaticString = #file,
    line: UInt = #line,
    outputWas callback: ((A, String)) -> Void = { _ in }) {
    do {
        let output = try parser.run(input)
        callback(output)
    } catch {
        XCTFail("failed parsing: \(input) with error: \(error)", file: file, line: line)
    }
}

func assertFails<A>(
    _ parser: StringParser<A>,
    forInput input: String,
    file: StaticString = #file,
    line: UInt = #line,
    errorWas callback: (Error) -> Void = { _ in }) {
    do {
        let output = try parser.run(input)
        XCTFail("Did not fail parsing as expected for: \(input), got: \(output)", file: file, line: line)
    } catch {
        callback(error)
    }
}
