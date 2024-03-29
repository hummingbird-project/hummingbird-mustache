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

@testable import Mustache
import XCTest

final class PartialTests: XCTestCase {
    /// Testing partials
    func testMustacheManualExample9() throws {
        let template = try MustacheTemplate(string: """
        <h2>Names</h2>
        {{#names}}
          {{> user}}
        {{/names}}
        """)
        let template2 = try MustacheTemplate(string: """
        <strong>{{.}}</strong>

        """)
        let library = MustacheLibrary(templates: ["base": template, "user": template2])

        let object: [String: Any] = ["names": ["john", "adam", "claire"]]
        XCTAssertEqual(library.render(object, withTemplate: "base"), """
        <h2>Names</h2>
          <strong>john</strong>
          <strong>adam</strong>
          <strong>claire</strong>

        """)
    }

    /// Test where last line of partial generates no content. It should not add a
    /// tab either
    func testPartialEmptyLineTabbing() throws {
        let template = try MustacheTemplate(string: """
        <h2>Names</h2>
        {{#names}}
          {{> user}}
        {{/names}}
        Text after

        """)
        let template2 = try MustacheTemplate(string: """
        {{^empty(.)}}
        <strong>{{.}}</strong>
        {{/empty(.)}}
        {{#empty(.)}}
        <strong>empty</strong>
        {{/empty(.)}}

        """)
        var library = MustacheLibrary()
        library.register(template, named: "base")
        library.register(template2, named: "user") // , withTemplate: String)// = MustacheLibrary(templates: ["base": template, "user": template2])

        let object: [String: Any] = ["names": ["john", "adam", "claire"]]
        XCTAssertEqual(library.render(object, withTemplate: "base"), """
        <h2>Names</h2>
          <strong>john</strong>
          <strong>adam</strong>
          <strong>claire</strong>
        Text after

        """)
    }

    /// Testing dynamic partials
    func testDynamicPartials() throws {
        let template = try MustacheTemplate(string: """
        <h2>Names</h2>
        {{partial}}
        """)
        let template2 = try MustacheTemplate(string: """
        {{#names}}
          <strong>{{.}}</strong>
        {{/names}}
        """)
        let library = MustacheLibrary(templates: ["base": template])

        let object: [String: Any] = ["names": ["john", "adam", "claire"], "partial": template2]
        XCTAssertEqual(library.render(object, withTemplate: "base"), """
        <h2>Names</h2>
          <strong>john</strong>
          <strong>adam</strong>
          <strong>claire</strong>

        """)
    }

    /// test inheritance
    func testInheritance() throws {
        var library = MustacheLibrary()
        try library.register(
            """
            <head>
            <title>{{$title}}Default title{{/title}}</title>
            </head>

            """,
            named: "header"
        )
        try library.register(
            """
            <html>
            {{$header}}{{/header}}
            {{$content}}{{/content}}
            </html>

            """,
            named: "base"
        )
        try library.register(
            """
            {{<base}}
            {{$header}}
            {{<header}}
            {{$title}}My page title{{/title}}
            {{/header}}
            {{/header}}
            {{$content}}<h1>Hello world</h1>{{/content}}
            {{/base}}

            """,
            named: "mypage"
        )
        XCTAssertEqual(library.render({}, withTemplate: "mypage")!, """
        <html>
        <head>
        <title>My page title</title>
        </head>
        <h1>Hello world</h1>
        </html>

        """)
    }
}
