//
//  TreeSitterFoldingEngine.swift
//  VSCodeiPadOS
//
//  TreeSitter-based code folding detection engine.
//  Replaces regex-based fold detection with AST-aware analysis
//  supporting multiple languages with incremental updates.
//

import Foundation
import os

/// Typealias so TreeSitter engine can reference FoldType without qualifying as FoldRegion.FoldType
typealias FoldType = FoldRegion.FoldType

// MARK: - TreeSitter Node Abstraction

/// Protocol for accessing syntax tree nodes.
/// Abstracts over Runestone's internal tree or a direct TreeSitter binding.
protocol SyntaxTreeNode {
    var type: String { get }
    var startLine: Int { get }
    var endLine: Int { get }
    var startColumn: Int { get }
    var endColumn: Int { get }
    var childCount: Int { get }
    var children: [SyntaxTreeNode] { get }
    var parent: SyntaxTreeNode? { get }
    func child(at index: Int) -> SyntaxTreeNode?
    func namedChild(_ name: String) -> SyntaxTreeNode?
}

/// Protocol for accessing the syntax tree root
protocol SyntaxTreeProvider {
    var rootNode: SyntaxTreeNode? { get }
    var language: String { get }
    func nodeAt(line: Int, column: Int) -> SyntaxTreeNode?
}

// MARK: - Fold Type Mapping

/// Maps TreeSitter node types to FoldType categories
struct FoldTypeMapping {
    let nodeType: String
    let foldType: FoldType
    let labelExtractor: LabelExtractor
    let minimumLines: Int
    
    enum LabelExtractor {
        case namedChild(String)
        case nodeType
        case firstLine
        case custom(String)
    }
}

// MARK: - Language Fold Configuration

struct LanguageFoldConfig {
    let language: String
    let mappings: [FoldTypeMapping]
    let commentNodeTypes: Set<String>
    let importNodeTypes: Set<String>
    let minimumFoldLines: Int
    
    var foldableNodeTypes: Set<String> {
        Set(mappings.map { $0.nodeType })
    }
}

// MARK: - Language Configurations

extension LanguageFoldConfig {
    
    static let swift = LanguageFoldConfig(
        language: "swift",
        mappings: [
            FoldTypeMapping(nodeType: "class_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "struct_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "actor_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_declaration", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "protocol_declaration", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "extension_declaration", foldType: .extension, labelExtractor: .namedChild("type_identifier"), minimumLines: 2),
            FoldTypeMapping(nodeType: "function_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "init_declaration", foldType: .function, labelExtractor: .custom("init"), minimumLines: 2),
            FoldTypeMapping(nodeType: "deinit_declaration", foldType: .function, labelExtractor: .custom("deinit"), minimumLines: 2),
            FoldTypeMapping(nodeType: "subscript_declaration", foldType: .function, labelExtractor: .custom("subscript"), minimumLines: 2),
            FoldTypeMapping(nodeType: "computed_property", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "guard_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "do_statement", foldType: .controlFlow, labelExtractor: .custom("do"), minimumLines: 2),
            FoldTypeMapping(nodeType: "catch_clause", foldType: .controlFlow, labelExtractor: .custom("catch"), minimumLines: 2),
            FoldTypeMapping(nodeType: "closure_expression", foldType: .genericBlock, labelExtractor: .custom("closure"), minimumLines: 3),
        ],
        commentNodeTypes: ["comment", "multiline_comment", "block_comment"],
        importNodeTypes: ["import_declaration"],
        minimumFoldLines: 2
    )
    
    static let javascript = LanguageFoldConfig(
        language: "javascript",
        mappings: [
            FoldTypeMapping(nodeType: "function_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "class_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "method_definition", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "arrow_function", foldType: .function, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "generator_function_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_in_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "do_statement", foldType: .controlFlow, labelExtractor: .custom("do"), minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "try_statement", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
            FoldTypeMapping(nodeType: "object", foldType: .genericBlock, labelExtractor: .custom("object"), minimumLines: 3),
            FoldTypeMapping(nodeType: "array", foldType: .genericBlock, labelExtractor: .custom("array"), minimumLines: 3),
            FoldTypeMapping(nodeType: "template_string", foldType: .genericBlock, labelExtractor: .custom("template"), minimumLines: 3),
        ],
        commentNodeTypes: ["comment", "multiline_comment", "block_comment", "hash_bang_line"],
        importNodeTypes: ["import_statement", "import_declaration"],
        minimumFoldLines: 2
    )
    
    static let typescript: LanguageFoldConfig = {
        var mappings = javascript.mappings
        mappings.append(contentsOf: [
            FoldTypeMapping(nodeType: "interface_declaration", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "type_alias_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_declaration", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "module", foldType: .extension, labelExtractor: .namedChild("name"), minimumLines: 2),
        ])
        return LanguageFoldConfig(
            language: "typescript",
            mappings: mappings,
            commentNodeTypes: javascript.commentNodeTypes,
            importNodeTypes: javascript.importNodeTypes.union(["import_statement"]),
            minimumFoldLines: 2
        )
    }()
    
    static let python = LanguageFoldConfig(
        language: "python",
        mappings: [
            FoldTypeMapping(nodeType: "function_definition", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "class_definition", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "decorated_definition", foldType: .function, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "try_statement", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
            FoldTypeMapping(nodeType: "with_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "match_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "dictionary", foldType: .genericBlock, labelExtractor: .custom("dict"), minimumLines: 3),
            FoldTypeMapping(nodeType: "list", foldType: .genericBlock, labelExtractor: .custom("list"), minimumLines: 3),
        ],
        commentNodeTypes: ["comment", "block_comment"],
        importNodeTypes: ["import_statement", "import_from_statement"],
        minimumFoldLines: 2
    )
    
    static let rust = LanguageFoldConfig(
        language: "rust",
        mappings: [
            FoldTypeMapping(nodeType: "function_item", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "struct_item", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_item", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "impl_item", foldType: .extension, labelExtractor: .namedChild("type"), minimumLines: 2),
            FoldTypeMapping(nodeType: "trait_item", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "mod_item", foldType: .extension, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "match_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "loop_expression", foldType: .controlFlow, labelExtractor: .custom("loop"), minimumLines: 2),
            FoldTypeMapping(nodeType: "for_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "closure_expression", foldType: .genericBlock, labelExtractor: .custom("closure"), minimumLines: 3),
        ],
        commentNodeTypes: ["line_comment", "block_comment"],
        importNodeTypes: ["use_declaration"],
        minimumFoldLines: 2
    )
    
    static let go = LanguageFoldConfig(
        language: "go",
        mappings: [
            FoldTypeMapping(nodeType: "function_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "method_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "type_declaration", foldType: .classOrStruct, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "select_statement", foldType: .controlFlow, labelExtractor: .custom("select"), minimumLines: 3),
            FoldTypeMapping(nodeType: "composite_literal", foldType: .genericBlock, labelExtractor: .firstLine, minimumLines: 3),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: ["import_declaration"],
        minimumFoldLines: 2
    )
    
    static let c = LanguageFoldConfig(
        language: "c",
        mappings: [
            FoldTypeMapping(nodeType: "function_definition", foldType: .function, labelExtractor: .namedChild("declarator"), minimumLines: 2),
            FoldTypeMapping(nodeType: "struct_specifier", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_specifier", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "union_specifier", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "do_statement", foldType: .controlFlow, labelExtractor: .custom("do"), minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "preproc_ifdef", foldType: .region, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "preproc_if", foldType: .region, labelExtractor: .firstLine, minimumLines: 2),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: ["preproc_include"],
        minimumFoldLines: 2
    )
    
    static let cpp: LanguageFoldConfig = {
        var mappings = c.mappings
        mappings.append(contentsOf: [
            FoldTypeMapping(nodeType: "class_specifier", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "namespace_definition", foldType: .extension, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "template_declaration", foldType: .genericBlock, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "try_statement", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
        ])
        return LanguageFoldConfig(
            language: "cpp",
            mappings: mappings,
            commentNodeTypes: c.commentNodeTypes,
            importNodeTypes: c.importNodeTypes.union(["using_declaration"]),
            minimumFoldLines: 2
        )
    }()
    
    static let java = LanguageFoldConfig(
        language: "java",
        mappings: [
            FoldTypeMapping(nodeType: "class_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "interface_declaration", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_declaration", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "method_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "constructor_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "enhanced_for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "try_statement", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
        ],
        commentNodeTypes: ["line_comment", "block_comment"],
        importNodeTypes: ["import_declaration"],
        minimumFoldLines: 2
    )
    
    static let php = LanguageFoldConfig(
        language: "php",
        mappings: [
            FoldTypeMapping(nodeType: "function_definition", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "method_declaration", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "class_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "interface_declaration", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "trait_declaration", foldType: .protocolDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "namespace_definition", foldType: .extension, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "foreach_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "switch_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "try_statement", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
            FoldTypeMapping(nodeType: "enum_declaration", foldType: .enumDeclaration, labelExtractor: .namedChild("name"), minimumLines: 2),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: ["use_declaration", "namespace_use_declaration"],
        minimumFoldLines: 2
    )
    
    static let ruby = LanguageFoldConfig(
        language: "ruby",
        mappings: [
            FoldTypeMapping(nodeType: "method", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "singleton_method", foldType: .function, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "class", foldType: .classOrStruct, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "module", foldType: .extension, labelExtractor: .namedChild("name"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "unless", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "for", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "case", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "begin", foldType: .controlFlow, labelExtractor: .custom("begin"), minimumLines: 2),
            FoldTypeMapping(nodeType: "do_block", foldType: .genericBlock, labelExtractor: .custom("do"), minimumLines: 2),
            FoldTypeMapping(nodeType: "block", foldType: .genericBlock, labelExtractor: .custom("block"), minimumLines: 3),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: ["call"],  // require/require_relative are method calls in Ruby
        minimumFoldLines: 2
    )
    
    static let kotlin = LanguageFoldConfig(
        language: "kotlin",
        mappings: [
            FoldTypeMapping(nodeType: "function_declaration", foldType: .function, labelExtractor: .namedChild("simple_identifier"), minimumLines: 2),
            FoldTypeMapping(nodeType: "class_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("type_identifier"), minimumLines: 2),
            FoldTypeMapping(nodeType: "object_declaration", foldType: .classOrStruct, labelExtractor: .namedChild("type_identifier"), minimumLines: 2),
            FoldTypeMapping(nodeType: "companion_object", foldType: .classOrStruct, labelExtractor: .custom("companion"), minimumLines: 2),
            FoldTypeMapping(nodeType: "if_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "when_expression", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 3),
            FoldTypeMapping(nodeType: "for_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "while_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "try_expression", foldType: .controlFlow, labelExtractor: .custom("try"), minimumLines: 2),
            FoldTypeMapping(nodeType: "lambda_literal", foldType: .genericBlock, labelExtractor: .custom("lambda"), minimumLines: 3),
        ],
        commentNodeTypes: ["line_comment", "multiline_comment"],
        importNodeTypes: ["import_header"],
        minimumFoldLines: 2
    )
    
    static let html = LanguageFoldConfig(
        language: "html",
        mappings: [
            FoldTypeMapping(nodeType: "element", foldType: .genericBlock, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "style_element", foldType: .genericBlock, labelExtractor: .custom("<style>"), minimumLines: 2),
            FoldTypeMapping(nodeType: "script_element", foldType: .genericBlock, labelExtractor: .custom("<script>"), minimumLines: 2),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: [],
        minimumFoldLines: 2
    )
    
    static let css = LanguageFoldConfig(
        language: "css",
        mappings: [
            FoldTypeMapping(nodeType: "rule_set", foldType: .genericBlock, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "media_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "keyframes_statement", foldType: .genericBlock, labelExtractor: .firstLine, minimumLines: 2),
            FoldTypeMapping(nodeType: "supports_statement", foldType: .controlFlow, labelExtractor: .firstLine, minimumLines: 2),
        ],
        commentNodeTypes: ["comment"],
        importNodeTypes: ["import_statement"],
        minimumFoldLines: 2
    )
    
    static let allConfigs: [String: LanguageFoldConfig] = [
        "swift": .swift,
        "javascript": .javascript,
        "typescript": .typescript,
        "tsx": .typescript,
        "jsx": .javascript,
        "python": .python,
        "rust": .rust,
        "go": .go,
        "c": .c,
        "cpp": .cpp,
        "c++": .cpp,
        "java": .java,
        "php": .php,
        "ruby": .ruby,
        "rb": .ruby,
        "kotlin": .kotlin,
        "kt": .kotlin,
        "html": .html,
        "htm": .html,
        "vue": .html,
        "svelte": .html,
        "css": .css,
        "scss": .css,
        "less": .css,
    ]
    
    static func forLanguage(_ language: String) -> LanguageFoldConfig? {
        allConfigs[language.lowercased()]
    }
}

// MARK: - TreeSitter Folding Engine

final class TreeSitterFoldingEngine {
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TreeSitterFolding")
    
    private let minimumFoldLines: Int
    private let enableImportGrouping: Bool
    private let enableCommentGrouping: Bool
    
    private(set) var lastDetectionTimeMs: Double = 0
    private(set) var lastNodeCount: Int = 0
    
    init(
        minimumFoldLines: Int = 2,
        enableImportGrouping: Bool = true,
        enableCommentGrouping: Bool = true
    ) {
        self.minimumFoldLines = minimumFoldLines
        self.enableImportGrouping = enableImportGrouping
        self.enableCommentGrouping = enableCommentGrouping
    }
    
    // MARK: - Detection from Syntax Tree
    
    func detectFoldRegions(
        tree: SyntaxTreeProvider,
        source: String
    ) -> [FoldRegion] {
        let startTime = CACurrentMediaTime()
        var regions: [FoldRegion] = []
        var nodeCount = 0
        
        guard let root = tree.rootNode else {
            Self.logger.warning("No root node in syntax tree")
            return []
        }
        
        guard let config = LanguageFoldConfig.forLanguage(tree.language) else {
            Self.logger.info("No fold config for language: \(tree.language), using fallback")
            return detectFallbackRegions(source: source)
        }
        
        let lines = source.components(separatedBy: "\n")
        
        walkTree(node: root, config: config, lines: lines, regions: &regions, nodeCount: &nodeCount)
        
        if enableImportGrouping {
            let importRegions = detectImportGroups(root: root, config: config, lines: lines)
            regions.append(contentsOf: importRegions)
        }
        
        if enableCommentGrouping {
            let commentRegions = detectCommentGroups(root: root, config: config, lines: lines)
            regions.append(contentsOf: commentRegions)
        }
        
        let markRegions = detectMarkRegions(lines: lines)
        regions.append(contentsOf: markRegions)
        
        regions.sort { $0.startLine < $1.startLine }
        regions = deduplicateRegions(regions)
        
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        lastDetectionTimeMs = elapsed
        lastNodeCount = nodeCount
        
        Self.logger.debug("Detected \(regions.count) fold regions in \(String(format: "%.1f", elapsed))ms (\(nodeCount) nodes)")
        
        return regions
    }
    
    /// Detect fold regions from source text using language-aware fallback.
    /// Uses brace matching enhanced with language-specific comment/import detection.
    func detectFoldRegions(
        source: String,
        language: String
    ) -> [FoldRegion] {
        let startTime = CACurrentMediaTime()
        let regions: [FoldRegion]
        
        if let config = LanguageFoldConfig.forLanguage(language) {
            // Use language-aware fallback that applies config's comment/import patterns
            regions = detectLanguageAwareFallbackRegions(source: source, config: config)
        } else {
            // No config for this language - pure brace matching
            regions = detectFallbackRegions(source: source)
        }
        
        lastDetectionTimeMs = (CACurrentMediaTime() - startTime) * 1000
        return regions
    }
    
    /// Language-aware fallback: brace matching + config-based comment/import grouping + MARK regions
    private func detectLanguageAwareFallbackRegions(
        source: String,
        config: LanguageFoldConfig
    ) -> [FoldRegion] {
        let lines = source.components(separatedBy: "\n")
        var regions: [FoldRegion] = []
        var braceStack: [(line: Int, indent: Int)] = []
        
        // Brace matching for block detection
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indent = line.count - line.drop(while: { $0 == " " || $0 == "\t" }).count
            
            if trimmed.hasSuffix("{") {
                braceStack.append((i, indent))
            }
            
            if trimmed.hasPrefix("}") {
                if let start = braceStack.popLast() {
                    if i - start.line >= minimumFoldLines {
                        // Try to classify the block using the opening line
                        let startLine = lines[start.line].trimmingCharacters(in: .whitespaces)
                        let foldType = classifyBlock(openingLine: startLine, config: config)
                        let label = extractBlockLabel(openingLine: startLine, foldType: foldType)
                        regions.append(FoldRegion(
                            startLine: start.line,
                            endLine: i,
                            isFolded: false,
                            type: foldType,
                            label: label
                        ))
                    }
                }
            }
        }
        
        // Python/Ruby-style indent-based block detection for languages without braces
        if config.language == "python" || config.language == "ruby" {
            let indentRegions = detectIndentBasedRegions(lines: lines, config: config)
            regions.append(contentsOf: indentRegions)
        }
        
        // Detect consecutive single-line comments as foldable groups
        if enableCommentGrouping {
            let commentRegions = detectCommentGroupsFallback(lines: lines, config: config)
            regions.append(contentsOf: commentRegions)
        }
        
        // Detect consecutive import lines as foldable groups
        if enableImportGrouping {
            let importRegions = detectImportGroupsFallback(lines: lines, config: config)
            regions.append(contentsOf: importRegions)
        }
        
        // MARK/region detection
        regions.append(contentsOf: detectMarkRegions(lines: lines))
        
        regions.sort { $0.startLine < $1.startLine }
        return deduplicateRegions(regions)
    }
    
    /// Classify a block by examining its opening line against known patterns
    private func classifyBlock(openingLine: String, config: LanguageFoldConfig) -> FoldType {
        let lower = openingLine.lowercased()
        
        // Function patterns
        if lower.hasPrefix("func ") || lower.hasPrefix("function ") || lower.contains("fun ") ||
           lower.hasPrefix("def ") || lower.hasPrefix("fn ") || lower.contains("-> {") {
            return .function
        }
        // Class/struct patterns
        if lower.hasPrefix("class ") || lower.hasPrefix("struct ") || lower.hasPrefix("actor ") {
            return .classOrStruct
        }
        // Enum
        if lower.hasPrefix("enum ") {
            return .enumDeclaration
        }
        // Protocol/interface
        if lower.hasPrefix("protocol ") || lower.hasPrefix("interface ") || lower.hasPrefix("trait ") {
            return .protocolDeclaration
        }
        // Extension/impl
        if lower.hasPrefix("extension ") || lower.hasPrefix("impl ") || lower.hasPrefix("module ") || lower.hasPrefix("namespace ") {
            return .extension
        }
        // Control flow
        if lower.hasPrefix("if ") || lower.hasPrefix("else ") || lower.hasPrefix("else{") ||
           lower.hasPrefix("for ") || lower.hasPrefix("while ") || lower.hasPrefix("switch ") ||
           lower.hasPrefix("do ") || lower.hasPrefix("do{") || lower.hasPrefix("guard ") ||
           lower.hasPrefix("try ") || lower.hasPrefix("catch ") || lower.hasPrefix("case ") ||
           lower.hasPrefix("foreach ") || lower.hasPrefix("unless ") || lower.hasPrefix("when ") {
            return .controlFlow
        }
        // Comment block
        if lower.hasPrefix("/*") || lower.hasPrefix("/**") {
            return .comment
        }
        return .genericBlock
    }
    
    /// Extract a human-readable label from the opening line of a block
    private func extractBlockLabel(openingLine: String, foldType: FoldType) -> String? {
        let trimmed = openingLine.trimmingCharacters(in: .whitespaces)
        // Extract name after keyword
        let keywords = ["func ", "function ", "class ", "struct ", "enum ", "protocol ",
                        "interface ", "extension ", "impl ", "trait ", "module ", "namespace ",
                        "def ", "fn ", "fun ", "actor ", "object "]
        for kw in keywords {
            if trimmed.lowercased().hasPrefix(kw) {
                let rest = String(trimmed.dropFirst(kw.count))
                let name = rest.prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "<" })
                if !name.isEmpty { return String(name) }
            }
        }
        return nil
    }
    
    /// Detect indent-based fold regions for Python/Ruby
    private func detectIndentBasedRegions(lines: [String], config: LanguageFoldConfig) -> [FoldRegion] {
        var regions: [FoldRegion] = []
        let blockStarters = ["def ", "class ", "if ", "elif ", "else:", "for ", "while ",
                             "try:", "except ", "except:", "finally:", "with ", "async def ",
                             "async for ", "async with ", "match ", "case "]
        
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            let isStarter = blockStarters.contains(where: { trimmed.hasPrefix($0) }) && trimmed.hasSuffix(":")
            guard isStarter else { continue }
            
            let baseIndent = line.prefix(while: { $0 == " " || $0 == "\t" }).count
            var endLine = i
            
            for j in (i + 1)..<lines.count {
                let nextLine = lines[j]
                let nextTrimmed = nextLine.trimmingCharacters(in: .whitespaces)
                if nextTrimmed.isEmpty { continue }  // Skip blank lines
                let nextIndent = nextLine.prefix(while: { $0 == " " || $0 == "\t" }).count
                if nextIndent > baseIndent {
                    endLine = j
                } else {
                    break
                }
            }
            
            if endLine - i >= config.minimumFoldLines {
                let foldType = classifyBlock(openingLine: trimmed, config: config)
                regions.append(FoldRegion(
                    startLine: i,
                    endLine: endLine,
                    isFolded: false,
                    type: foldType,
                    label: extractBlockLabel(openingLine: trimmed, foldType: foldType)
                ))
            }
        }
        return regions
    }
    
    /// Detect comment groups using line-by-line patterns
    private func detectCommentGroupsFallback(lines: [String], config: LanguageFoldConfig) -> [FoldRegion] {
        var commentLines: [Int] = []
        let commentPrefixes = ["//", "#", "--", "/*", "*", "*/"]
        
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if commentPrefixes.contains(where: { trimmed.hasPrefix($0) }) {
                commentLines.append(i)
            }
        }
        return groupConsecutiveLines(commentLines, type: .comment, label: "comments", minGroup: 3)
    }
    
    /// Detect import groups using line-by-line patterns
    private func detectImportGroupsFallback(lines: [String], config: LanguageFoldConfig) -> [FoldRegion] {
        var importLines: [Int] = []
        let importKeywords = ["import ", "from ", "use ", "require(", "#include", "using ", "@import"]
        
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if importKeywords.contains(where: { trimmed.hasPrefix($0) }) {
                importLines.append(i)
            }
        }
        return groupConsecutiveLines(importLines, type: .importStatement, label: "imports", minGroup: 3)
    }
    
    func updateFoldRegions(
        tree: SyntaxTreeProvider,
        source: String,
        editedLineRange: ClosedRange<Int>,
        existingRegions: [FoldRegion]
    ) -> [FoldRegion] {
        let startTime = CACurrentMediaTime()
        
        let expandedStart = max(0, editedLineRange.lowerBound - 5)
        let expandedEnd = min(source.components(separatedBy: "\n").count - 1, editedLineRange.upperBound + 5)
        
        var kept = existingRegions.filter { region in
            region.endLine < expandedStart || region.startLine > expandedEnd
        }
        
        let fullRegions = detectFoldRegions(tree: tree, source: source)
        
        let newInRange = fullRegions.filter { region in
            region.startLine >= expandedStart && region.startLine <= expandedEnd ||
            region.endLine >= expandedStart && region.endLine <= expandedEnd
        }
        
        kept.append(contentsOf: newInRange)
        kept.sort { $0.startLine < $1.startLine }
        kept = deduplicateRegions(kept)
        
        lastDetectionTimeMs = (CACurrentMediaTime() - startTime) * 1000
        return kept
    }
    
    // MARK: - Tree Walking
    
    private func walkTree(
        node: SyntaxTreeNode,
        config: LanguageFoldConfig,
        lines: [String],
        regions: inout [FoldRegion],
        nodeCount: inout Int
    ) {
        nodeCount += 1
        
        if let mapping = config.mappings.first(where: { $0.nodeType == node.type }) {
            let lineSpan = node.endLine - node.startLine
            if lineSpan >= mapping.minimumLines {
                let label = extractLabel(from: node, using: mapping.labelExtractor, lines: lines)
                let region = FoldRegion(
                    startLine: node.startLine,
                    endLine: node.endLine,
                    isFolded: false,
                    type: mapping.foldType,
                    label: label
                )
                regions.append(region)
            }
        }
        
        if config.commentNodeTypes.contains(node.type) {
            let lineSpan = node.endLine - node.startLine
            if lineSpan >= 1 {
                let region = FoldRegion(
                    startLine: node.startLine,
                    endLine: node.endLine,
                    isFolded: false,
                    type: .comment,
                    label: "comment"
                )
                regions.append(region)
            }
        }
        
        for child in node.children {
            walkTree(node: child, config: config, lines: lines, regions: &regions, nodeCount: &nodeCount)
        }
    }
    
    // MARK: - Label Extraction
    
    private func extractLabel(
        from node: SyntaxTreeNode,
        using extractor: FoldTypeMapping.LabelExtractor,
        lines: [String]
    ) -> String? {
        switch extractor {
        case .namedChild(let childName):
            return node.namedChild(childName).map { extractNodeText($0, lines: lines) }
        case .nodeType:
            return node.type
        case .firstLine:
            guard node.startLine < lines.count else { return nil }
            return lines[node.startLine].trimmingCharacters(in: .whitespaces)
        case .custom(let label):
            return label
        }
    }
    
    private func extractNodeText(_ node: SyntaxTreeNode, lines: [String]) -> String {
        guard node.startLine < lines.count else { return "" }
        let line = lines[node.startLine]
        let startIdx = line.index(line.startIndex, offsetBy: min(node.startColumn, line.count))
        if node.startLine == node.endLine {
            let endIdx = line.index(line.startIndex, offsetBy: min(node.endColumn, line.count))
            return String(line[startIdx..<endIdx])
        }
        return String(line[startIdx...])
    }
    
    // MARK: - Import & Comment Grouping
    
    private func detectImportGroups(
        root: SyntaxTreeNode,
        config: LanguageFoldConfig,
        lines: [String]
    ) -> [FoldRegion] {
        var importLines: [Int] = []
        collectNodes(root: root, types: config.importNodeTypes) { node in
            importLines.append(node.startLine)
        }
        importLines.sort()
        return groupConsecutiveLines(importLines, type: .importStatement, label: "imports", minGroup: 3)
    }
    
    private func detectCommentGroups(
        root: SyntaxTreeNode,
        config: LanguageFoldConfig,
        lines: [String]
    ) -> [FoldRegion] {
        var singleLineCommentLines: [Int] = []
        collectNodes(root: root, types: config.commentNodeTypes) { node in
            if node.startLine == node.endLine {
                singleLineCommentLines.append(node.startLine)
            }
        }
        singleLineCommentLines.sort()
        return groupConsecutiveLines(singleLineCommentLines, type: .comment, label: "comments", minGroup: 3)
    }
    
    private func collectNodes(
        root: SyntaxTreeNode,
        types: Set<String>,
        visitor: (SyntaxTreeNode) -> Void
    ) {
        if types.contains(root.type) {
            visitor(root)
        }
        for child in root.children {
            collectNodes(root: child, types: types, visitor: visitor)
        }
    }
    
    private func groupConsecutiveLines(
        _ lines: [Int],
        type: FoldType,
        label: String,
        minGroup: Int
    ) -> [FoldRegion] {
        guard lines.count >= minGroup else { return [] }
        
        var regions: [FoldRegion] = []
        var groupStart = lines[0]
        var groupEnd = lines[0]
        
        for i in 1..<lines.count {
            if lines[i] == groupEnd + 1 || lines[i] == groupEnd + 2 {
                groupEnd = lines[i]
            } else {
                if groupEnd - groupStart + 1 >= minGroup {
                    regions.append(FoldRegion(
                        startLine: groupStart,
                        endLine: groupEnd,
                        isFolded: false,
                        type: type,
                        label: label
                    ))
                }
                groupStart = lines[i]
                groupEnd = lines[i]
            }
        }
        
        if groupEnd - groupStart + 1 >= minGroup {
            regions.append(FoldRegion(
                startLine: groupStart,
                endLine: groupEnd,
                isFolded: false,
                type: type,
                label: label
            ))
        }
        
        return regions
    }
    
    // MARK: - Mark/Region Detection
    
    private func detectMarkRegions(lines: [String]) -> [FoldRegion] {
        var regions: [FoldRegion] = []
        var regionStack: [(line: Int, label: String)] = []
        
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#region") || trimmed.hasPrefix("// MARK:") || trimmed.hasPrefix("# MARK:") {
                let label = trimmed
                    .replacingOccurrences(of: "#region ", with: "")
                    .replacingOccurrences(of: "// MARK: - ", with: "")
                    .replacingOccurrences(of: "// MARK:", with: "")
                    .replacingOccurrences(of: "# MARK: - ", with: "")
                    .replacingOccurrences(of: "# MARK:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                regionStack.append((i, label))
            }
            
            if trimmed.hasPrefix("#endregion") {
                if let start = regionStack.popLast() {
                    regions.append(FoldRegion(
                        startLine: start.line,
                        endLine: i,
                        isFolded: false,
                        type: .region,
                        label: start.label
                    ))
                }
            }
        }
        
        // Auto-close MARK regions at the next MARK or EOF
        var markLines: [(line: Int, label: String)] = []
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("MARK:") {
                let label = trimmed
                    .replacingOccurrences(of: "// MARK: - ", with: "")
                    .replacingOccurrences(of: "// MARK: ", with: "")
                    .replacingOccurrences(of: "# MARK: - ", with: "")
                    .replacingOccurrences(of: "# MARK: ", with: "")
                    .trimmingCharacters(in: .whitespaces)
                markLines.append((i, label))
            }
        }
        
        for i in 0..<markLines.count {
            let start = markLines[i].line
            let end = i + 1 < markLines.count ? markLines[i + 1].line - 1 : lines.count - 1
            if end - start >= 2 {
                regions.append(FoldRegion(
                    startLine: start,
                    endLine: end,
                    isFolded: false,
                    type: .region,
                    label: markLines[i].label
                ))
            }
        }
        
        return regions
    }
    
    // MARK: - Fallback (Brace Matching)
    
    private func detectFallbackRegions(source: String) -> [FoldRegion] {
        let lines = source.components(separatedBy: "\n")
        var regions: [FoldRegion] = []
        var braceStack: [(line: Int, indent: Int)] = []
        
        for (i, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indent = line.count - line.drop(while: { $0 == " " || $0 == "\t" }).count
            
            if trimmed.hasSuffix("{") {
                braceStack.append((i, indent))
            }
            
            if trimmed.hasPrefix("}") {
                if let start = braceStack.popLast() {
                    if i - start.line >= minimumFoldLines {
                        regions.append(FoldRegion(
                            startLine: start.line,
                            endLine: i,
                            isFolded: false,
                            type: .genericBlock,
                            label: nil
                        ))
                    }
                }
            }
        }
        
        regions.append(contentsOf: detectMarkRegions(lines: lines))
        return regions
    }
    
    // MARK: - Deduplication
    
    private func deduplicateRegions(_ regions: [FoldRegion]) -> [FoldRegion] {
        var result: [FoldRegion] = []
        var seen = Set<String>()
        
        for region in regions {
            let key = "\(region.startLine)-\(region.endLine)"
            if !seen.contains(key) {
                seen.insert(key)
                result.append(region)
            }
        }
        
        return result
    }
}
