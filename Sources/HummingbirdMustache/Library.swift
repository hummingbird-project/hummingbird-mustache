/// Class holding a collection of mustache templates.
///
/// Each template can reference the others via a partial using the name the template is registered under
/// ```
/// {{#sequence}}{{>entry}}{{/sequence}}
/// ```
public final class HBMustacheLibrary {
    /// Initialize empty library
    public init() {
        self.templates = [:]
    }

    /// Initialize library with contents of folder.
    ///
    /// Each template is registered with the name of the file minus its extension. The search through
    /// the folder is recursive and templates in subfolders will be registered with the name `subfolder/template`.
    /// - Parameter directory: Directory to look for mustache templates
    /// - Parameter extension: Extension of files to look for
    public init(directory: String, withExtension extension: String = "mustache") throws {
        self.templates = [:]
        try loadTemplates(from: directory, withExtension: `extension`)
    }

    /// Register template under name
    /// - Parameters:
    ///   - template: Template
    ///   - name: Name of template
    public func register(_ template: HBMustacheTemplate, named name: String) {
        template.setLibrary(self)
        self.templates[name] = template
    }

    /// Register template under name
    /// - Parameters:
    ///   - mustache: Mustache text
    ///   - name: Name of template
    public func register(_ mustache: String, named name: String) throws {
        let template = try HBMustacheTemplate(string: mustache)
        template.setLibrary(self)
        self.templates[name] = template
    }

    /// Return template registed with name
    /// - Parameter name: name to search for
    /// - Returns: Template
    public func getTemplate(named name: String) -> HBMustacheTemplate? {
        self.templates[name]
    }

    /// Render object using templated with name
    /// - Parameters:
    ///   - object: Object to render
    ///   - name: Name of template
    /// - Returns: Rendered text
    public func render(_ object: Any, withTemplate name: String) -> String? {
        guard let template = templates[name] else { return nil }
        return template.render(object)
    }

    /// Error returned by init() when parser fails
    public struct ParserError: Swift.Error {
        /// File error occurred in
        public let filename: String
        /// Context (line, linenumber and column number)
        public let context: HBParser.Context
        /// Actual error that occurred
        public let error: Error
    }

    private var templates: [String: HBMustacheTemplate]
}
