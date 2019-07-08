//
// This source file is part of Grizzly, an open source project by Wayfair
//
// Copyright (c) 2019 Wayfair, LLC.
// Licensed under the 2-Clause BSD License
//
// See LICENSE.md for license information
//

import Foundation
import GrizzlyCore
import Parsers

final class MyLoggerDelegate: GrizzlyRunnerDelegate {
    private var caseResults: [CaseCompleted]!

    func onFoundSuiteStarted(_ suiteStarted: SuiteStarted) {
    }

    func onFoundSuiteCompleted(_ suiteCompleted: SuiteCompleted) {
    }

    func onFoundCaseStarted(_ caseStarted: CaseStarted) {
    }

    func onFoundCaseCompleted(_ caseCompleted: CaseCompleted) {
        caseResults.append(caseCompleted)

        if !caseCompleted.passed {
            print("\(caseCompleted.name) failed!")
        }
        if caseCompleted.elapsed > 0.5 {
            let resultText = caseCompleted.passed ? "passed" : "failed"
            print("\(caseCompleted.name) \(resultText) and was slow: \(caseCompleted.elapsed)")
        }
    }

    func onBeforeParseRunStarted() {
        caseResults = []
    }

    func onAfterParseRunCompleted(_ error: ParseError?) {
        let sortedCaseResults = caseResults.sorted { $0.elapsed > $1.elapsed }
        let n = 20
        print("top \(n) slowest tests:")
        for caseResult in sortedCaseResults.prefix(n) {
            let resultText = caseResult.passed ? "passed" : "failed"
            print("\(caseResult.name) [\(resultText)], elapsed: \(caseResult.elapsed)")
        }
    }
}

// MARK: - main

let options = ProcessInfo.processInfo.grizzlyOptions
//print("json flag: \(options.outputJSON)") // TODO: plug in a different delegate below for JSON output (also implement JSON)

let delegate = MyLoggerDelegate()
let runner = GrizzlyRunner(delegate: delegate)
runner.run()
