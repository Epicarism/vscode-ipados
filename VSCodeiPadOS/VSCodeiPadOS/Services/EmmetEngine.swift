//  EmmetEngine.swift
//  VSCodeiPadOS
//
//  Lightweight Emmet abbreviation expansion engine for HTML and CSS files.
//  Triggered on Tab key (always) and optionally on Enter/Space.

import Foundation

// MARK: - Public API

/// Emmet expansion engine. Call expand(_:for:) with the abbreviation and filename.
public final class EmmetEngine: @unchecked Sendable {

    /// Trigger key that invoked Emmet expansion.
    public enum EmmetTrigger: Sendable {
        case tab
        case enter
        case space
    }

    public static let shared = EmmetEngine()
    private init() {}

    // MARK: - Settings

    /// Whether Emmet expansion should trigger on Enter key (default: false).
    public var expandOnEnter: Bool {
        get { UserDefaults.standard.bool(forKey: "emmetExpandOnEnter") }
        set { UserDefaults.standard.set(newValue, forKey: "emmetExpandOnEnter") }
    }

    /// Whether Emmet expansion should trigger on Space key (default: false).
    public var expandOnSpace: Bool {
        get { UserDefaults.standard.bool(forKey: "emmetExpandOnSpace") }
        set { UserDefaults.standard.set(newValue, forKey: "emmetExpandOnSpace") }
    }

    // MARK: - Entry point

    /// Attempt to expand `abbreviation` for the file type identified by `filename`.
    /// Returns the expanded string, or nil if not recognised.
    public func expand(_ abbreviation: String, for filename: String) -> String? {
        let abbr = abbreviation.trimmingCharacters(in: .whitespaces)
        guard !abbr.isEmpty else { return nil }
        switch detectLanguage(for: filename) {
        case .html:    return expandHTML(abbr)
        case .css:     return expandCSS(abbr)
        case .unknown: return nil
        }
    }

    /// Returns true if the filename extension supports Emmet.
    public func isSupported(for filename: String) -> Bool {
        detectLanguage(for: filename) != .unknown
    }

    // MARK: - Language detection

    private enum Language: Equatable { case html, css, unknown }

    private func detectLanguage(for filename: String) -> Language {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "html", "htm", "xhtml", "xml", "svg",
             "jsx", "tsx", "vue", "svelte", "php", "erb":
            return .html
        case "css", "scss", "less", "sass", "styl", "postcss":
            return .css
        default:
            return .unknown
        }
    }
}

// MARK: - HTML Expansion

extension EmmetEngine {

    // Void (self-closing) HTML elements
    private static let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"
    ]

    // Build the HTML5 boilerplate string at runtime to avoid escape-quoting issues
    private static let html5Boilerplate: String = {
        let q = "\""
        return [
            "<!DOCTYPE html>",
            "<html lang=" + q + "en" + q + ">",
            "<head>",
            "    <meta charset=" + q + "UTF-8" + q + ">",
            "    <meta name=" + q + "viewport" + q +
                " content=" + q + "width=device-width, initial-scale=1.0" + q + ">",
            "    <title>Document</title>",
            "</head>",
            "<body>",
            "    ",
            "</body>",
            "</html>"
        ].joined(separator: "\n")
    }()

    // Build common shortcuts at runtime to avoid embedded quote escaping
    private nonisolated(unsafe) static let htmlShortcuts: [String: () -> String] = [
        "!": { EmmetEngine.html5Boilerplate },
        "html:5": { EmmetEngine.html5Boilerplate },
        "link:css": {
            let q = "\""
            return "<link rel=" + q + "stylesheet" + q + " href=" + q + "style.css" + q + ">"
        },
        "link:favicon": {
            let q = "\""
            return "<link rel=" + q + "shortcut icon" + q +
                   " type=" + q + "image/x-icon" + q +
                   " href=" + q + "favicon.ico" + q + ">"
        },
        "link:print": {
            let q = "\""
            return "<link rel=" + q + "stylesheet" + q +
                   " href=" + q + "print.css" + q +
                   " media=" + q + "print" + q + ">"
        },
        "script:src": {
            let q = "\""
            return "<script src=" + q + q + "></script>"
        },
        "meta:utf": {
            let q = "\""
            return "<meta charset=" + q + "UTF-8" + q + ">"
        },
        "meta:vp": {
            let q = "\""
            return "<meta name=" + q + "viewport" + q +
                   " content=" + q + "width=device-width, initial-scale=1.0" + q + ">"
        },
        "input:text":     { EmmetEngine.inputTag(type: "text") },
        "input:email":    { EmmetEngine.inputTag(type: "email") },
        "input:password": { EmmetEngine.inputTag(type: "password") },
        "input:checkbox": { EmmetEngine.inputTag(type: "checkbox") },
        "input:radio":    { EmmetEngine.inputTag(type: "radio") },
        "input:submit":   { EmmetEngine.inputTag(type: "submit",  valueAttr: true) },
        "input:button":   { EmmetEngine.inputTag(type: "button",  valueAttr: true) },
        "input:file":     { EmmetEngine.inputTag(type: "file",    nameOnly:  true) },
        "input:search":   { EmmetEngine.inputTag(type: "search") },
        "input:number":   { EmmetEngine.inputTag(type: "number") },
        "input:date":     { EmmetEngine.inputTag(type: "date") },
        "input:color":    { EmmetEngine.inputTag(type: "color") },
        "input:range":    { EmmetEngine.inputTag(type: "range") },
        "input:url":      { EmmetEngine.inputTag(type: "url") },
        "btn:submit": {
            let q = "\""
            return "<button type=" + q + "submit" + q + "></button>"
        },
        "btn:reset": {
            let q = "\""
            return "<button type=" + q + "reset" + q + "></button>"
        },
        "btn:button": {
            let q = "\""
            return "<button type=" + q + "button" + q + "></button>"
        },
        "a:link": {
            let q = "\""
            return "<a href=" + q + "http://" + q + "></a>"
        },
        "a:mail": {
            let q = "\""
            return "<a href=" + q + "mailto:" + q + "></a>"
        },
    ]

    private static func inputTag(
        type: String,
        nameId: Bool = true,
        valueAttr: Bool = false,
        nameOnly: Bool = false
    ) -> String {
        let q = "\""
        var s = "<input type=" + q + type + q
        if nameOnly {
            s += " name=" + q + q
        } else if nameId {
            s += " name=" + q + q + " id=" + q + q
        }
        if valueAttr {
            s += " value=" + q + q
        }
        return s + ">"
    }

    // MARK: - HTML entry

    private func expandHTML(_ abbreviation: String) -> String? {
        if let factory = EmmetEngine.htmlShortcuts[abbreviation] {
            return factory()
        }
        let parser = HTMLAbbreviationParser(abbreviation)
        guard let nodes = parser.parse() else { return nil }
        let result = nodes.map { renderHTMLNode($0) }.joined()
        return result.isEmpty ? nil : result
    }

    // MARK: - Rendering

    private func renderHTMLNode(_ node: HTMLNode) -> String {
        guard node.multiplier >= 1 else { return "" }
        var output = ""
        for i in 1...node.multiplier {
            output += renderSingleHTMLNode(node, index: i)
        }
        return output
    }

    private func renderSingleHTMLNode(_ node: HTMLNode, index: Int) -> String {
        let tag = node.tag
        let q = "\""
        var attrs = ""

        if let id = node.id {
            attrs += " id=" + q + resolveNumbering(id, index: index) + q
        }
        if !node.classes.isEmpty {
            let cls = node.classes
                .map { resolveNumbering($0, index: index) }
                .joined(separator: " ")
            attrs += " class=" + q + cls + q
        }
        for (k, v) in node.attributes {
            attrs += " " + k + "=" + q + resolveNumbering(v, index: index) + q
        }

        if EmmetEngine.voidElements.contains(tag.lowercased()) {
            return "<" + tag + attrs + ">"
        }

        let text = resolveNumbering(node.textContent, index: index)

        if node.children.isEmpty {
            return "<" + tag + attrs + ">" + text + "</" + tag + ">"
        }
        var inner = text
        for child in node.children {
            inner += renderSingleHTMLNode(child, index: index)
        }
        return "<" + tag + attrs + ">" + inner + "</" + tag + ">"
    }

    /// Replaces $ placeholder with the current iteration index.
    private func resolveNumbering(_ s: String, index: Int) -> String {
        var r = s
        r = r.replacingOccurrences(of: "$$$", with: String(format: "%03d", index))
        r = r.replacingOccurrences(of: "$$",  with: String(format: "%02d", index))
        r = r.replacingOccurrences(of: "$",   with: "\(index)")
        return r
    }
}

// MARK: - HTML AST Node

private final class HTMLNode {
    var tag: String
    var id: String?
    var classes: [String] = []
    var attributes: [(String, String)] = []
    var textContent: String = ""
    var multiplier: Int = 1
    var children: [HTMLNode] = []
    init(tag: String) { self.tag = tag }
}

// MARK: - HTML Abbreviation Parser (recursive descent)
//
// Grammar:
//   abbreviation := sequence
//   sequence     := element ('+' element)*
//   element      := node ('>' sequence)?
//   node         := tagName modifiers? ('{' text '}')? ('*' digits)?
//   modifiers    := ('.' ident | '#' ident | '[' attrs ']')*

private final class HTMLAbbreviationParser {
    private let input: [Character]
    private var pos: Int = 0

    init(_ s: String) { self.input = Array(s) }

    private var current: Character? { pos < input.count ? input[pos] : nil }

    private func expect(_ c: Character) {
        if current == c { pos += 1 }
    }

    private var atEnd: Bool { pos >= input.count }

    // MARK: Public entry

    func parse() -> [HTMLNode]? {
        guard let nodes = parseSequence() else { return nil }
        return atEnd ? nodes : nil
    }

    // MARK: sequence := element ('+' element)*

    private func parseSequence() -> [HTMLNode]? {
        guard var nodes = parseElement() else { return nil }
        while current == "+" {
            pos += 1
            guard let more = parseElement() else { return nil }
            nodes.append(contentsOf: more)
        }
        return nodes
    }

    // MARK: element := node ('>' sequence)?

    private func parseElement() -> [HTMLNode]? {
        guard let node = parseNode() else { return nil }
        if current == ">" {
            pos += 1
            guard let children = parseSequence() else { return nil }
            node.children = children
        }
        return [node]
    }

    // MARK: node := tagName modifiers? ('{' text '}')? ('*' digits)?

    private func parseNode() -> HTMLNode? {
        let tag = parseTagName()
        guard !tag.isEmpty else { return nil }
        let node = HTMLNode(tag: tag)
        parseModifiers(into: node)
        if current == "{" {
            pos += 1
            var text = ""
            while let c = current, c != "}" { text.append(c); pos += 1 }
            expect("}")
            node.textContent = text
        }
        if current == "*" {
            pos += 1
            node.multiplier = Int(parseDigits()) ?? 1
        }
        return node
    }

    private func parseTagName() -> String {
        // Bare .class or #id shorthand defaults to div
        if current == "." || current == "#" { return "div" }
        var name = ""
        while let c = current, c.isLetter || c.isNumber || c == "-" || c == ":" {
            name.append(c); pos += 1
        }
        return name
    }

    private func parseModifiers(into node: HTMLNode) {
        while true {
            switch current {
            case ".":
                pos += 1
                let cls = parseIdentifier()
                if !cls.isEmpty { node.classes.append(cls) }
            case "#":
                pos += 1
                let idStr = parseIdentifier()
                if !idStr.isEmpty { node.id = idStr }
            case "[":
                pos += 1
                parseAttributes(into: node)
            default:
                return
            }
        }
    }

    private func parseAttributes(into node: HTMLNode) {
        while let c = current, c != "]" {
            skipSpaces()
            guard let ch = current, ch != "]" else { break }
            let key = parseIdentifier()
            guard !key.isEmpty else { pos += 1; continue }
            var value = ""
            if current == "=" {
                pos += 1
                if current == "\"" || current == "'" {
                    guard let q = current else { break }
                    pos += 1
                    while let ch2 = current, ch2 != q { value.append(ch2); pos += 1 }
                    if current == q { pos += 1 }
                } else {
                    while let ch2 = current, ch2 != " " && ch2 != "]" {
                        value.append(ch2); pos += 1
                    }
                }
            }
            node.attributes.append((key, value))
            skipSpaces()
        }
        expect("]")
    }

    private func parseIdentifier() -> String {
        var s = ""
        while let c = current, c.isLetter || c.isNumber || c == "-" || c == "_" || c == "$" {
            s.append(c); pos += 1
        }
        return s
    }

    private func parseDigits() -> String {
        var s = ""
        while let c = current, c.isNumber { s.append(c); pos += 1 }
        return s
    }

    private func skipSpaces() {
        while current == " " { pos += 1 }
    }
}

// MARK: - CSS Expansion

extension EmmetEngine {

    // Maps abbreviated property aliases to either:
    //   "propertyName"           (property only; needs a following value)
    //   "propertyName:keyword"   (property + baked-in keyword value)
    private static let cssPropertyAliases: [String: String] = [
        // Display
        "d":     "display",
        "db":    "display:block",
        "di":    "display:inline",
        "dib":   "display:inline-block",
        "df":    "display:flex",
        "dif":   "display:inline-flex",
        "dg":    "display:grid",
        "dig":   "display:inline-grid",
        "dn":    "display:none",
        "dt":    "display:table",
        "dtc":   "display:table-cell",
        // Position
        "pos":   "position",
        "posa":  "position:absolute",
        "posf":  "position:fixed",
        "posr":  "position:relative",
        "poss":  "position:sticky",
        "post":  "position:static",
        // Overflow
        "ov":    "overflow",
        "ovx":   "overflow-x",
        "ovy":   "overflow-y",
        "oh":    "overflow:hidden",
        "oa":    "overflow:auto",
        "os":    "overflow:scroll",
        // Float and clear
        "fl":    "float",
        "fll":   "float:left",
        "flr":   "float:right",
        "fln":   "float:none",
        "cl":    "clear",
        "cla":   "clear:both",
        // Visibility
        "v":     "visibility",
        "vis":   "visibility:visible",
        "hid":   "visibility:hidden",
        // Outline
        "o":     "outline",
        "on":    "outline:none",
        // List
        "list":  "list-style",
        "listn": "list-style:none",
        // User-select
        "usr":   "user-select",
        "usrn":  "user-select:none",
        // Box model
        "m":     "margin",
        "mt":    "margin-top",
        "mr":    "margin-right",
        "mb":    "margin-bottom",
        "ml":    "margin-left",
        "p":     "padding",
        "pt":    "padding-top",
        "pr":    "padding-right",
        "pb":    "padding-bottom",
        "pl":    "padding-left",
        // Sizing
        "w":     "width",
        "h":     "height",
        "maw":   "max-width",
        "mah":   "max-height",
        "miw":   "min-width",
        "mih":   "min-height",
        // Typography
        "fz":    "font-size",
        "fw":    "font-weight",
        "fs":    "font-style",
        "ff":    "font-family",
        "lh":    "line-height",
        "ls":    "letter-spacing",
        "ta":    "text-align",
        "td":    "text-decoration",
        "tt":    "text-transform",
        "whs":   "white-space",
        "wb":    "word-break",
        // Background and color
        "bg":    "background",
        "bgc":   "background-color",
        "bgi":   "background-image",
        "bgp":   "background-position",
        "bgr":   "background-repeat",
        "bgs":   "background-size",
        "c":     "color",
        "op":    "opacity",
        // Border
        "bd":    "border",
        "bdc":   "border-color",
        "bdw":   "border-width",
        "bds":   "border-style",
        "bdrrs": "border-radius",
        "bxsh":  "box-shadow",
        "txsh":  "text-shadow",
        // Flex
        "jc":    "justify-content",
        "ai":    "align-items",
        "ac":    "align-content",
        "as":    "align-self",
        "fx":    "flex",
        "fxg":   "flex-grow",
        "fxsh":  "flex-shrink",
        "fxb":   "flex-basis",
        "fxd":   "flex-direction",
        "fxw":   "flex-wrap",
        // Grid
        "gtc":   "grid-template-columns",
        "gtr":   "grid-template-rows",
        "gta":   "grid-template-areas",
        "gc":    "grid-column",
        "gr":    "grid-row",
        "gg":    "gap",
        "rg":    "row-gap",
        "cg":    "column-gap",
        // Misc
        "cur":   "cursor",
        "pe":    "pointer-events",
        "trs":   "transition",
        "trx":   "transform",
        "z":     "z-index",
        "top":   "top",
        "bot":   "bottom",
        "lft":   "left",
        "rgt":   "right",
    ]

    private static let cssValueAliases: [String: String] = [
        "n":   "none",
        "a":   "auto",
        "i":   "inherit",
        "un":  "unset",
        "nor": "normal",
        "fs":  "flex-start",
        "fe":  "flex-end",
        "c":   "center",
        "sb":  "space-between",
        "sa":  "space-around",
        "se":  "space-evenly",
        "str": "stretch",
        "b":   "baseline",
        "bl":  "block",
        "il":  "inline",
        "ilb": "inline-block",
        "abs": "absolute",
        "rel": "relative",
        "fix": "fixed",
        "stk": "sticky",
        "l":   "left",
        "r":   "right",
        "j":   "justify",
        "h":   "hidden",
        "sc":  "scroll",
    ]

    // MARK: - CSS entry

    private func expandCSS(_ abbreviation: String) -> String? {
        // Exact alias match (possibly with baked-in keyword value)
        if let full = EmmetEngine.cssPropertyAliases[abbreviation] {
            if let colonIdx = full.firstIndex(of: ":") {
                let prop = String(full[full.startIndex..<colonIdx])
                let val  = String(full[full.index(after: colonIdx)...])
                return prop + ": " + val + ";"
            }
            return nil  // property only — no value provided
        }
        return parseCSSAbbreviation(abbreviation)
    }

    // MARK: - CSS parser
    //
    // Handles:  m10       -> margin: 10px;
    //           p10-20    -> padding: 10px 20px;
    //           w100p     -> width: 100%;
    //           fz1r      -> font-size: 1rem;
    //           bgcf06    -> background-color: #f06;
    //           op0       -> opacity: 0;

    private func parseCSSAbbreviation(_ abbr: String) -> String? {
        let chars = Array(abbr)
        var i = 0

        // 1. Extract leading alpha chars = property alias
        var propAlias = ""
        while i < chars.count && chars[i].isLetter {
            propAlias.append(chars[i])
            i += 1
        }
        guard !propAlias.isEmpty else { return nil }

        // 2. Resolve property name
        var propName: String
        if let full = EmmetEngine.cssPropertyAliases[propAlias] {
            if let colonIdx = full.firstIndex(of: ":") {
                // Keyword baked in: if nothing follows, return the baked expansion
                if i == chars.count {
                    let p = String(full[full.startIndex..<colonIdx])
                    let v = String(full[full.index(after: colonIdx)...])
                    return p + ": " + v + ";"
                }
                propName = String(full[full.startIndex..<colonIdx])
            } else {
                propName = full
            }
        } else {
            let known: Set<String> = [
                "margin", "padding", "width", "height", "top", "left",
                "right", "bottom", "color", "background", "border",
                "font", "flex", "grid", "opacity", "display",
                "position", "overflow", "transform", "transition",
                "cursor", "outline", "float", "clear", "visibility",
                "z-index", "gap",
            ]
            guard known.contains(propAlias) else { return nil }
            propName = propAlias
        }

        // Nothing after property alias
        guard i < chars.count else { return nil }

        // 3. Parse value tokens separated by '-'
        var valueTokens: [String] = []
        while i < chars.count {
            let ch = chars[i]

            if ch == "-" {
                // Value separator or start of negative number?
                if i + 1 < chars.count && chars[i + 1].isNumber {
                    i += 1
                    var numStr = "-"
                    while i < chars.count && (chars[i].isNumber || chars[i] == ".") {
                        numStr.append(chars[i]); i += 1
                    }
                    valueTokens.append(formatCSSValue(numStr, unit: consumeCSSUnit(&i, chars: chars)))
                } else {
                    i += 1  // separator
                }
                continue
            }

            if ch.isNumber {
                var numStr = ""
                while i < chars.count && (chars[i].isNumber || chars[i] == ".") {
                    numStr.append(chars[i]); i += 1
                }
                valueTokens.append(formatCSSValue(numStr, unit: consumeCSSUnit(&i, chars: chars)))
                continue
            }

            if ch == "#" {
                i += 1
                var hex = ""
                while i < chars.count && isHexChar(chars[i]) { hex.append(chars[i]); i += 1 }
                valueTokens.append("#" + hex)
                continue
            }

            // Bare 3-or-6 hex color (e.g. f06, ff0066)
            let hexStart = i
            var hexStr = ""
            while i < chars.count && isHexChar(chars[i]) { hexStr.append(chars[i]); i += 1 }
            if (hexStr.count == 3 || hexStr.count == 6) &&
               (i == chars.count || chars[i] == "-") {
                valueTokens.append("#" + hexStr)
                continue
            }
            i = hexStart  // backtrack

            // Keyword value
            var kw = ""
            while i < chars.count && chars[i].isLetter { kw.append(chars[i]); i += 1 }
            if kw.isEmpty { return nil }
            valueTokens.append(EmmetEngine.cssValueAliases[kw] ?? kw)
        }

        guard !valueTokens.isEmpty else { return nil }
        return propName + ": " + valueTokens.joined(separator: " ") + ";"
    }

    // Consume a CSS unit suffix starting at index i. Advances i past the unit.
    private func consumeCSSUnit(_ i: inout Int, chars: [Character]) -> String? {
        guard i < chars.count else { return nil }
        switch chars[i] {
        case "p":
            if i + 1 < chars.count && chars[i + 1] == "x" { i += 2; return "px" }
            i += 1; return "%"  // bare 'p' -> percent
        case "e":
            if i + 1 < chars.count && chars[i + 1] == "m" { i += 2; return "em" }
        case "r":
            if i + 1 < chars.count && chars[i + 1] == "e",
               i + 2 < chars.count && chars[i + 2] == "m" { i += 3; return "rem" }
            i += 1; return "rem"  // bare 'r' -> rem
        case "v":
            if i + 1 < chars.count {
                if chars[i + 1] == "w" { i += 2; return "vw" }
                if chars[i + 1] == "h" { i += 2; return "vh" }
            }
        case "%":
            i += 1; return "%"
        case "s":
            i += 1; return "s"
        case "d":
            if i + 1 < chars.count && chars[i + 1] == "e",
               i + 2 < chars.count && chars[i + 2] == "g" { i += 3; return "deg" }
        default:
            break
        }
        return nil
    }

    private func formatCSSValue(_ number: String, unit: String?) -> String {
        if let u = unit { return number + u }
        if number == "0" || number == "-0" { return "0" }
        return number + "px"
    }

    private func isHexChar(_ c: Character) -> Bool {
        (c >= "0" && c <= "9") || (c >= "a" && c <= "f") || (c >= "A" && c <= "F")
    }
}

// MARK: - RunestoneEditorView integration helper

extension EmmetEngine {

    /// Called from key handlers in RunestoneEditorView.Coordinator.
    ///
    /// Locates the abbreviation immediately before `cursorLocation` in `text`,
    /// expands it, and returns the expansion with its replacement range — or nil
    /// if no Emmet expansion applies.
    ///
    /// When `trigger` is `.enter` the expansion is followed by a newline;
    /// when `.space` it is followed by a space character; `.tab` appends nothing.
    /// Non-tab triggers are only attempted when the corresponding setting is enabled.
    public func tryExpand(
        in text: String,
        cursorLocation: Int,
        filename: String,
        trigger: EmmetTrigger = .tab
    ) -> (expansion: String, replacementRange: NSRange)? {

        guard isSupported(for: filename) else { return nil }

        // Non-tab triggers require opt-in setting
        switch trigger {
        case .tab:
            break
        case .enter:
            guard expandOnEnter else { return nil }
        case .space:
            guard expandOnSpace else { return nil }
        }

        let ns = text as NSString
        // Characters that terminate an abbreviation when encountered walking backwards
        let stopChars = CharacterSet(charactersIn: " \n\r\t;<>()")

        var start = cursorLocation
        var bracketDepth = 0

        while start > 0 {
            let idx = start - 1
            guard idx >= 0 && idx < ns.length else { break }
            let charCode = ns.character(at: idx)
            guard let scalar = Unicode.Scalar(charCode) else { break }
            let c = Character(scalar)

            // Track square brackets so we can walk through [attr=val]
            if c == "]" { bracketDepth += 1; start -= 1; continue }
            if c == "[" {
                if bracketDepth > 0 { bracketDepth -= 1; start -= 1; continue }
                else { break }
            }
            if bracketDepth > 0 { start -= 1; continue }
            if stopChars.contains(scalar) { break }
            start -= 1
        }

        guard start < cursorLocation else { return nil }

        let abbrev = ns.substring(with: NSRange(location: start, length: cursorLocation - start))
        let trimmed = abbrev.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        guard let expansion = expand(trimmed, for: filename) else { return nil }

        // Append the trigger character so the expected keystroke still happens
        let suffix: String
        switch trigger {
        case .tab:   suffix = ""
        case .enter: suffix = "\n"
        case .space: suffix = " "
        }

        return (expansion + suffix, NSRange(location: start, length: cursorLocation - start))
    }
}
