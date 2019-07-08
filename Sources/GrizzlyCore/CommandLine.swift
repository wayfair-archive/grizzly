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

/// command line options for Grizzly
public struct GrizzlyOptions {
    public let outputJSON: Bool
}

/// parser that turns the string “--json” (as in, “use JSON output”) into `true` and anything else into `false`
let parseJSONFlag = string("--json").asBool

/// parser that parses all the `GrizzlyOptions` eg. from `ProcessInfo.arguments`
let parseGrizzlyOptions: Parser<[String], GrizzlyOptions> = .init { stream in
    var options = GrizzlyOptions(outputJSON: false)
    for string in stream {
        if let (result, _) = try? parseJSONFlag.map(GrizzlyOptions.init).run(string) {
            options = result
        }
    }
    return (options, [])
}

public extension ProcessInfo {
    var grizzlyOptions: GrizzlyOptions {
        let (result, _) = try! parseGrizzlyOptions.parse(
            Array(arguments.dropFirst())
        )
        return result
    }
}
