//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import HummingbirdMustache
import XCTest

final class LibraryTests: XCTestCase {
    func testDirectoryLoad() throws {
        let fs = FileManager()
        try? fs.createDirectory(atPath: "templates", withIntermediateDirectories: false)
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates")) }
        let mustache = Data("<test>{{#value}}<value>{{.}}</value>{{/value}}</test>".utf8)
        try mustache.write(to: URL(fileURLWithPath: "templates/test.mustache"))
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates/test.mustache")) }

        let library = try HBMustacheLibrary(directory: "./templates")
        let object = ["value": ["value1", "value2"]]
        XCTAssertEqual(library.render(object, withTemplate: "test"), "<test><value>value1</value><value>value2</value></test>")
    }

    func testLibraryParserError() throws {
        let fs = FileManager()
        try? fs.createDirectory(atPath: "templates", withIntermediateDirectories: false)
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates")) }
        let mustache = Data("<test>{{#value}}<value>{{.}}</value>{{/value}}</test>".utf8)
        try mustache.write(to: URL(fileURLWithPath: "templates/test.mustache"))
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates/test.mustache")) }
        let mustache2 = Data("""
        {{#test}}
        {{{name}}
        {{/test2}}
        """.utf8)
        try mustache2.write(to: URL(fileURLWithPath: "templates/error.mustache"))
        defer { XCTAssertNoThrow(try fs.removeItem(atPath: "templates/error.mustache")) }

        XCTAssertThrowsError(try HBMustacheLibrary(directory: "./templates")) { error in
            guard let parserError = error as? HBMustacheLibrary.ParserError else {
                XCTFail("\(error)")
                return
            }
            XCTAssertEqual(parserError.filename, "error.mustache")
            XCTAssertEqual(parserError.context.line, "{{{name}}")
            XCTAssertEqual(parserError.context.lineNumber, 2)
            XCTAssertEqual(parserError.context.columnNumber, 10)
        }
    }
}
