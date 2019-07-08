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

// MARK: - shared

/// date formatter matching the format of dates output by `xcodebuild`
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
}()

private func digits(_ n: Int) -> StringParser<[Character]> {
    return oneOf("0123456789").repeated(n)
}

private let parseDateFormat: StringParser<[Character]> = (
    digits(4)
        <> oneOf("-").once
        <> digits(2)
        <> oneOf("-").once
        <> digits(2)
        <> oneOf(" ").once
        <> digits(2)
        <> oneOf(":").once
        <> digits(2)
        <> oneOf(":").once
        <> digits(2)
        <> oneOf(".").once
        <> digits(3)
)

/// parser for parsing `xcodebuild`-format dates
let parseDate: StringParser<Date> = parseDateFormat.flatMap { chars in
    .init { stream in
        guard let dateValue = dateFormatter.date(from: String(chars)) else {
            let message = "parse failed, constructing a `Date` from the `String` “\(String(chars))” did not succeed"
            throw ParseError(message)
        }
        return (dateValue, stream)
    }
}

/// parser that turns the string “passed” (as in, “test case X passed”) into `true` and anything else into `false`
let parsePassed: StringParser<Bool> = stringIgnoringTrailingWhitespace("passed").asTrue <|> stringIgnoringTrailingWhitespace("failed").asFalse

/// TODO: this is bad
let parseQuotedName: StringParser<String> =
    string("'") *> noneOf("'").zeroOrMore.map { String($0) } <* string("'") <* whitespace.zeroOrMore

// MARK: - parser runner delegate

/// delegate protocol for the Grizzly parser runner. Conform to this protocol and assign yourself as the `delegate` of the `GrizzlyRunner` to receive data as the parser parses it from the stream
public protocol GrizzlyRunnerDelegate: class {

    // MARK: - data

    /// delegate callback for when the parser successfully parses a “suite started” line of data
    ///
    /// - Parameter suiteStarted: a `SuiteStarted` struct
    func onFoundSuiteStarted(_ suiteStarted: SuiteStarted)

    /// delegate callback for when the parser successfully parses a “suite completed” line of data
    ///
    /// - Parameter suiteCompleted: a `SuiteCompleted` struct
    func onFoundSuiteCompleted(_ suiteCompleted: SuiteCompleted)

    /// delegate callback for when the parser successfully parses a “case started” line of data
    ///
    /// - Parameter caseStarted: a `CaseStarted` struct
    func onFoundCaseStarted(_ caseStarted: CaseStarted)

    /// delegate callback for when the parser successfully parses a “case completed” line of data
    ///
    /// - Parameter caseCompleted: a `CaseCompleted` struct
    func onFoundCaseCompleted(_ caseCompleted: CaseCompleted)

    // MARK: - other events

    /// delegate callback called just before the parser runner begins parsing from the stream
    func onBeforeParseRunStarted()

    /// delegate callback called just after the parser finishes parsing the stream (eg. EOF)
    ///
    /// - Parameter error: if parsing completed successfully, this parameter will be `nil`. Otherwise, the runner will return the `ParseError` that caused parsing to terminate
    func onAfterParseRunCompleted(_ error: ParseError?)
}

// MARK: - parser runner

/// “runner” class for the Grizzly parser. To perform analysis with the parser, implement a `GrizzlyRunnerDelegate` that performs the desired calculations, connect it to this object’s `delegate`, and `GrizzlyRunner.run()` the runner
public final class GrizzlyRunner {
    public weak var delegate: GrizzlyRunnerDelegate?

    public init(delegate: GrizzlyRunnerDelegate?) {
        self.delegate = delegate
    }

    /// run this `GrizzlyRunner`. For the moment, this method will consume text from standard input until EOF is reached, calling this instance’s `delegate` as data is successfully parsed
    public func run() {
        delegate?.onBeforeParseRunStarted()
        while let line = readLine() { // TODO: parser should actually be multi-line
            runLine(line)
        }
        delegate?.onAfterParseRunCompleted(nil)
    }

    func runLine(_ line: String) {
         // TODO: move to plain `try` here, returning any error to the `delegate`, once we have a catch-all parser
        if let (logLine, _) = try? GrizzlyLogLine.parser.run(line) {
            switch logLine {
            case .suiteStarted(let suiteStarted):
                delegate?.onFoundSuiteStarted(suiteStarted)
            case .suiteCompleted(let suiteCompleted):
                delegate?.onFoundSuiteCompleted(suiteCompleted)
            case .caseStarted(let caseStarted):
                delegate?.onFoundCaseStarted(caseStarted)
            case .caseCompleted(let caseCompleted):
                delegate?.onFoundCaseCompleted(caseCompleted)
            }
        }
    }
}

// MARK: - top-level data type

/// `enum` to lift all the different structs we are interested in into the same data type so that consumers can switch on parser results
///
/// - suiteStarted: contains a `SuiteStarted` struct
/// - suiteCompleted: contains a `SuiteCompleted` struct
/// - caseStarted: contains a `CaseStarted` struct
/// - caseCompleted: contains a `CaseCompleted` struct
private enum GrizzlyLogLine {
    case suiteStarted(SuiteStarted)
    case suiteCompleted(SuiteCompleted)
    case caseStarted(CaseStarted)
    case caseCompleted(CaseCompleted)
}

// MARK: - top-level parser

extension GrizzlyLogLine {
    /// the “top-level” `GrizzlyLogLine` parser. Uses the `Parser` `<|>` (“choice”) operator to try the available parsers in order until one matches. If nothing matches (for example, if it’s a line of build output we are not interested in), this composite parser will fail.
    /// we probably eventually want to move the matching of EOL characters into these component parsers, and add a catch-all “unrecognized line” parser at the bottom. This would allow us to completely stream data into Grizzly instead of what we are doing now, which just sends one line at a time via `Swift.readLine(strippingNewline:)`
    static var parser: StringParser<GrizzlyLogLine> =
        parseSuiteStarted.map { .suiteStarted($0) }
            <|> parseSuiteCompleted.map { .suiteCompleted($0) }
            <|> parseCaseStarted.map { .caseStarted($0) }
            <|> parseCaseCompleted.map { .caseCompleted($0) }
}
