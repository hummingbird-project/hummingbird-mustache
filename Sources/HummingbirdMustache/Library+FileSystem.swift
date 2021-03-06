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

import Foundation

extension HBMustacheLibrary {
    /// Load templates from a folder
    func loadTemplates(from directory: String, withExtension extension: String = "mustache") throws {
        var directory = directory
        if !directory.hasSuffix("/") {
            directory += "/"
        }
        let extWithDot = ".\(`extension`)"
        let fs = FileManager()
        guard let enumerator = fs.enumerator(atPath: directory) else { return }
        for case let path as String in enumerator {
            guard path.hasSuffix(extWithDot) else { continue }
            guard let data = fs.contents(atPath: directory + path) else { continue }
            let string = String(decoding: data, as: Unicode.UTF8.self)
            let template: HBMustacheTemplate
            do {
                template = try HBMustacheTemplate(string: string)
            } catch let error as HBMustacheTemplate.ParserError {
                throw ParserError(filename: path, context: error.context, error: error.error)
            }
            // drop ".mustache" from path to get name
            let name = String(path.dropLast(extWithDot.count))
            register(template, named: name)
        }
    }
}
