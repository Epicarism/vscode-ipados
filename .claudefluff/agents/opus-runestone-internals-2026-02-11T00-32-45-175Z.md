# Agent: opus-runestone-internals
**Status:** done
**Tokens:** 12,211
**Cost:** $0.0000
**Time:** 2026-02-11T00:32:45.175Z

## Task
CRITICAL: Deep dive into Runestone library internals. Search ~/Library/Developer/Xcode/DerivedData for ALL Runestone Swift files related to syntax highlighting. Find: 1) How HighlightName enum works 2) How textColorFor delegate is invoked 3) The full highlight application pipeline. Read key files completely.

## Response
I'll search the DerivedData folder for Runestone syntax highlighting files. Let me start by exploring the directory structure.

>>>TOOL list_dir
{"path": "~/Library/Developer/Xcode/DerivedData"}
>>>END

Let me try with the expanded path:

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Developer/Xcode/DerivedData"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/Library/Developer/Xcode/DerivedData" not found


Let me search for Runestone files in the project and common package cache locations:

>>>TOOL search
{"query": "HighlightName", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 20 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:107: let normalizedName = normalizeHighlightName(highlightName)
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:205: private func normalizeHighlightName(_ name: String) -> String {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:221: let normalizedName = normalizeHighlightName(highlightName)
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:587: func textColor(for rawHighlightName: String) -> UIColor? {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:590: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:659: func fontTraits(for rawHighlightName: String) -> FontTraits {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:660: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:587: func textColor(for rawHighlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:590: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:659: func fontTraits(for rawHighlightName: String) -> FontTraits {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:660: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:586: func textColor(for rawHighlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:589: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:592: // print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:613: if rawHighlightName == "string" {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:688: func fontTraits(for rawHighlightName: String) -> FontTraits {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:689: let highlightName = rawHighlightName.lowercased()
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:107: let normalizedName = normalizeHighlightName(highlightName)
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:205: private func normalizeHighlightName(_ name: String) -> String {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:221: let normalizedName = normalizeHighlightName(highlightName)


Let me search for the Runestone package in Swift Package Manager cache locations:

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Developer/Xcode/DerivedData"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/Library/Developer/Xcode/DerivedData" not found


Let me search for Runestone package files in common SPM locations:

>>>TOOL search
{"query": "import Runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:11: import Runestone


Let me look for the SourcePackages folder in the project:

>>>TOOL list_dir
{"path": "/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS" not found


>>>TOOL list_dir
{"path": "/Users/danielswagg/PLAYGROUND/vscode-ipados"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/PLAYGROUND/vscode-ipados" not found


Let me check the current directory:

>>>TOOL list_dir
{"path": "."}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
📁 .garbage/
📁 .patch-backups/
📁 .vscode/
📁 Docs/
📁 Extensions/
📁 logs/
📁 Models/
📁 Services/
📁 test-results/
📁 Tests/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOSUITests/
   .gitignore
   build.log
   FULL_FEATURE_TEST_PLAN.md
   idb_testing_report.md
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
(cached)


>>>TOOL list_dir
{"path": "/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/PLAYGROUND/vscode-ipados/VSCodeiPadOS" not found


>>>TOOL list_dir
{"path": "."}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
📁 .garbage/
📁 .patch-backups/
📁 .vscode/
📁 Docs/
📁 Extensions/
📁 logs/
📁 Models/
📁 Services/
📁 test-results/
📁 Tests/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOSUITests/
   .gitignore
   build.log
   FULL_FEATURE_TEST_PLAN.md
   idb_testing_report.md
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md
(cached)


>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   build_output.log
   build_output2.log
   build.log
   FeatureFlags.swift
   Info.plist
   Package.swift
   TreeSitterLanguages.swift
   TypingLagTest.swift
(cached)


>>>TOOL search
{"query": "protocol.*Theme", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "protocol.*Theme"


>>>TOOL read_file
{"path": "Package.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/Package.swift (lines 1-41 of 41)
────────────────────────────────────────
1: // swift-tools-version:5.9
2: // Package.swift for SwiftNIO SSH dependency
3: // Add this package to your Xcode project via:
4: // File -> Add Package Dependencies -> Enter URL:
5: // https://github.com/apple/swift-nio-ssh
6: 
7: import PackageDescription
8: 
9: let package = Package(
10:     name: "VSCodeiPadOS",
11:     platforms: [
12:         .iOS(.v15),
13:         .macOS(.v12)
14:     ],
15:     products: [
16:         .library(
17:             name: "VSCodeiPadOS",
18:             targets: ["VSCodeiPadOS"]
19:         ),
20:     ],
21:     dependencies: [
22:         // SwiftNIO SSH - Pure Swift SSH implementation
23:         .package(url: "https://github.com/apple/swift-nio-ssh", from: "0.8.0"),
24:         
25:         // SwiftNIO - Required by swift-nio-ssh
26:         .package(url: "https://github.com/apple/swift-nio", from: "2.50.0"),
27:     ],
28:     targets: [
29:         .target(
30:             name: "VSCodeiPadOS",
31:             dependencies: [
32:                 .product(name: "NIOSSH", package: "swift-nio-ssh"),
33:                 .product(name: "NIO", package: "swift-nio"),
34:                 .product(name: "NIOCore", package: "swift-nio"),
35:                 .product(name: "NIOPosix", package: "swift-nio"),
36:             ],
37:             path: "VSCodeiPadOS"
38:         ),
39:     ]
40: )
41: 


>>>TOOL search
{"query": "Runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 30 matches:
VSCodeiPadOS/FeatureFlags.swift:5: /// Use Runestone editor instead of legacy regex-based highlighting
VSCodeiPadOS/FeatureFlags.swift:7: static let useRunestoneEditor = true
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:2: //  RunestoneThemeAdapter.swift
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:5: //  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:12: // MARK: - VSCodeRunestoneTheme
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:14: /// A Runestone Theme implementation that adapts our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:15: /// to Runestone's expected theme protocol for syntax highlighting.
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:16: public final class VSCodeRunestoneTheme: Runestone.Theme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:91: /// Creates a Runestone theme from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:282: // MARK: - RunestoneThemeAdapter
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:284: /// Static helper for creating Runestone themes from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:285: public enum RunestoneThemeAdapter {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:287: /// Creates a Runestone Theme from our app's Theme struct
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:291: /// - Returns: A Runestone-compatible Theme
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:292: public static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:293: VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:296: /// Creates a Runestone Theme from our app's Theme with customized settings
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:300: /// - Returns: A VSCodeRunestoneTheme instance
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:304: ) -> VSCodeRunestoneTheme {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:305: VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:311: /// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:2: //  RunestoneEditorView.swift
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:5: //  High-performance code editor using Runestone with TreeSitter syntax highlighting.
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:11: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:13: // Feature flag now uses centralized FeatureFlags.useRunestoneEditor
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:15: /// UIViewRepresentable wrapper for Runestone's TextView
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:17: struct RunestoneEditorView: UIViewRepresentable {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:91: let theme = makeRunestoneTheme()
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:126: let theme = makeRunestoneTheme()


>>>TOOL search
{"query": "textColor.*highlightName", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "textColor.*highlightName"


>>>TOOL search
{"query": "func textColor", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 9 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:105: public func textColor(for highlightName: String) -> UIColor? {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:185: private func textColorByPrefix(_ highlightName: String) -> UIColor? {
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:587: func textColor(for rawHighlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:105: func textColor(for highlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:185: private func textColorByPrefix(_ highlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:105: public func textColor(for highlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:185: private func textColorByPrefix(_ highlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:587: func textColor(for rawHighlightName: String) -> UIColor? {
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:586: func textColor(for rawHighlightName: String) -> UIColor? {


Let me look for the Runestone package in SPM cache and check the project structure:

>>>TOOL list_dir
{"path": "/Users/danielswagg/Library/Caches/org.swift.swiftpm"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "/Users/danielswagg/Library/Caches/org.swift.swiftpm" not found


>>>TOOL list_dir
{"path": "VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   build_output.log
   build_output2.log
   build.log
   FeatureFlags.swift
   Info.plist
   Package.swift
   TreeSitterLanguages.swift
   TypingLagTest.swift


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus.bak/
📁 Models/
📁 Resources/
📁 Services/
📁 Tests/
📁 UITests/
📁 Utils/
📁 Views/
   .tooling_note.txt
   ContentView_shift_arrow.patch
   ContentView.swift
   ContentView.swift.bak
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus.bak/
📁 Models/
📁 Resources/
📁 Services/
📁 Tests/
📁 UITests/
📁 Utils/
📁 Views/
   .tooling_note.txt
   ContentView_shift_arrow.patch
   ContentView.swift
   ContentView.swift.bak
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md
(cached)


>>>TOOL list_dir
{"path": "VSCodeiPadOS.xcodeproj"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "VSCodeiPadOS.xcodeproj" not found


>>>TOOL search
{"query": "SourcePackages", "glob": "**/project.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SourcePackages"


>>>TOOL search
{"query": "struct HighlightName", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "struct HighlightName"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift (lines 1-315 of 315)
────────────────────────────────────────
1: //
2: //  RunestoneThemeAdapter.swift
3: //  VSCodeiPadOS
4: //
5: //  Maps our Theme struct to Runestone's Theme protocol for syntax highlighting
6: //
7: 
8: import UIKit
9: import SwiftUI
10: import Runestone
11: 
12: // MARK: - VSCodeRunestoneTheme
13: 
14: /// A Runestone Theme implementation that adapts our app's Theme struct
15: /// to Runestone's expected theme protocol for syntax highlighting.
16: final class VSCodeRunestoneTheme: Runestone.Theme {
17:     
18:     // MARK: - Properties
19:     
20:     private let theme: Models.Theme
21:     private let fontSize: CGFloat
22:     
23:     // MARK: - Required Theme Properties
24:     
25:     var font: UIFont {
26:         .monospacedSystemFont(ofSize: fontSize, weight: .regular)
27:     }
28:     
29:     var textColor: UIColor {
30:         UIColor(theme.editorForeground)
31:     }
32:     
33:     var gutterBackgroundColor: UIColor {
34:         UIColor(theme.sidebarBackground)
35:     }
36:     
37:     var gutterHairlineColor: UIColor {
38:         UIColor(theme.sidebarBackground).withAlphaComponent(0.5)
39:     }
40:     
41:     var gutterHairlineWidth: CGFloat {
42:         1.0 / UIScreen.main.scale
43:     }
44:     
45:     var lineNumberColor: UIColor {
46:         UIColor(theme.lineNumber)
47:     }
48:     
49:     var lineNumberFont: UIFont {
50:         .monospacedSystemFont(ofSize: fontSize, weight: .regular)
51:     }
52:     
53:     var selectedLineBackgroundColor: UIColor {
54:         UIColor(theme.currentLineHighlight)
55:     }
56:     
57:     var selectedLinesLineNumberColor: UIColor {
58:         UIColor(theme.lineNumberActive)
59:     }
60:     
61:     var selectedLinesGutterBackgroundColor: UIColor {
62:         UIColor(theme.sidebarBackground)
63:     }
64:     
65:     var invisibleCharactersColor: UIColor {
66:         UIColor(theme.lineNumber).withAlphaComponent(0.4)
67:     }
68:     
69:     var pageGuideHairlineColor: UIColor {
70:         UIColor(theme.indentGuide)
71:     }
72:     
73:     var pageGuideHairlineWidth: CGFloat {
74:         1.0 / UIScreen.main.scale
75:     }
76:     
77:     var pageGuideBackgroundColor: UIColor {
78:         UIColor(theme.editorBackground).withAlphaComponent(0.5)
79:     }
80:     
81:     var markedTextBackgroundColor: UIColor {
82:         UIColor(theme.selection)
83:     }
84:     
85:     var markedTextBackgroundCornerRadius: CGFloat {
86:         2.0
87:     }
88:     
89:     // MARK: - Initialization
90:     
91:     /// Creates a Runestone theme from our app's Theme struct
92:     /// - Parameters:
93:     ///   - theme: Our app's Theme struct containing colors and styles
94:     ///   - fontSize: Font size for editor text (default: 14)
95:     init(theme: Models.Theme, fontSize: CGFloat = 14) {
96:         self.theme = theme
97:         self.fontSize = fontSize
98:     }
99:     
100:     // MARK: - Syntax Highlighting
101:     
102:     /// Returns the text color for a given Tree-sitter highlight name
103:     /// - Parameter highlightName: The Tree-sitter capture name (e.g., "keyword", "string")
104:     /// - Returns: The UIColor to use for that highlight, or nil for default color
105:     func textColor(for highlightName: String) -> UIColor? {
106:         // Handle compound highlight names like "keyword.return" by checking prefixes
107:         let normalizedName = normalizeHighlightName(highlightName)
108:         
109:         switch normalizedName {
110:         // Keywords (control flow, storage, etc.)
111:         case "keyword", "keyword.control", "keyword.return", "keyword.function",
112:              "keyword.operator", "keyword.import", "keyword.storage", "keyword.type":
113:             return UIColor(theme.keyword)
114:             
115:         // Strings and string-like content
116:         case "string", "string.special", "string.escape", "string.regex":
117:             return UIColor(theme.string)
118:             
119:         // Comments
120:         case "comment", "comment.line", "comment.block", "comment.documentation":
121:             return UIColor(theme.comment)
122:             
123:         // Functions and method calls
124:         case "function", "function.call", "function.method", "function.builtin",
125:              "method", "method.call":
126:             return UIColor(theme.function)
127:             
128:         // Types, classes, and type-like constructs
129:         case "type", "type.builtin", "type.definition", "type.qualifier",
130:              "class", "struct", "enum", "interface", "namespace":
131:             return UIColor(theme.type)
132:             
133:         // Variables and properties
134:         case "variable", "variable.parameter", "variable.member",
135:              "property", "property.definition", "field":
136:             return UIColor(theme.variable)
137:             
138:         // Variable builtins (self, this, super)
139:         case "variable.builtin", "variable.language":
140:             return UIColor(theme.keyword).withAlphaComponent(0.9)
141:             
142:         // Numbers and numeric constants
143:         case "number", "number.float", "float", "integer":
144:             return UIColor(theme.number)
145:             
146:         // Constants
147:         case "constant", "constant.builtin", "constant.character", "boolean":
148:             return UIColor(theme.number)
149:             
150:         // Constructors
151:         case "constructor":
152:             return UIColor(theme.function)
153:             
154:         // Operators and punctuation
155:         case "operator":
156:             return UIColor(theme.editorForeground)
157:             
158:         case "punctuation", "punctuation.bracket", "punctuation.delimiter",
159:              "punctuation.special":
160:             return UIColor(theme.editorForeground).withAlphaComponent(0.8)
161:             
162:         // Tags (HTML/XML)
163:         case "tag", "tag.builtin":
164:             return UIColor(theme.keyword)
165:             
166:         // Attributes
167:         case "attribute", "attribute.builtin":
168:             return UIColor(theme.function)
169:             
170:         // Labels
171:         case "label":
172:             return UIColor(theme.type)
173:             
174:         // Embedded code (like template literals)
175:         case "embedded":
176:             return UIColor(theme.string)
177:             
178:         default:
179:             // For unrecognized names, try to match by prefix
180:             return textColorByPrefix(highlightName)
181:         }
182:     }
183:     
184:     /// Attempts to find a color by checking highlight name prefixes
185:     private func textColorByPrefix(_ highlightName: String) -> UIColor? {
186:         if highlightName.hasPrefix("keyword") {
187:             return UIColor(theme.keyword)
188:         } else if highlightName.hasPrefix("string") {
189:             return UIColor(theme.string)
190:         } else if highlightName.hasPrefix("comment") {
191:             return UIColor(theme.comment)
192:         } else if highlightName.hasPrefix("function") || highlightName.hasPrefix("method") {
193:             return UIColor(theme.function)
194:         } else if highlightName.hasPrefix("type") || highlightName.hasPrefix("class") {
195:             return UIColor(theme.type)
196:         } else if highlightName.hasPrefix("variable") || highlightName.hasPrefix("property") {
197:             return UIColor(theme.variable)
198:         } else if highlightName.hasPrefix("number") || highlightName.hasPrefix("constant") {
199:             return UIColor(theme.number)
200:         }
201:         return nil
202:     }
203:     
204:     /// Normalizes a highlight name by converting it to lowercase and trimming whitespace
205:     private func normalizeHighlightName(_ name: String) -> String {
206:         name.lowercased().trimmingCharacters(in: .whitespaces)
207:     }
208:     
209:     /// Returns the font for a given highlight name (optional override)
210:     /// - Parameter highlightName: The Tree-sitter capture name
211:     /// - Returns: A custom font, or nil to use the default font
212:     func font(for highlightName: String) -> UIFont? {
213:         // Use default font for all highlights - traits will modify it
214:         return nil
215:     }
216:     
217:     /// Returns font traits (bold, italic) for a given highlight name
218:     /// - Parameter highlightName: The Tree-sitter capture name
219:     /// - Returns: FontTraits to apply to the text
220:     func fontTraits(for highlightName: String) -> FontTraits {
221:         let normalizedName = normalizeHighlightName(highlightName)
222:         
223:         switch normalizedName {
224:         // Keywords are bold
225:         case let name where name.hasPrefix("keyword"):
226:             return .bold
227:             
228:         // Comments are italic
229:         case let name where name.hasPrefix("comment"):
230:             return .italic
231:             
232:         // Type definitions can be bold
233:         case "type.definition", "class", "struct", "enum", "interface":
234:             return .bold
235:             
236:         // Storage modifiers (static, const, etc.) are italic
237:         case "storage", "storage.modifier":
238:             return .italic
239:             
240:         default:
241:             return []
242:         }
243:     }
244:     
245:     /// Returns a shadow for a given highlight name (optional)
246:     /// - Parameter highlightName: The Tree-sitter capture name
247:     /// - Returns: An NSShadow to apply, or nil for no shadow
248:     func shadow(for highlightName: String) -> NSShadow? {
249:         // No shadows by default - can be customized if needed
250:         return nil
251:     }
252:     
253:     /// Returns highlighted range styling for search results (iOS 16+)
254:     @available(iOS 16.0, *)
255:     func highlightedRange(
256:         forFoundTextRange foundTextRange: NSRange,
257:         ofStyle style: UITextSearchFoundTextStyle
258:     ) -> HighlightedRange? {
259:         switch style {
260:         case .found:
261:             // Background for all matches
262:             return HighlightedRange(
263:                 range: foundTextRange,
264:                 color: UIColor(theme.selection).withAlphaComponent(0.4),
265:                 cornerRadius: 2
266:             )
267:         case .highlighted:
268:             // Background for the current/active match
269:             return HighlightedRange(
270:                 range: foundTextRange,
271:                 color: UIColor(theme.selection),
272:                 cornerRadius: 2
273:             )
274:         case .normal:
275:             return nil
276:         @unknown default:
277:             return nil
278:         }
279:     }
280: }
281: 
282: // MARK: - RunestoneThemeAdapter
283: 
284: /// Static helper for creating Runestone themes from our app's Theme struct
285: public enum RunestoneThemeAdapter {
286:     
287:     /// Creates a Runestone Theme from our app's Theme struct
288:     /// - Parameters:
289:     ///   - theme: The app's Theme to convert
290:     ///   - fontSize: Font size for the editor (default: 14)
291:     /// - Returns: A Runestone-compatible Theme
292:     static func theme(from theme: Models.Theme, fontSize: CGFloat = 14) -> Runestone.Theme {
293:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
294:     }
295:     
296:     /// Creates a Runestone Theme from our app's Theme with customized settings
297:     /// - Parameters:
298:     ///   - theme: The app's Theme to convert
299:     ///   - fontSize: Font size for the editor
300:     /// - Returns: A VSCodeRunestoneTheme instance
301:     static func createTheme(
302:         from theme: Models.Theme,
303:         fontSize: CGFloat = 14
304:     ) -> VSCodeRunestoneTheme {
305:         VSCodeRunestoneTheme(theme: theme, fontSize: fontSize)
306:     }
307: }
308: 
309: // MARK: - Theme Namespace Alias
310: 
311: /// Namespace alias to avoid conflicts between our Theme model and Runestone's Theme protocol
312: enum Models {
313:     typealias Theme = VSCodeiPadOS.Theme
314: }
315: 


Let me search for the Runestone package in SPM cache and Xcode project locations:

>>>TOOL search
{"query": "protocol Theme", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "protocol Theme"


>>>TOOL list_dir
{"path": "VSCodeiPadOS.xcodeproj"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "VSCodeiPadOS.xcodeproj" not found


>>>TOOL search
{"query": "import Runestone", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 6 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/.garbage/1770744061015/RunestoneEditorView.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:10: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView 2.swift:11: import Runestone
VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift:11: import Runestone


>>>TOOL list_dir
{"path": "VSCodeiPadOS.xcodeproj"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory "VSCodeiPadOS.xcodeproj" not found


>>>TOOL search
{"query": "HighlightedRange", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 9 matches:
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:258: ) -> HighlightedRange? {
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:262: return HighlightedRange(
VSCodeiPadOS/.garbage/1770744061015/RunestoneThemeAdapter.swift:269: return HighlightedRange(
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:258: ) -> HighlightedRange? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:262: return HighlightedRange(
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift:269: return HighlightedRange(
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:258: ) -> HighlightedRange? {
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:262: return HighlightedRange(
VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter 2.swift:269: return HighlightedRange(


Let me search the web for Runestone library documentation and source code to understand the internals:

>>>TOOL web_search
{"query": "Runestone Swift library Theme protocol textColor highlightName syntax highlighting"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone Swift library Theme protocol textColor highlightName syntax highlighting" (10 results):

1. **Creating a Theme | Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/creatingatheme/
   Take a look at the documentation of the Theme protocol to get an overview of what aspects of TextView can be customized. Syntax Highlighting Text The theme determines the text styling and colors to use when syntax highlighting text. Implement the following methods on Theme to specify the text styling and color of syntax highlighted text. font(for:)

2. **Runestone SwiftUI Example - GitHub**
   https://github.com/rosiebunnybear/RunestoneSwiftUIExample
   Text editing: Full-featured code editor with syntax highlighting for JavaScript Theme switching: Multiple built-in themes (Tomorrow, Tomorrow Night, One Dark, Plain Text)

3. **Runestone - Swift Package Registry**
   https://swiftpackageregistry.com/simonbs/Runestone
   👋 Welcome to Runestone - a performant plain text editor for iOS with code editing features Runestone uses GitHub&#x27;s Tree-sitter to parse code to a syntax tree which is used for features that require an understanding of the code in the editor, for example syntax highlighting.

4. **simonbs/Runestone | DeepWiki**
   https://deepwiki.com/simonbs/Runestone
   Syntax Highlighting Runestone uses GitHub&#x27;s Tree-sitter library for parsing code and providing syntax highlighting. This implementation allows for high-performance incremental parsing that only re-parses the portions of code that have changed.

5. **Adding a Theme — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/adding-a-theme/
   This tutorial guides you through adding a custom theme to your project. You will add the theme to the TextCompanion app and use it when highlighting code.

6. **Syntax Highlighting the Text — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text/
   This tutorial guides you through syntax highlighting text in a text view. In this guide we&#x27;ll add support for syntax highlighting JavaScript code to the text view we configured in Setting up a TextView. We&#x27;ll use the JavaScript syntax included in the TreeSitterLanguages Swift package. For more information on Tree-sitter languages and how they can be used without the TreeSitterLanguages ...

7. **Runestone - Documentation**
   https://docs.runestone.app/documentation/runestone/
   Explore Runestone, the performant code editor with syntax highlighting, line numbers, invisible characters, and much more through a series of interactive tutorials.

8. **Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/syntaxnode/!=(_:_:)/
   Syntax Highlighting Syntax Highlighting the Text Adding a Tree-sitter Language Syntax Highlighting a String LanguageMode

9. **Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/meet-runestone/
   Explore Runestone, the performant code editor with syntax highlighting, line numbers, invisible characters, and much more through a series of interactive tutorials.

10. **Setting up a TextView — Runestone Tutorials | Documentation**
   https://docs.runestone.app/tutorials/runestone/setting-up-a-textview/
   This tutorial guides you through creating a TextView, adding it to your view hierarchy, and configuring the TextView.


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/creatingatheme/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/creatingatheme/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.63s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.02s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.65s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/creatingatheme/#main)
## [ Runestone  ](https://docs.runestone.app/documentation/runestone)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
C
22 of 46 symbols inside <root> containing 5 symbols[TreeSitterLanguageMode](https://docs.runestone.app/documentation/runestone/treesitterlanguagemode)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
C
21 of 46 symbols inside <root> containing 2 symbols[PlainTextLanguageMode](https://docs.runestone.app/documentation/runestone/plaintextlanguagemode)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
rP
20 of 46 symbols inside <root> [LanguageMode](https://docs.runestone.app/documentation/runestone/languagemode)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
19 of 46 symbols inside <root> [Syntax Highlighting a String](https://docs.runestone.app/documentation/runestone/syntaxhighlightingastring)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
18 of 46 symbols inside <root> [Adding a Tree-sitter Language](https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
17 of 46 symbols inside <root> [Syntax Highlighting the Text](https://docs.runestone.app/tutorials/runestone/syntax-highlighting-the-text)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
16 of 46 symbols inside <root>
Syntax Highlighting
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
E
15 of 46 symbols inside <root> containing 6 symbols[LineSelectionDisplayType](https://docs.runestone.app/documentation/runestone/lineselectiondisplaytype)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
E
14 of 46 symbols inside <root> containing 8 symbols[LineBreakMode](https://docs.runestone.app/documentation/runestone/linebreakmode)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
C
13 of 46 symbols inside <root> containing 23 symbols[DefaultTheme](https://docs.runestone.app/documentation/runestone/defaulttheme)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
S
12 of 46 symbols inside <root> containing 11 symbols[FontTraits](https://docs.runestone.app/documentation/runestone/fonttraits)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
rP
11 of 46 symbols inside <root> containing 23 symbols[Theme](https://docs.runestone.app/documentation/runestone/theme)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
10 of 46 symbols inside <root> [Creating a Theme](https://docs.runestone.app/documentation/runestone/creatingatheme)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
9 of 46 symbols inside <root> [Adding a Theme](https://docs.runestone.app/tutorials/runestone/adding-a-theme)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
8 of 46 symbols inside <root>
Appearance
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
C
7 of 46 symbols inside <root> containing 7 symbols[TextViewState](https://docs.runestone.app/documentation/runestone/textviewstate)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
rP
6 of 46 symbols inside <root> containing 17 symbols[TextViewDelegate](https://docs.runestone.app/documentation/runestone/textviewdelegate)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
C
5 of 46 symbols inside <root> containing 149 symbols[TextView](https://docs.runestone.app/documentation/runestone/textview)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
4 of 46 symbols inside <root> [Getting Started](https://docs.runestone.app/documentation/runestone/gettingstarted)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
3 of 46 symbols inside <root> [Setting up a TextView](https://docs.runestone.app/tutorials/runestone/setting-up-a-textview)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
2 of 46 symbols inside <root> containing 4 symbols[Meet Runestone](https://docs.runestone.app/tutorials/meet-runestone)
To navigate the symbols, press Up Arrow, Down Arrow, Left Arrow or Right Arrow 
1 of 46 symbols inside <root>
Essentials
46 items were found. Tab back to navigate through them. 
/ 
Navigator is ready 
Documentation
[ Open Menu ](https://docs.runestone.app/documentation/runestone/creatingatheme/#)
  * /[ Runestone ](https://docs.runestone.app/documentation/runestone)
  * /
    * [Runestone](https://docs.runestone.app/documentation/runestone)
  * / Creating a Theme 


  * SwiftLanguage: Swift


[](https://docs.runestone.app/documentation/runestone/creatingatheme/#)
Article
#  Creating a Theme
Learn how to create a theme and customize the appearance of TextView.
## [Overviewin page link](https://docs.runestone.app/documentation/runestone/creatingatheme/#Overview)
The [`Theme`](https://docs.runestone.app/documentation/runestone/theme) protocol can be used to customize the appearance of [`TextView`](https://docs.runestone.app/documentation/runestone/textview). Runestone does not include any themes by default. However, you can find examples of themes [in the example project](https://github.com/simonbs/Runestone/tree/main/Example/Example/Themes) that is included in Runestone’s repository on GitHub.
Take a look at the documentation of the [`Theme`](https://docs.runestone.app/documentation/runestone/theme) protocol to get an overview of what aspects of [`TextView`](https://docs.runestone.app/documentation/runestone/textview) can be customized.
## [Syntax Highlighting Textin page link](https://docs.runestone.app/documentation/runestone/creatingatheme/#Syntax-Highlighting-Text)
The theme determines the text styling and colors to use when syntax highlighting text. Implement the following methods on [`Theme`](https://docs.runestone.app/documentation/runestone/theme) to specify the text styling and color of syntax highlighted text.
  * [`font(for:)`](https://docs.runestone.app/documentation/runestone/theme/font\(for:\)-6u3z2)
  * [`fontTraits(for:)`](https://docs.runestone.app/documentation/runestone/theme/fonttraits\(for:\)-38bfk)
  * [`textColor(for:)`](https://docs.runestone.app/documentation/runestone/theme/textcolor\(for:\))


The functions should return a font, font traits, and a color for a _highlight name_ which corresponds to a name specified in a Tree-sitter highlights query. For more information on Tree-sitter highlight queries, please refer to [Adding a Tree-sitter Language](https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage).
Highlight names are strings defined by the highlights query in the parser, and as such, there is no fixed set of highlight names used by Runestone. Consult the highlights query of the language you are using. This query is typically in a file named highlights.scm.
Examples of highlight names include `keyword`, `comment`, `string` and `function`. Highlight names can share common subsequences. Examples:
  * `variable and `variable.parameter`.
  * `function`, `function.builtin` and `function.method`.


Styling should be determined based on the longest matching highlight name. So for example `function.builtin` should be preferred over `function` but if `function.builtin` is not defined by your theme, it should fall back to `function`. The Swift code below contains an example of how we this logic can be implemented.
```
func findLongestMatch(highlightName: String) -> String? {
    // Split the highlight name on dots so "function.builtin.static" becomes ["function", "builtin", "static"]
    var components = highlightName.components(separatedBy: ".")
    // Loop through components to find the longest match.
    while !components.isEmpty {
        // Join all components with a dot so ["function", "builtin", "static"] becomes "function.builtin.static"
        let candidate = components.joined(separator: ".")
        if supportedHighlightNames.contains(candidate) {
            // The candidate highlight name is supported.
            return candidate
        } else {
            // Remove the last component so our next candidate will be one component shorter in the next iteration of the loop.
            components.removeLast()
        }
    }
    // No match found for the highlight name.
    return nil
}

```

The list below contains highlight names that are commonly used across a suite of languages. They might serve as a starting point for your theme.
  * `attribute`
  * `constant`
  * `constant.builtin`
  * `constructor`
  * `comment`
  * `delimiter`
  * `escape`
  * `field`
  * `function`
  * `function.builtin`
  * `function.method`
  * `keyword`
  * `number`
  * `operator`
  * `property`
  * `punctuation.bracket`
  * `punctuation.delimiter`
  * `punctuation.special`
  * `string`
  * `string.special`
  * `tag`
  * `type`
  * `type.builtin`
  * `variable`
  * `variable.builtin`


## [See Alsoin page link](https://docs.runestone.app/documentation/runestone/creatingatheme/#see-also)
### [Appearancein page link](https://docs.runestone.app/documentation/runestone/creatingatheme/#appearance)
[Adding a Theme](https://docs.runestone.app/tutorials/runestone/adding-a-theme)
This tutorial guides you through adding a custom theme to your project. You will add the [Tomorrow](https://github.com/chriskempson/tomorrow-theme) theme to the TextCompanion app and use it when highlighting code.
[`protocol Theme`](https://docs.runestone.app/documentation/runestone/theme)
Fonts and colors to be used by a `TextView`.
[`struct FontTraits`](https://docs.runestone.app/documentation/runestone/fonttraits)
Traits to be applied to a font.
[`class DefaultTheme`](https://docs.runestone.app/documentation/runestone/defaulttheme)
Default theme used by Runestone when no other theme has been set.
[`enum LineBreakMode`](https://docs.runestone.app/documentation/runestone/linebreakmode)
Line break mode for text view.
[`enum LineSelectionDisplayType`](https://docs.runestone.app/documentation/runestone/lineselectiondisplaytype)
Approach for highlighting the selected line.
  * [ Creating a Theme ](https://docs.runestone.app/documentation/runestone/creatingatheme/#app-top)
  * [ Overview ](https://docs.runestone.app/documentation/runestone/creatingatheme/#Overview)
  * [ Syntax Highlighting Text ](https://docs.runestone.app/documentation/runestone/creatingatheme/#Syntax-Highlighting-Text)
  * [ See Also ](https://docs.runestone.app/documentation/runestone/creatingatheme/#see-also)


Current page is Creating a Theme 
Light
Dark
Auto


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/theme", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/theme

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.67s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.00s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/theme           
| ✓ | ⏱: 0.68s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/theme/#main)
Light
Dark
Auto


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 1.14s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swi
ft                   | ✓ | ⏱: 1.17s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTheme%2FTheme.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/Theme/Theme.swift) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[Theme](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme)


/
# Theme.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/Theme/Theme.swift.
[Return to the repository overview](https://github.com/simonbs/Runestone)
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme          
| ✓ | ⏱: 1.06s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme          
| ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme          
| ✓ | ⏱: 1.10s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTheme)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTheme)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTheme)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Theme) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# Theme
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/Theme.
[Return to the repository overview](https://github.com/simonbs/Runestone)
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.35s 
[SCRAPE].. ◆ https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 0.04s 
[COMPLETE] ● https://github.com/simonbs/Runestone/tree/main/Sources/Runestone   
| ✓ | ⏱: 1.40s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
[![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)](https://github.com/simonbs)[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Scroll edge effect blurs line numbers on iOS 26 (](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7)[#404](https://github.com/simonbs/Runestone/pull/404)[)](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7)
success
Aug 31, 2025
[d490289](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7) · Aug 31, 2025
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)


/
# Runestone
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources)  
[Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") | [Documentation.docc](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Documentation.docc "Documentation.docc") |  [Adds StringSyntaxHighlighter (](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting")[#363](https://github.com/simonbs/Runestone/pull/363)[)](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting") | Mar 23, 2024  
[Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") | [Library](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Library "Library") |  [Fix build with Xcode 16 (](https://github.com/simonbs/Runestone/commit/1fad339aab99cf2136ce6bf8c32da3265b2e85e5 "Fix build with Xcode 16 \(#375\)

Prior to this, Xcode 16 was unable to infer the type of the variable \(while Xcode 15 was\), so the lookup to `reversed\(\)` was ambiguous.

This adds `String` as the inferred type, so that the call to `reversed\(\)` is no longer ambiguous.")[#375](https://github.com/simonbs/Runestone/pull/375)[)](https://github.com/simonbs/Runestone/commit/1fad339aab99cf2136ce6bf8c32da3265b2e85e5 "Fix build with Xcode 16 \(#375\)

Prior to this, Xcode 16 was unable to infer the type of the variable \(while Xcode 15 was\), so the lookup to `reversed\(\)` was ambiguous.

This adds `String` as the inferred type, so that the call to `reversed\(\)` is no longer ambiguous.") | Jun 11, 2024  
[LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") | [LineManager](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/LineManager "LineManager") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") | [RedBlackTree](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/RedBlackTree "RedBlackTree") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") | [Resources](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/Resources "Resources") |  [Create Localizable.strings (](https://github.com/simonbs/Runestone/commit/d862d75901b679556e8486255842825e987733e2 "Create Localizable.strings \(#194\)")[#194](https://github.com/simonbs/Runestone/pull/194)[)](https://github.com/simonbs/Runestone/commit/d862d75901b679556e8486255842825e987733e2 "Create Localizable.strings \(#194\)") | Sep 21, 2022  
[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") | [TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView "TextView") |  [Scroll edge effect blurs line numbers on iOS 26 (](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)")[#404](https://github.com/simonbs/Runestone/pull/404)[)](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)") | Aug 31, 2025  
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter "TreeSitter") |  [Modernizes GitHub Actions workflows (](https://github.com/simonbs/Runestone/commit/5bb9f9b59965c18fa0aa1cb183747ea9f85d5cc5 "Modernizes GitHub Actions workflows \(#301\)

* Removes extraneous whitespace

* Uses latest macOS versions

* Uses latest stable Xcode

* Selects Xcode version using environment variable

* Removes third-party action for SwiftLint

* Removes CODEQL_ENABLE_EXPERIMENTAL_FEATURES_SWIFT

* Adds concurrency rules

* Explicitly uses macOS 13 runners

* Fixes SwiftLint error

* Ensure SwiftLint is newest version

* Use SwiftLint via Homebrew

* Overwrite linked SwiftLint

* Set Homebrew related environment variables

* Removes existing SwiftLint

* Runs installed SwiftLint

* Disables prefer_self_in_static_references

* Uses version 3 of actions/checkout")[#301](https://github.com/simonbs/Runestone/pull/301)[)](https://github.com/simonbs/Runestone/commit/5bb9f9b59965c18fa0aa1cb183747ea9f85d5cc5 "Modernizes GitHub Actions workflows \(#301\)

* Removes extraneous whitespace

* Uses latest macOS versions

* Uses latest stable Xcode

* Selects Xcode version using environment variable

* Removes third-party action for SwiftLint

* Removes CODEQL_ENABLE_EXPERIMENTAL_FEATURES_SWIFT

* Adds concurrency rules

* Explicitly uses macOS 13 runners

* Fixes SwiftLint error

* Ensure SwiftLint is newest version

* Use SwiftLint via Homebrew

* Overwrite linked SwiftLint

* Set Homebrew related environment variables

* Removes existing SwiftLint

* Runs installed SwiftLint

* Disables prefer_self_in_static_references

* Uses version 3 of actions/checkout") | Jul 15, 2023  
[PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") | [PrivacyInfo.xcprivacy](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/PrivacyInfo.xcprivacy "PrivacyInfo.xcprivacy") |  [Adds privacy report (](https://github.com/simonbs/Runestone/commit/9ba5a1fb624701c230524b9751b23ea05840947f "Adds privacy report \(#358\)")[#358](https://github.com/simonbs/Runestone/pull/358)[)](https://github.com/simonbs/Runestone/commit/9ba5a1fb624701c230524b9751b23ea05840947f "Adds privacy report \(#358\)") | Mar 16, 2024  
[StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") | [StringSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/StringSyntaxHighlighter.swift "StringSyntaxHighlighter.swift") |  [Adds StringSyntaxHighlighter (](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting")[#363](https://github.com/simonbs/Runestone/pull/363)[)](https://github.com/simonbs/Runestone/commit/9a486543e8ea44a705359cd06069c8f86e18df1b "Adds StringSyntaxHighlighter \(#363\)

* Adds default tab stops

* Fixes SwiftLint warning

* Adds StringSyntaxHighlighter

* Adds documentation

* Fixes SwiftLint warnings

* Improves formatting") | Mar 23, 2024  
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.03s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.08s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TextView
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)  
[Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") | [Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") |  |   
[CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") | [CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") |  |   
[Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") | [Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") |  |   
[Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") | [Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") |  |   
[Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") | [Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") |  |   
[Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") | [Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") |  |   
[InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") | [InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") |  |   
[LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") | [LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") |  |   
[Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") | [Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") |  |   
[PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") | [PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") |  |   
[SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") | [SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") |  |   
[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") | [SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") |  |   
[TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") | [TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.90s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appear
ance                 | ✓ | ⏱: 1.95s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FAppearance)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
          * Theme.xcassets
          * DefaultTheme.swift
          * FontTraits.swift
          * HighlightName.swift
          * LineBreakMode.swift
          * LineSelectionDisplayType.swift
          * Theme.swift
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests/RunestoneTests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/Appearance)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# Appearance
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") | [Theme.xcassets](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance/Theme.xcassets "Theme.xcassets") |  |   
[DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") | [DefaultTheme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/DefaultTheme.swift "DefaultTheme.swift") |  |   
[FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") | [FontTraits.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/FontTraits.swift "FontTraits.swift") |  |   
[HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") | [HighlightName.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/HighlightName.swift "HighlightName.swift") |  |   
[LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") | [LineBreakMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineBreakMode.swift "LineBreakMode.swift") |  |   
[LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") | [LineSelectionDisplayType.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/LineSelectionDisplayType.swift "LineSelectionDisplayType.swift") |  |   
[Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") | [Theme.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/Appearance/Theme.swift "Theme.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


Excellent! I found the key files! Let me fetch the actual source code:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/HighlightName.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/HighlightName.swift

#if DEBUG
private var previousUnrecognizedHighlightNames: [String] = []
#endif

enum HighlightName: String {
    case comment
    case constantBuiltin = "constant.builtin"
    case constantCharacter = "constant.character"
    case constructor
    case function
    case keyword
    case number
    case `operator`
    case property
    case punctuation
    case string
    case type
    case variable
    case variableBuiltin = "variable.builtin"

    init?(_ rawHighlightName: String) {
        var comps = rawHighlightName.split(separator: ".")
        while !comps.isEmpty {
            let candidateRawHighlightName = comps.joined(separator: ".")
            if let highlightName = Self(rawValue: candidateRawHighlightName) {
                self = highlightName
                return
            }
            comps.removeLast()
        }
#if DEBUG
        if !previousUnrecognizedHighlightNames.contains(rawHighlightName) {
            previousUnrecognizedHighlightNames.append(rawHighlightName)
            print("Unrecognized highlight name: '\(rawHighlightName)'."
                  + " Add the highlight name to HighlightName.swift if you want to add support for syntax highlighting it."
                  + " This message will only be shown once per highlight name.")
        }
#endif
        return nil
    }
}


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/Theme.swift

import UIKit

/// Fonts and colors to be used by a `TextView`.
public protocol Theme: AnyObject {
    /// Default font of text in the text view.
    var font: UIFont { get }
    /// Default color of text in the text view.
    var textColor: UIColor { get }
    /// Background color of the gutter containing line numbers.
    var gutterBackgroundColor: UIColor { get }
    /// Color of the hairline next to the gutter containing line numbers.
    var gutterHairlineColor: UIColor { get }
    /// Width of the hairline next to the gutter containing line numbers.
    var gutterHairlineWidth: CGFloat { get }
    /// Color of the line numbers in the gutter.
    var lineNumberColor: UIColor { get }
    /// Font of the line nubmers in the gutter.
    var lineNumberFont: UIFont { get }
    /// Background color of the selected line.
    var selectedLineBackgroundColor: UIColor { get }
    /// Color of the line number of the selected line.
    var selectedLinesLineNumberColor: UIColor { get }
    /// Background color of the gutter for selected lines.
    var selectedLinesGutterBackgroundColor: UIColor { get }
    /// Color of invisible characters, i.e. dots, spaces and line breaks.
    var invisibleCharactersColor: UIColor { get }
    /// Color of the hairline next to the page guide.
    var pageGuideHairlineColor: UIColor { get }
    /// Width of the hairline next to the page guide.
    var pageGuideHairlineWidth: CGFloat { get }
    /// Background color of the page guide.
    var pageGuideBackgroundColor: UIColor { get }
    /// Background color of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    var markedTextBackgroundColor: UIColor { get }
    /// Corner radius of the background of marked text. Text will be marked when writing certain languages, for example Chinese and Japanese.
    /// A value of zero or less means that the background will not have rounded corners. Defaults to 0.
    var markedTextBackgroundCornerRadius: CGFloat { get }
    /// Color of text matching the capture sequence.
    ///
    /// See  for more information on higlight names.
    func textColor(for highlightName: String) -> UIColor?
    /// Font of text matching the capture sequence.
    ///
    /// See  for more information on higlight names.
    func font(for highlightName: String) -> UIFont?
    /// Traits of text matching the capture sequence.
    ///
    /// See  for more information on higlight names.
    func fontTraits(for highlightName: String) -> FontTraits
    /// Shadow of text matching the capture sequence.
    ///
    /// See  for more information on higlight names.
    func shadow(for highlightName: String) -> NSShadow?
    /// Highlighted range for a text range matching a search query.
    ///
    /// This function is called when highlighting a search result that was found using the standard find/replace interaction enabled using .
    ///
    /// Return `nil` to prevent highlighting the range.
    /// - Parameters:
    ///   - foundTextRange: The text range matching a search query.
    ///   - style: Style used to decorate the text.
    /// - Returns: The object used for highlighting the provided text range, or `nil` if the range should not be highlighted.
    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange?
}

public extension Theme {
    var gutterHairlineWidth: CGFloat {
        hairlineLength
    }

    var pageGuideHairlineWidth: CGFloat {
        hairlineLength
    }

    var markedTextBackgroundCornerRadius: CGFloat {
        0
    }

    func font(for highlightName: String) -> UIFont? {
        nil
    }

    func fontTraits(for highlightName: String) -> FontTraits {
        []
    }

    func shadow(for highlightName: String) -> NSShadow? {
        nil
    }

    @available(iOS 16, *)
    func highlightedRange(forFoundTextRange foundTextRange: NSRange, ofStyle style: UITextSearchFoundTextStyle) -> HighlightedRange? {
        switch style {
        case .found:
            return HighlightedRange(range: foundTextRange, color: .systemYellow.withAlphaComponent(0.2))
        case .highlighted:
            return HighlightedRange(range: foundTextRange, color: .systemYellow)
        case .normal:
            return nil
        @unknown default:
            return nil
        }
    }
}


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.26s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.31s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
          * Internal
          * PlainText
          * TreeSitter
          * LanguageMode.swift
          * SyntaxNode.swift
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# SyntaxHighlighting
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
![migueldeicaza](https://avatars.githubusercontent.com/u/36863?v=4&size=40)![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)
[migueldeicaza](https://github.com/simonbs/Runestone/commits?author=migueldeicaza)
and
[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc)
Open commit details
Apr 15, 2024
[36d91bf](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc) · Apr 15, 2024
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# SyntaxHighlighting
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") | [Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") | [Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc "Add a lock around parse, to prevent concurrent access to the underlying parse tree. \(#367\)

* Add a lock around parse, as we can have both the OperationQueue-based parse and this parse happen at the same time

* Fixes SwiftLint violation

---------

Co-authored-by: Simon Støvring <mail@simonbs.dk>") | Apr 15, 2024  
[PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") | [PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") | [LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
[SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") | [SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 1.21s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 1.25s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
          * Internal
            * PlainText
            * TreeSitter
            * InternalLanguageMode.swift
            * InternalLanguageModeFactory.swift
          * PlainText
          * TreeSitter
          * LanguageMode.swift
          * SyntaxNode.swift
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)


/
# Internal
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
![migueldeicaza](https://avatars.githubusercontent.com/u/36863?v=4&size=40)![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)
[migueldeicaza](https://github.com/simonbs/Runestone/commits?author=migueldeicaza)
and
[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc)
Open commit details
Apr 15, 2024
[36d91bf](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc) · Apr 15, 2024
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)


/
# Internal
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)  
[PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/PlainText "PlainText") | [PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/PlainText "PlainText") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter "TreeSitter") | [Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc "Add a lock around parse, to prevent concurrent access to the underlying parse tree. \(#367\)

* Add a lock around parse, as we can have both the OperationQueue-based parse and this parse happen at the same time

* Fixes SwiftLint violation

---------

Co-authored-by: Simon Støvring <mail@simonbs.dk>") | Apr 15, 2024  
[InternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift "InternalLanguageMode.swift") | [InternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift "InternalLanguageMode.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
[InternalLanguageModeFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageModeFactory.swift "InternalLanguageModeFactory.swift") | [InternalLanguageModeFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageModeFactory.swift "InternalLanguageModeFactory.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/InternalLanguageMode.swift

import Foundation

struct InsertLineBreakIndentStrategy {
    let indentLevel: Int
    let insertExtraLineBreak: Bool
}

protocol InternalLanguageMode: AnyObject {
    func parse(_ text: NSString)
    func parse(_ text: NSString, completion: @escaping ((Bool) -> Void))
    func textDidChange(_ change: TextChange) -> LineChangeSet
    func createLineSyntaxHighlighter() -> LineSyntaxHighlighter
    func syntaxNode(at linePosition: LinePosition) -> SyntaxNode?
    func currentIndentLevel(of line: DocumentLineNode, using indentStrategy: IndentStrategy) -> Int
    func strategyForInsertingLineBreak(
        from startLinePosition: LinePosition,
        to endLinePosition: LinePosition,
        using indentStrategy: IndentStrategy) -> InsertLineBreakIndentStrategy
    func detectIndentStrategy() -> DetectedIndentStrategy
}


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 1.26s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 0.08s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 1.34s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal%2FTreeSitter)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FInternal%2FTreeSitter)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
          * Internal
            * PlainText
            * TreeSitter
              * TreeSitterIndentController.swift
              * TreeSitterIndentStrategyDetector.swift
              * TreeSitterInjectedLanguage.swift
              * TreeSitterInjectedLanguageMapper.swift
              * TreeSitterInternalLanguage.swift
              * TreeSitterInternalLanguageMode.swift
              * TreeSitterLanguageLayer.swift
              * TreeSitterLanguageLayerStore.swift
              * TreeSitterSyntaxHighlightToken.swift
              * TreeSitterSyntaxHighlighter.swift
              * TreeSitterTextPredicatesEvaluator.swift
            * InternalLanguageMode.swift
            * InternalLanguageModeFactory.swift
          * PlainText
          * TreeSitter
          * LanguageMode.swift
          * SyntaxNode.swift
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)
  6. /[Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)


/
# TreeSitter
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
![migueldeicaza](https://avatars.githubusercontent.com/u/36863?v=4&size=40)![simonbs](https://avatars.githubusercontent.com/u/830995?v=4&size=40)
[migueldeicaza](https://github.com/simonbs/Runestone/commits?author=migueldeicaza)
and
[simonbs](https://github.com/simonbs/Runestone/commits?author=simonbs)
[Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc)
Open commit details
Apr 15, 2024
[36d91bf](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc) · Apr 15, 2024
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter)
Open commit details
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)
  6. /[Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)


/
# TreeSitter
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal)  
[TreeSitterIndentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterIndentController.swift "TreeSitterIndentController.swift") | [TreeSitterIndentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterIndentController.swift "TreeSitterIndentController.swift") |  |   
[TreeSitterIndentStrategyDetector.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterIndentStrategyDetector.swift "TreeSitterIndentStrategyDetector.swift") | [TreeSitterIndentStrategyDetector.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterIndentStrategyDetector.swift "TreeSitterIndentStrategyDetector.swift") |  |   
[TreeSitterInjectedLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInjectedLanguage.swift "TreeSitterInjectedLanguage.swift") | [TreeSitterInjectedLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInjectedLanguage.swift "TreeSitterInjectedLanguage.swift") |  |   
[TreeSitterInjectedLanguageMapper.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInjectedLanguageMapper.swift "TreeSitterInjectedLanguageMapper.swift") | [TreeSitterInjectedLanguageMapper.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInjectedLanguageMapper.swift "TreeSitterInjectedLanguageMapper.swift") |  |   
[TreeSitterInternalLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguage.swift "TreeSitterInternalLanguage.swift") | [TreeSitterInternalLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguage.swift "TreeSitterInternalLanguage.swift") |  |   
[TreeSitterInternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift "TreeSitterInternalLanguageMode.swift") | [TreeSitterInternalLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift "TreeSitterInternalLanguageMode.swift") |  |   
[TreeSitterLanguageLayer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayer.swift "TreeSitterLanguageLayer.swift") | [TreeSitterLanguageLayer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayer.swift "TreeSitterLanguageLayer.swift") |  |   
[TreeSitterLanguageLayerStore.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayerStore.swift "TreeSitterLanguageLayerStore.swift") | [TreeSitterLanguageLayerStore.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayerStore.swift "TreeSitterLanguageLayerStore.swift") |  |   
[TreeSitterSyntaxHighlightToken.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlightToken.swift "TreeSitterSyntaxHighlightToken.swift") | [TreeSitterSyntaxHighlightToken.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlightToken.swift "TreeSitterSyntaxHighlightToken.swift") |  |   
[TreeSitterSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift "TreeSitterSyntaxHighlighter.swift") | [TreeSitterSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift "TreeSitterSyntaxHighlighter.swift") |  |   
[TreeSitterTextPredicatesEvaluator.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterTextPredicatesEvaluator.swift "TreeSitterTextPredicatesEvaluator.swift") | [TreeSitterTextPredicatesEvaluator.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterTextPredicatesEvaluator.swift "TreeSitterTextPredicatesEvaluator.swift") |  |   
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift

import UIKit

enum TreeSitterSyntaxHighlighterError: LocalizedError {
    case cancelled
    case operationDeallocated

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Operation was cancelled"
        case .operationDeallocated:
            return "The operation was deallocated"
        }
    }
}

final class TreeSitterSyntaxHighlighter: LineSyntaxHighlighter {
    var theme: Theme = DefaultTheme()
    var kern: CGFloat = 0
    var canHighlight: Bool {
        languageMode.canHighlight
    }

    private let stringView: StringView
    private let languageMode: TreeSitterInternalLanguageMode
    private let operationQueue: OperationQueue
    private var currentOperation: Operation?

    init(stringView: StringView, languageMode: TreeSitterInternalLanguageMode, operationQueue: OperationQueue) {
        self.stringView = stringView
        self.languageMode = languageMode
        self.operationQueue = operationQueue
    }

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput) {
        let captures = languageMode.captures(in: input.byteRange)
        let tokens = self.tokens(for: captures, localTo: input.byteRange)
        setAttributes(for: tokens, on: input.attributedString)
    }

    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback) {
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            guard let operation = operation, let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.operationDeallocated))
                }
                return
            }
            guard !operation.isCancelled else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                }
                return
            }
            let captures = self.languageMode.captures(in: input.byteRange)
            if !operation.isCancelled {
                DispatchQueue.main.async {
                    if !operation.isCancelled {
                        let tokens = self.tokens(for: captures, localTo: input.byteRange)
                        self.setAttributes(for: tokens, on: input.attributedString)
                        completion(.success(()))
                    } else {
                        completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(TreeSitterSyntaxHighlighterError.cancelled))
                }
            }
        }
        currentOperation = operation
        operationQueue.addOperation(operation)
    }

    func cancel() {
        currentOperation?.cancel()
        currentOperation = nil
    }
}

private extension TreeSitterSyntaxHighlighter {
    private func setAttributes(for tokens: [TreeSitterSyntaxHighlightToken], on attributedString: NSMutableAttributedString) {
        attributedString.beginEditing()
        for token in tokens {
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let foregroundColor = token.textColor {
                attributes[.foregroundColor] = foregroundColor
            }
            if let shadow = token.shadow {
                attributes[.shadow] = shadow
            }
            if token.fontTraits.contains(.bold) {
                attributedString.addAttribute(.isBold, value: true, range: token.range)
            }
            if token.fontTraits.contains(.italic) {
                attributedString.addAttribute(.isItalic, value: true, range: token.range)
            }
            var symbolicTraits: UIFontDescriptor.SymbolicTraits = []
            if let isBold = attributedString.attribute(.isBold, at: token.range.location, effectiveRange: nil) as? Bool, isBold {
                symbolicTraits.insert(.traitBold)
            }
            if let isItalic = attributedString.attribute(.isItalic, at: token.range.location, effectiveRange: nil) as? Bool, isItalic {
                symbolicTraits.insert(.traitItalic)
            }
            let currentFont = attributedString.attribute(.font, at: token.range.location, effectiveRange: nil) as? UIFont
            let baseFont = token.font ?? theme.font
            let newFont: UIFont
            if !symbolicTraits.isEmpty {
                newFont = baseFont.withSymbolicTraits(symbolicTraits) ?? baseFont
            } else {
                newFont = baseFont
            }
            if newFont != currentFont {
                attributes[.font] = newFont
            }
            if !attributes.isEmpty {
                attributedString.addAttributes(attributes, range: token.range)
            }
        }
        attributedString.endEditing()
    }

    private func tokens(for captures: [TreeSitterCapture], localTo localRange: ByteRange) -> [TreeSitterSyntaxHighlightToken] {
        var tokens: [TreeSitterSyntaxHighlightToken] = []
        for capture in captures where capture.byteRange.overlaps(localRange) {
            // We highlight each line separately but a capture may extend beyond a line,
            // e.g. an unterminated string, so we need to cap the start and end location
            // to ensure it's within the line.
            let cappedStartByte = max(capture.byteRange.lowerBound, localRange.lowerBound)
            let cappedEndByte = min(capture.byteRange.upperBound, localRange.upperBound)
            let length = cappedEndByte - cappedStartByte
            let cappedRange = ByteRange(location: cappedStartByte - localRange.lowerBound, length: length)
            if !cappedRange.isEmpty {
                let token = token(from: capture, in: cappedRange)
                if !token.isEmpty {
                    tokens.append(token)
                }
            }
        }
        return tokens
    }
}

private extension TreeSitterSyntaxHighlighter {
    private func token(from capture: TreeSitterCapture, in byteRange: ByteRange) -> TreeSitterSyntaxHighlightToken {
        let range = NSRange(byteRange)
        let textColor = theme.textColor(for: capture.name)
        let shadow = theme.shadow(for: capture.name)
        let font = theme.font(for: capture.name)
        let fontTraits = theme.fontTraits(for: capture.name)
        return TreeSitterSyntaxHighlightToken(range: range, textColor: textColor, shadow: shadow, font: font, fontTraits: fontTraits)
    }
}

private extension UIFont {
    func withSymbolicTraits(_ symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) {
            return UIFont(descriptor: newFontDescriptor, size: pointSize)
        } else {
            return nil
        }
    }
}


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlightToken.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlightToken.swift

import UIKit

final class TreeSitterSyntaxHighlightToken {
    let range: NSRange
    let textColor: UIColor?
    let shadow: NSShadow?
    let font: UIFont?
    let fontTraits: FontTraits
    var isEmpty: Bool {
        range.length == 0 || (textColor == nil && font == nil && shadow == nil)
    }

    init(range: NSRange, textColor: UIColor?, shadow: NSShadow?, font: UIFont?, fontTraits: FontTraits) {
        self.range = range
        self.textColor = textColor
        self.shadow = shadow
        self.font = font
        self.fontTraits = fontTraits
    }
}

extension TreeSitterSyntaxHighlightToken: Equatable {
    static func == (lhs: TreeSitterSyntaxHighlightToken, rhs: TreeSitterSyntaxHighlightToken) -> Bool {
        lhs.range == rhs.range && lhs.textColor == rhs.textColor && lhs.font == rhs.font
    }
}

extension TreeSitterSyntaxHighlightToken {
    static func locationSort(_ lhs: TreeSitterSyntaxHighlightToken, _ rhs: TreeSitterSyntaxHighlightToken) -> Bool {
        if lhs.range.location != rhs.range.location {
            return lhs.range.location < rhs.range.location
        } else {
            return lhs.range.length < rhs.range.length
        }
    }
}

extension TreeSitterSyntaxHighlightToken: CustomDebugStringConvertible {
    var debugDescription: String {
        "[TreeSitterSyntaxHighlightToken: \(range.location) - \(range.length)]"
    }
}


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 1.26s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineCo
ntroller             | ✓ | ⏱: 1.32s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FLineController)
Appearance settings
  * Platform
    * AI CODE CREATION
      * [ GitHub CopilotWrite better code with AI ](https://github.com/features/copilot)
      * [ GitHub SparkBuild and deploy intelligent apps ](https://github.com/features/spark)
      * [ GitHub ModelsManage and compare prompts ](https://github.com/features/models)
      * [ MCP RegistryNewIntegrate external tools ](https://github.com/mcp)
    * DEVELOPER WORKFLOWS
      * [ ActionsAutomate any workflow ](https://github.com/features/actions)
      * [ CodespacesInstant dev environments ](https://github.com/features/codespaces)
      * [ IssuesPlan and track work ](https://github.com/features/issues)
      * [ Code ReviewManage code changes ](https://github.com/features/code-review)
    * APPLICATION SECURITY
      * [ GitHub Advanced SecurityFind and fix vulnerabilities ](https://github.com/security/advanced-security)
      * [ Code securitySecure your code as you build ](https://github.com/security/advanced-security/code-security)
      * [ Secret protectionStop leaks before they start ](https://github.com/security/advanced-security/secret-protection)
    * EXPLORE
      * [Why GitHub](https://github.com/why-github)
      * [Documentation](https://docs.github.com)
      * [Blog](https://github.blog)
      * [Changelog](https://github.blog/changelog)
      * [Marketplace](https://github.com/marketplace)
[View all features](https://github.com/features)
  * Solutions
    * BY COMPANY SIZE
      * [Enterprises](https://github.com/enterprise)
      * [Small and medium teams](https://github.com/team)
      * [Startups](https://github.com/enterprise/startups)
      * [Nonprofits](https://github.com/solutions/industry/nonprofits)
    * BY USE CASE
      * [App Modernization](https://github.com/solutions/use-case/app-modernization)
      * [DevSecOps](https://github.com/solutions/use-case/devsecops)
      * [DevOps](https://github.com/solutions/use-case/devops)
      * [CI/CD](https://github.com/solutions/use-case/ci-cd)
      * [View all use cases](https://github.com/solutions/use-case)
    * BY INDUSTRY
      * [Healthcare](https://github.com/solutions/industry/healthcare)
      * [Financial services](https://github.com/solutions/industry/financial-services)
      * [Manufacturing](https://github.com/solutions/industry/manufacturing)
      * [Government](https://github.com/solutions/industry/government)
      * [View all industries](https://github.com/solutions/industry)
[View all solutions](https://github.com/solutions)
  * Resources
    * EXPLORE BY TOPIC
      * [AI](https://github.com/resources/articles?topic=ai)
      * [Software Development](https://github.com/resources/articles?topic=software-development)
      * [DevOps](https://github.com/resources/articles?topic=devops)
      * [Security](https://github.com/resources/articles?topic=security)
      * [View all topics](https://github.com/resources/articles)
    * EXPLORE BY TYPE
      * [Customer stories](https://github.com/customer-stories)
      * [Events & webinars](https://github.com/resources/events)
      * [Ebooks & reports](https://github.com/resources/whitepapers)
      * [Business insights](https://github.com/solutions/executive-insights)
      * [GitHub Skills](https://skills.github.com)
    * SUPPORT & SERVICES
      * [Documentation](https://docs.github.com)
      * [Customer support](https://support.github.com)
      * [Community forum](https://github.com/orgs/community/discussions)
      * [Trust center](https://github.com/trust-center)
      * [Partners](https://github.com/partners)
  * Open Source
    * COMMUNITY
      * [ GitHub SponsorsFund open source developers ](https://github.com/sponsors)
    * PROGRAMS
      * [Security Lab](https://securitylab.github.com)
      * [Maintainer Community](https://maintainers.github.com)
      * [Accelerator](https://github.com/accelerator)
      * [Archive Program](https://archiveprogram.github.com)
    * REPOSITORIES
      * [Topics](https://github.com/topics)
      * [Trending](https://github.com/trending)
      * [Collections](https://github.com/collections)
  * Enterprise
    * ENTERPRISE SOLUTIONS
      * [ Enterprise platformAI-powered developer platform ](https://github.com/enterprise)
    * AVAILABLE ADD-ONS
      * [ GitHub Advanced SecurityEnterprise-grade security features ](https://github.com/security/advanced-security)
      * [ Copilot for BusinessEnterprise-grade AI features ](https://github.com/features/copilot/copilot-business)
      * [ Premium SupportEnterprise-grade 24/7 support ](https://github.com/premium-support)
  * [Pricing](https://github.com/pricing)


Search or jump to...
# Search code, repositories, users, issues, pull requests...
Search 
Clear
[Search syntax tips](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax)
#  Provide feedback 
We read every piece of feedback, and take your input very seriously.
Include my email address so I can be contacted
Cancel  Submit feedback 
#  Saved searches 
## Use saved searches to filter your results more quickly
Name
Query
To see all available qualifiers, see our [documentation](https://docs.github.com/search-github/github-code-search/understanding-github-code-search-syntax). 
Cancel  Create saved search 
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FLineController)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[Runestone](https://github.com/simonbs/Runestone) ** Public
  * [ Sponsor  ](https://github.com/sponsors/simonbs)
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone) You must be signed in to change notification settings
  * [ 193 ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)
  * [ Star  3k ](https://github.com/login?return_to=%2Fsimonbs%2FRunestone)


  * [ Code ](https://github.com/simonbs/Runestone)
  * [ Issues 31 ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests 4 ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions ](https://github.com/simonbs/Runestone/actions)
  * [ Security 0 ](https://github.com/simonbs/Runestone/security)
  * [ Insights ](https://github.com/simonbs/Runestone/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/Runestone)
  * [ Issues  ](https://github.com/simonbs/Runestone/issues)
  * [ Pull requests  ](https://github.com/simonbs/Runestone/pulls)
  * [ Actions  ](https://github.com/simonbs/Runestone/actions)
  * [ Security  ](https://github.com/simonbs/Runestone/security)
  * [ Insights  ](https://github.com/simonbs/Runestone/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Assets
  * Design
  * Example
  * Scripts
  * Sources
    * Runestone
      * Documentation.docc
      * Library
      * LineManager
      * RedBlackTree
      * Resources
      * TextView
        * Appearance
        * CharacterPairs
        * Core
        * Gutter
        * Highlight
        * Indent
        * InvisibleCharacters
        * LineController
          * LineBreak
          * LineController.swift
          * LineControllerFactory.swift
          * LineControllerStorage.swift
          * LineFragment.swift
          * LineFragmentCharacterLocationQuery.swift
          * LineFragmentController.swift
          * LineFragmentFrameQuery.swift
          * LineFragmentNode.swift
          * LineFragmentRenderer.swift
          * LineFragmentSelectionRect.swift
          * LineSyntaxHighlighter.swift
          * LineTypesetter.swift
        * Navigation
        * PageGuide
        * SearchAndReplace
        * SyntaxHighlighting
        * TextSelection
      * TreeSitter
      * PrivacyInfo.xcprivacy
      * StringSyntaxHighlighter.swift
    * TestTreeSitterLanguages
  * Tests
  * UITests
  * .gitattributes
  * .gitignore
  * .gitmodules
  * .spi.yml
  * .swiftlint.yml
  * CODEOWNERS
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md
  * swiftgen.yml


## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# LineController
/
Copy path
## Directory actions
## More options
More options
## Directory actions
## More options
More options
## Latest commit
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/LineController)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/LineController)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)


/
# LineController
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)  
[LineBreak](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController/LineBreak "LineBreak") | [LineBreak](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController/LineBreak "LineBreak") |  [Adds LineBreakSuggester (](https://github.com/simonbs/Runestone/commit/890f22c09a5da60e0d64b9cbd34e30e4b341d093 "Adds LineBreakSuggester \(#271\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests")[#271](https://github.com/simonbs/Runestone/pull/271)[)](https://github.com/simonbs/Runestone/commit/890f22c09a5da60e0d64b9cbd34e30e4b341d093 "Adds LineBreakSuggester \(#271\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests") | Feb 13, 2023  
[LineController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineController.swift "LineController.swift") | [LineController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineController.swift "LineController.swift") |  [Adds DefaultStringAttributes (](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)")[#359](https://github.com/simonbs/Runestone/pull/359)[)](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)") | Mar 16, 2024  
[LineControllerFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerFactory.swift "LineControllerFactory.swift") | [LineControllerFactory.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerFactory.swift "LineControllerFactory.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineControllerStorage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerStorage.swift "LineControllerStorage.swift") | [LineControllerStorage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineControllerStorage.swift "LineControllerStorage.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineFragment.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragment.swift "LineFragment.swift") | [LineFragment.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragment.swift "LineFragment.swift") |  [Hides leading whitespaces from line fragments (](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning")[#272](https://github.com/simonbs/Runestone/pull/272)[)](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning") | Feb 13, 2023  
[LineFragmentCharacterLocationQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentCharacterLocationQuery.swift "LineFragmentCharacterLocationQuery.swift") | [LineFragmentCharacterLocationQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentCharacterLocationQuery.swift "LineFragmentCharacterLocationQuery.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineFragmentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentController.swift "LineFragmentController.swift") | [LineFragmentController.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentController.swift "LineFragmentController.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineFragmentFrameQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentFrameQuery.swift "LineFragmentFrameQuery.swift") | [LineFragmentFrameQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentFrameQuery.swift "LineFragmentFrameQuery.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineFragmentNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentNode.swift "LineFragmentNode.swift") | [LineFragmentNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentNode.swift "LineFragmentNode.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[LineFragmentRenderer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentRenderer.swift "LineFragmentRenderer.swift") | [LineFragmentRenderer.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentRenderer.swift "LineFragmentRenderer.swift") |  [Hides leading whitespaces from line fragments (](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning")[#272](https://github.com/simonbs/Runestone/pull/272)[)](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning") | Feb 13, 2023  
[LineFragmentSelectionRect.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentSelectionRect.swift "LineFragmentSelectionRect.swift") | [LineFragmentSelectionRect.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineFragmentSelectionRect.swift "LineFragmentSelectionRect.swift") |  [Fixes SwiftLint warnings (](https://github.com/simonbs/Runestone/commit/a9a5bb85a88fc3a2d028f55b19e04dc029014a6a "Fixes SwiftLint warnings \(#298\)

* Fixes SwiftLint warnings

* Fixes SwiftLint warning")[#298](https://github.com/simonbs/Runestone/pull/298)[)](https://github.com/simonbs/Runestone/commit/a9a5bb85a88fc3a2d028f55b19e04dc029014a6a "Fixes SwiftLint warnings \(#298\)

* Fixes SwiftLint warnings

* Fixes SwiftLint warning") | Jul 9, 2023  
[LineSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift "LineSyntaxHighlighter.swift") | [LineSyntaxHighlighter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift "LineSyntaxHighlighter.swift") |  [Adds DefaultStringAttributes (](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)")[#359](https://github.com/simonbs/Runestone/pull/359)[)](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)") | Mar 16, 2024  
[LineTypesetter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineTypesetter.swift "LineTypesetter.swift") | [LineTypesetter.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/LineController/LineTypesetter.swift "LineTypesetter.swift") |  [Hides leading whitespaces from line fragments (](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning")[#272](https://github.com/simonbs/Runestone/pull/272)[)](https://github.com/simonbs/Runestone/commit/1d0e79051a18d79f12882e9fad0b130e47d4a06b "Hides leading whitespaces from line fragments \(#272\)

* Improves formatting

* Adds LineBreakSuggester

* Fixes tests

* Fixes tests

* Improves formatting

* Adds containsAllCharacters\(of:\)

* Adds isWhitespaceCharacter\(at:\) to NSAttributedString

* Uses lineFragment.visibleRange

* Trims leading whitespaces

* Fixes SwiftLint warnings

* Fixes SwiftLint warning") | Feb 13, 2023  
View all files  
## Footer
[ ](https://github.com) © 2026 GitHub, Inc. 
### Footer navigation
  * [Terms](https://docs.github.com/site-policy/github-terms/github-terms-of-service)
  * [Privacy](https://docs.github.com/site-policy/privacy-policies/github-privacy-statement)
  * [Security](https://github.com/security)
  * [Status](https://www.githubstatus.com/)
  * [Community](https://github.community/)
  * [Docs](https://docs.github.com/)
  * [Contact](https://support.github.com?tags=dotcom-footer)
  * Manage cookies 
  * Do not share my personal information


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift

import CoreGraphics
import Foundation

extension NSAttributedString.Key {
    static let isBold = NSAttributedString.Key("runestone_isBold")
    static let isItalic = NSAttributedString.Key("runestone_isItalic")
}

struct LineSyntaxHiglighterSetAttributesResult {
    let isSizingInvalid: Bool
}

final class LineSyntaxHighlighterInput {
    let attributedString: NSMutableAttributedString
    let byteRange: ByteRange

    init(attributedString: NSMutableAttributedString, byteRange: ByteRange) {
        self.attributedString = attributedString
        self.byteRange = byteRange
    }
}

protocol LineSyntaxHighlighter: AnyObject {
    typealias AsyncCallback = (Result) -> Void
    var theme: Theme { get set }
    var canHighlight: Bool { get }
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput)
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback)
    func cancel()
}


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 1, "end_line": 100}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 2-100 of 741)
────────────────────────────────────────
2: //  RunestoneEditorView.swift
3: //  VSCodeiPadOS
4: //
5: //  High-performance code editor using Runestone with TreeSitter syntax highlighting.
6: //  Provides native line numbers, code folding, and efficient rendering for large files.
7: //
8: 
9: import SwiftUI
10: import UIKit
11: import Runestone
12: import TreeSitterSwiftRunestone
13: import TreeSitterJavaScriptRunestone
14: import TreeSitterPythonRunestone
15: import TreeSitterJSONRunestone
16: import TreeSitterHTMLRunestone
17: import TreeSitterCSSRunestone
18: import TreeSitterGoRunestone
19: import TreeSitterRustRunestone
20: 
21: // Feature flag now uses centralized FeatureFlags.useRunestoneEditor
22: 
23: /// UIViewRepresentable wrapper for Runestone's TextView
24: /// Provides native TreeSitter syntax highlighting, line numbers, and code folding
25: struct RunestoneEditorView: UIViewRepresentable {
26:     @Binding var text: String
27:     let filename: String
28:     @Binding var scrollOffset: CGFloat
29:     @Binding var totalLines: Int
30:     @Binding var currentLineNumber: Int
31:     @Binding var currentColumn: Int
32:     @Binding var cursorIndex: Int
33:     let isActive: Bool
34:     let fontSize: CGFloat
35:     @EnvironmentObject var editorCore: EditorCore
36:     
37:     // Settings from AppStorage
38:     @AppStorage("wordWrap") private var wordWrapEnabled: Bool = true
39:     @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
40:     
41:     /// Autocomplete key handling hooks (return true if handled)
42:     let onAcceptAutocomplete: (() -> Bool)?
43:     let onDismissAutocomplete: (() -> Bool)?
44:     
45:     init(
46:         text: Binding<String>,
47:         filename: String,
48:         scrollOffset: Binding<CGFloat> = .constant(0),
49:         totalLines: Binding<Int>,
50:         currentLineNumber: Binding<Int>,
51:         currentColumn: Binding<Int>,
52:         cursorIndex: Binding<Int> = .constant(0),
53:         isActive: Bool,
54:         fontSize: CGFloat = 14.0,
55:         onAcceptAutocomplete: (() -> Bool)? = nil,
56:         onDismissAutocomplete: (() -> Bool)? = nil
57:     ) {
58:         self._text = text
59:         self.filename = filename
60:         self._scrollOffset = scrollOffset
61:         self._totalLines = totalLines
62:         self._currentLineNumber = currentLineNumber
63:         self._currentColumn = currentColumn
64:         self._cursorIndex = cursorIndex
65:         self.isActive = isActive
66:         self.fontSize = fontSize
67:         self.onAcceptAutocomplete = onAcceptAutocomplete
68:         self.onDismissAutocomplete = onDismissAutocomplete
69:     }
70:     
71:     func makeCoordinator() -> Coordinator {
72:         Coordinator(self)
73:     }
74:     
75:     func makeUIView(context: Context) -> TextView {
76:         let textView = TextView()
77:         textView.editorDelegate = context.coordinator
78:         
79:         // Configure line numbers (from settings)
80:         textView.showLineNumbers = showLineNumbers
81:         textView.lineSelectionDisplayType = .line
82:         
83:         // Configure line wrapping (from settings)
84:         textView.isLineWrappingEnabled = wordWrapEnabled
85:         
86:         // Configure editing
87:         textView.isEditable = true
88:         textView.isSelectable = true
89:         
90:         // Disable autocorrect/autocapitalize for code editing
91:         textView.autocorrectionType = .no
92:         textView.autocapitalizationType = .none
93:         textView.smartQuotesType = .no
94:         textView.smartDashesType = .no
95:         textView.smartInsertDeleteType = .no
96:         textView.spellCheckingType = .no
97:         
98:         // Configure keyboard
99:         textView.keyboardType = .asciiCapable
100:         textView.keyboardDismissMode = .interactive


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift

import CoreGraphics
import Foundation

extension NSAttributedString.Key {
    static let isBold = NSAttributedString.Key("runestone_isBold")
    static let isItalic = NSAttributedString.Key("runestone_isItalic")
}

struct LineSyntaxHiglighterSetAttributesResult {
    let isSizingInvalid: Bool
}

final class LineSyntaxHighlighterInput {
    let attributedString: NSMutableAttributedString
    let byteRange: ByteRange

    init(attributedString: NSMutableAttributedString, byteRange: ByteRange) {
        self.attributedString = attributedString
        self.byteRange = byteRange
    }
}

protocol LineSyntaxHighlighter: AnyObject {
    typealias AsyncCallback = (Result) -> Void
    var theme: Theme { get set }
    var canHighlight: Bool { get }
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput)
    func syntaxHighlight(_ input: LineSyntaxHighlighterInput, completion: @escaping AsyncCallback)
    func cancel()
}


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 550, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 551-700 of 741)
────────────────────────────────────────
551:     
552:     var lineNumberFont: UIFont {
553:         UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
554:     }
555:     
556:     var selectedLineBackgroundColor: UIColor {
557:         _selectedLineBackgroundColor
558:     }
559:     
560:     var selectedLinesLineNumberColor: UIColor {
561:         _selectedLinesLineNumberColor
562:     }
563:     
564:     var selectedLinesGutterBackgroundColor: UIColor {
565:         _selectedLinesGutterBackgroundColor
566:     }
567:     
568:     var invisibleCharactersColor: UIColor {
569:         _invisibleCharactersColor
570:     }
571:     
572:     var pageGuideHairlineColor: UIColor {
573:         _pageGuideHairlineColor
574:     }
575:     
576:     var pageGuideBackgroundColor: UIColor {
577:         _pageGuideBackgroundColor
578:     }
579:     
580:     var markedTextBackgroundColor: UIColor {
581:         _markedTextBackgroundColor
582:     }
583:     
584:     // MARK: - Syntax Highlighting
585:     
586:     func textColor(for rawHighlightName: String) -> UIColor? {
587:         // Map TreeSitter highlight names to colors
588:         // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
589:         let highlightName = rawHighlightName.lowercased()
590:         
591:         // Debug: Log ALL highlight names to console (remove in production)
592:         // print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
593:         
594:         // Keywords
595:         if highlightName.contains("keyword") {
596:             return _keywordColor
597:         }
598:         
599:         // JSON/Object keys - MUST return color for specific patterns
600:         // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
601:         // We handle specific patterns first, then skip generic "string" to avoid overwrite
602:         if highlightName.hasPrefix("string.special") ||
603:            highlightName.contains("label") ||
604:            highlightName.contains("property.definition") {
605:             return _variableColor  // Light blue #9CDCFE for keys
606:         }
607:         
608:         // Strings - but NOT if it's JUST "string" (let specific matches win)
609:         // Only color strings that are clearly values, not potential keys
610:         if highlightName.contains("string") {
611:             // If it's exactly "string" with no qualifiers, it might be a key
612:             // that was already colored by string.special.key - return nil to not overwrite
613:             if rawHighlightName == "string" {
614:                 // For pure "string" captures, still color them (they're values)
615:                 // The issue is ordering - specific patterns should come AFTER in Runestone
616:                 return _stringColor
617:             }
618:             return _stringColor  // Orange #CE9178 for string values
619:         }
620:         
621:         // Numbers and constants
622:         if highlightName.contains("number") || highlightName == "constant.numeric" {
623:             return _numberColor
624:         }
625:         
626:         // Comments
627:         if highlightName.contains("comment") {
628:             return _commentColor
629:         }
630:         
631:         // Functions and methods
632:         if highlightName.contains("function") || highlightName.contains("method") {
633:             return _functionColor
634:         }
635:         
636:         // Types, classes, structs
637:         if highlightName.contains("type") || highlightName.contains("class") ||
638:            highlightName.contains("struct") || highlightName.contains("interface") ||
639:            highlightName.contains("enum") {
640:             return _typeColor
641:         }
642:         
643:         // Variables, parameters, properties
644:         if highlightName.contains("variable") || highlightName.contains("parameter") ||
645:            highlightName.contains("property") || highlightName.contains("field") {
646:             return _variableColor
647:         }
648:         
649:         // Constants and booleans - use keyword color
650:         if highlightName.contains("constant") || highlightName.contains("boolean") {
651:             return _keywordColor
652:         }
653:         
654:         // Operators - use keyword color
655:         if highlightName.contains("operator") {
656:             return _keywordColor
657:         }
658:         
659:         // Namespaces and modules - use type color
660:         if highlightName.contains("namespace") || highlightName.contains("module") {
661:             return _typeColor
662:         }
663:         
664:         // Tags (HTML, XML) - use type color
665:         if highlightName.contains("tag") {
666:             return _typeColor
667:         }
668:         
669:         // Attributes - use variable color
670:         if highlightName.contains("attribute") {
671:             return _variableColor
672:         }
673:         
674:         // Spell checking highlights - ignore (return nil to use default)
675:         if highlightName.contains("spell") {
676:             return nil
677:         }
678:         
679:         // Include/import statements - use keyword color
680:         if highlightName.contains("include") {
681:             return _keywordColor
682:         }
683:         
684:         // Default: use standard text color
685:         return nil
686:     }
687:     
688:     func fontTraits(for rawHighlightName: String) -> FontTraits {
689:         let highlightName = rawHighlightName.lowercased()
690:         
691:         // Make comments italic
692:         if highlightName.contains("comment") {
693:             return .italic
694:         }
695:         
696:         // Make keywords bold
697:         if highlightName.contains("keyword") {
698:             return .bold
699:         }
700:         


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 700, "end_line": 741}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 701-741 of 741)
────────────────────────────────────────
701:         return []
702:     }
703: }
704: 
705: 
706: 
707: // MARK: - Preview
708: #if DEBUG
709: struct RunestoneEditorView_Previews: PreviewProvider {
710:     @State static var text = """
711:     func hello() {
712:         print("Hello, World!")
713:     }
714:     
715:     // This is a comment
716:     let number = 42
717:     let string = "test"
718:     """
719:     @State static var scrollOffset: CGFloat = 0
720:     @State static var totalLines = 7
721:     @State static var currentLineNumber = 1
722:     @State static var currentColumn = 1
723:     @State static var cursorIndex = 0
724:     
725:     static var previews: some View {
726:         RunestoneEditorView(
727:             text: $text,
728:             filename: "test.swift",
729:             scrollOffset: $scrollOffset,
730:             totalLines: $totalLines,
731:             currentLineNumber: $currentLineNumber,
732:             currentColumn: $currentColumn,
733:             cursorIndex: $cursorIndex,
734:             isActive: true,
735:             fontSize: 14
736:         )
737:         .environmentObject(EditorCore())
738:     }
739: }
740: #endif
741: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 560, "end_line": 700}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 561-700 of 741)
────────────────────────────────────────
561:         _selectedLinesLineNumberColor
562:     }
563:     
564:     var selectedLinesGutterBackgroundColor: UIColor {
565:         _selectedLinesGutterBackgroundColor
566:     }
567:     
568:     var invisibleCharactersColor: UIColor {
569:         _invisibleCharactersColor
570:     }
571:     
572:     var pageGuideHairlineColor: UIColor {
573:         _pageGuideHairlineColor
574:     }
575:     
576:     var pageGuideBackgroundColor: UIColor {
577:         _pageGuideBackgroundColor
578:     }
579:     
580:     var markedTextBackgroundColor: UIColor {
581:         _markedTextBackgroundColor
582:     }
583:     
584:     // MARK: - Syntax Highlighting
585:     
586:     func textColor(for rawHighlightName: String) -> UIColor? {
587:         // Map TreeSitter highlight names to colors
588:         // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
589:         let highlightName = rawHighlightName.lowercased()
590:         
591:         // Debug: Log ALL highlight names to console (remove in production)
592:         // print("🎨 HIGHLIGHT: '\(rawHighlightName)'")
593:         
594:         // Keywords
595:         if highlightName.contains("keyword") {
596:             return _keywordColor
597:         }
598:         
599:         // JSON/Object keys - MUST return color for specific patterns
600:         // TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys
601:         // We handle specific patterns first, then skip generic "string" to avoid overwrite
602:         if highlightName.hasPrefix("string.special") ||
603:            highlightName.contains("label") ||
604:            highlightName.contains("property.definition") {
605:             return _variableColor  // Light blue #9CDCFE for keys
606:         }
607:         
608:         // Strings - but NOT if it's JUST "string" (let specific matches win)
609:         // Only color strings that are clearly values, not potential keys
610:         if highlightName.contains("string") {
611:             // If it's exactly "string" with no qualifiers, it might be a key
612:             // that was already colored by string.special.key - return nil to not overwrite
613:             if rawHighlightName == "string" {
614:                 // For pure "string" captures, still color them (they're values)
615:                 // The issue is ordering - specific patterns should come AFTER in Runestone
616:                 return _stringColor
617:             }
618:             return _stringColor  // Orange #CE9178 for string values
619:         }
620:         
621:         // Numbers and constants
622:         if highlightName.contains("number") || highlightName == "constant.numeric" {
623:             return _numberColor
624:         }
625:         
626:         // Comments
627:         if highlightName.contains("comment") {
628:             return _commentColor
629:         }
630:         
631:         // Functions and methods
632:         if highlightName.contains("function") || highlightName.contains("method") {
633:             return _functionColor
634:         }
635:         
636:         // Types, classes, structs
637:         if highlightName.contains("type") || highlightName.contains("class") ||
638:            highlightName.contains("struct") || highlightName.contains("interface") ||
639:            highlightName.contains("enum") {
640:             return _typeColor
641:         }
642:         
643:         // Variables, parameters, properties
644:         if highlightName.contains("variable") || highlightName.contains("parameter") ||
645:            highlightName.contains("property") || highlightName.contains("field") {
646:             return _variableColor
647:         }
648:         
649:         // Constants and booleans - use keyword color
650:         if highlightName.contains("constant") || highlightName.contains("boolean") {
651:             return _keywordColor
652:         }
653:         
654:         // Operators - use keyword color
655:         if highlightName.contains("operator") {
656:             return _keywordColor
657:         }
658:         
659:         // Namespaces and modules - use type color
660:         if highlightName.contains("namespace") || highlightName.contains("module") {
661:             return _typeColor
662:         }
663:         
664:         // Tags (HTML, XML) - use type color
665:         if highlightName.contains("tag") {
666:             return _typeColor
667:         }
668:         
669:         // Attributes - use variable color
670:         if highlightName.contains("attribute") {
671:             return _variableColor
672:         }
673:         
674:         // Spell checking highlights - ignore (return nil to use default)
675:         if highlightName.contains("spell") {
676:             return nil
677:         }
678:         
679:         // Include/import statements - use keyword color
680:         if highlightName.contains("include") {
681:             return _keywordColor
682:         }
683:         
684:         // Default: use standard text color
685:         return nil
686:     }
687:     
688:     func fontTraits(for rawHighlightName: String) -> FontTraits {
689:         let highlightName = rawHighlightName.lowercased()
690:         
691:         // Make comments italic
692:         if highlightName.contains("comment") {
693:             return .italic
694:         }
695:         
696:         // Make keywords bold
697:         if highlightName.contains("keyword") {
698:             return .bold
699:         }
700:         


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 480, "end_line": 560}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 481-560 of 741)
────────────────────────────────────────
481:     private let _commentColor: UIColor
482:     private let _functionColor: UIColor
483:     private let _typeColor: UIColor
484:     private let _variableColor: UIColor
485:     
486:     init(
487:         fontSize: CGFloat,
488:         backgroundColor: UIColor,
489:         textColor: UIColor,
490:         gutterBackgroundColor: UIColor,
491:         gutterHairlineColor: UIColor,
492:         lineNumberColor: UIColor,
493:         selectedLineBackgroundColor: UIColor,
494:         selectedLinesLineNumberColor: UIColor,
495:         selectedLinesGutterBackgroundColor: UIColor,
496:         invisibleCharactersColor: UIColor,
497:         pageGuideHairlineColor: UIColor,
498:         pageGuideBackgroundColor: UIColor,
499:         markedTextBackgroundColor: UIColor,
500:         keywordColor: UIColor,
501:         stringColor: UIColor,
502:         numberColor: UIColor,
503:         commentColor: UIColor,
504:         functionColor: UIColor,
505:         typeColor: UIColor,
506:         variableColor: UIColor
507:     ) {
508:         self.fontSize = fontSize
509:         self._backgroundColor = backgroundColor
510:         self._textColor = textColor
511:         self._gutterBackgroundColor = gutterBackgroundColor
512:         self._gutterHairlineColor = gutterHairlineColor
513:         self._lineNumberColor = lineNumberColor
514:         self._selectedLineBackgroundColor = selectedLineBackgroundColor
515:         self._selectedLinesLineNumberColor = selectedLinesLineNumberColor
516:         self._selectedLinesGutterBackgroundColor = selectedLinesGutterBackgroundColor
517:         self._invisibleCharactersColor = invisibleCharactersColor
518:         self._pageGuideHairlineColor = pageGuideHairlineColor
519:         self._pageGuideBackgroundColor = pageGuideBackgroundColor
520:         self._markedTextBackgroundColor = markedTextBackgroundColor
521:         self._keywordColor = keywordColor
522:         self._stringColor = stringColor
523:         self._numberColor = numberColor
524:         self._commentColor = commentColor
525:         self._functionColor = functionColor
526:         self._typeColor = typeColor
527:         self._variableColor = variableColor
528:     }
529:     
530:     // MARK: - Theme Protocol Properties
531:     
532:     var font: UIFont {
533:         UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
534:     }
535:     
536:     var textColor: UIColor {
537:         _textColor
538:     }
539:     
540:     var gutterBackgroundColor: UIColor {
541:         _gutterBackgroundColor
542:     }
543:     
544:     var gutterHairlineColor: UIColor {
545:         _gutterHairlineColor
546:     }
547:     
548:     var lineNumberColor: UIColor {
549:         _lineNumberColor
550:     }
551:     
552:     var lineNumberFont: UIFont {
553:         UIFont.monospacedSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
554:     }
555:     
556:     var selectedLineBackgroundColor: UIColor {
557:         _selectedLineBackgroundColor
558:     }
559:     
560:     var selectedLinesLineNumberColor: UIColor {


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 440, "end_line": 485}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 441-485 of 741)
────────────────────────────────────────
441:                 }
442:             }
443:             
444:             // Column is the offset from the start of the current line
445:             columnNumber = cursorLocation - currentLineStart + 1
446:             
447:             // Update bindings on main thread to avoid SwiftUI state update warnings
448:             DispatchQueue.main.async {
449:                 self.parent.cursorIndex = cursorLocation
450:                 self.parent.currentLineNumber = lineNumber
451:                 self.parent.currentColumn = columnNumber
452:             }
453:         }
454:     }
455: }
456: 
457: // MARK: - Runestone Theme Implementation
458: 
459: /// Custom theme implementation for Runestone that maps app theme colors to editor appearance
460: class RunestoneEditorTheme: Runestone.Theme {
461:     let fontSize: CGFloat
462:     
463:     // Core colors
464:     private let _backgroundColor: UIColor
465:     private let _textColor: UIColor
466:     private let _gutterBackgroundColor: UIColor
467:     private let _gutterHairlineColor: UIColor
468:     private let _lineNumberColor: UIColor
469:     private let _selectedLineBackgroundColor: UIColor
470:     private let _selectedLinesLineNumberColor: UIColor
471:     private let _selectedLinesGutterBackgroundColor: UIColor
472:     private let _invisibleCharactersColor: UIColor
473:     private let _pageGuideHairlineColor: UIColor
474:     private let _pageGuideBackgroundColor: UIColor
475:     private let _markedTextBackgroundColor: UIColor
476:     
477:     // Syntax colors
478:     private let _keywordColor: UIColor
479:     private let _stringColor: UIColor
480:     private let _numberColor: UIColor
481:     private let _commentColor: UIColor
482:     private let _functionColor: UIColor
483:     private let _typeColor: UIColor
484:     private let _variableColor: UIColor
485:     


Now let me read the FontTraits and DefaultTheme to complete the picture:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/FontTraits.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/Appearance/FontTraits.swift

import Foundation

/// Traits to be applied to a font.
///
/// The font traits can be used with a ``Theme`` to change the appearance of the font when syntax highlighting text.
public struct FontTraits: OptionSet {
    /// Attribute creating a bold font.
    public static let bold = Self(rawValue: 1 << 0)
    /// Attribute creating an italic font.
    public static let italic = Self(rawValue: 1 << 1)

    /// The corresponding value of the raw type.
    public let rawValue: Int

    /// Creates a set of font traits.
    /// - Parameter rawValue: The raw vlaue to create the font traits from.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


Now let me look at how the TreeSitter captures are generated and processed:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift", "use_crawl4ai": false, "max_length": 15000}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift

import Foundation
import TreeSitter

protocol TreeSitterLanguageModeDelegate: AnyObject {
    func treeSitterLanguageMode(_ languageMode: TreeSitterInternalLanguageMode, bytesAt byteIndex: ByteCount) -> TreeSitterTextProviderResult?
}

final class TreeSitterInternalLanguageMode: InternalLanguageMode {
    weak var delegate: TreeSitterLanguageModeDelegate?
    var canHighlight: Bool {
        rootLanguageLayer.canHighlight
    }

    private let stringView: StringView
    private let parser: TreeSitterParser
    private let lineManager: LineManager
    private let rootLanguageLayer: TreeSitterLanguageLayer
    private let operationQueue = OperationQueue()
    private let parseLock = NSLock()

    init(language: TreeSitterInternalLanguage, languageProvider: TreeSitterLanguageProvider?, stringView: StringView, lineManager: LineManager) {
        self.stringView = stringView
        self.lineManager = lineManager
        operationQueue.name = "TreeSitterLanguageMode"
        operationQueue.qualityOfService = .default
        parser = TreeSitterParser(encoding: TSInputEncodingUTF16)
        rootLanguageLayer = TreeSitterLanguageLayer(
            language: language,
            languageProvider: languageProvider,
            parser: parser,
            stringView: stringView,
            lineManager: lineManager)
        parser.delegate = self
    }

    deinit {
        operationQueue.cancelAllOperations()
    }

    func parse(_ text: NSString) {
        parseLock.withLock {
            rootLanguageLayer.parse(text)
        }
    }

    func parse(_ text: NSString, completion: @escaping ((Bool) -> Void)) {
        operationQueue.cancelAllOperations()
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            if let self = self, let operation = operation, !operation.isCancelled {
                self.parse(text)
                DispatchQueue.main.async {
                    completion(!operation.isCancelled)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        operationQueue.addOperation(operation)
    }

    func textDidChange(_ change: TextChange) -> LineChangeSet {
        let bytesRemoved = change.byteRange.length
        let bytesAdded = change.bytesAdded
        let edit = TreeSitterInputEdit(
            startByte: change.byteRange.location,
            oldEndByte: change.byteRange.location + bytesRemoved,
            newEndByte: change.byteRange.location + bytesAdded,
            startPoint: TreeSitterTextPoint(change.startLinePosition),
            oldEndPoint: TreeSitterTextPoint(change.oldEndLinePosition),
            newEndPoint: TreeSitterTextPoint(change.newEndLinePosition))
        return rootLanguageLayer.apply(edit)
    }

    func captures(in range: ByteRange) -> [TreeSitterCapture] {
        rootLanguageLayer.captures(in: range)
    }

    func createLineSyntaxHighlighter() -> LineSyntaxHighlighter {
        TreeSitterSyntaxHighlighter(stringView: stringView, languageMode: self, operationQueue: operationQueue)
    }

    func currentIndentLevel(of line: DocumentLineNode, using indentStrategy: IndentStrategy) -> Int {
        let measurer = IndentLevelMeasurer(stringView: stringView)
        return measurer.indentLevel(lineStartLocation: line.location, lineTotalLength: line.data.totalLength, tabLength: indentStrategy.tabLength)
    }

    func strategyForInsertingLineBreak(from startLinePosition: LinePosition,
                                       to endLinePosition: LinePosition,
                                       using indentStrategy: IndentStrategy) -> InsertLineBreakIndentStrategy {
        let startLayerAndNode = rootLanguageLayer.layerAndNode(at: startLinePosition)
        let endLayerAndNode = rootLanguageLayer.layerAndNode(at: endLinePosition)
        if let indentationScopes = startLayerAndNode?.layer.language.indentationScopes ?? endLayerAndNode?.layer.language.indentationScopes {
            let indentController = TreeSitterIndentController(
                indentationScopes: indentationScopes,
                stringView: stringView,
                lineManager: lineManager,
                tabLength: indentStrategy.tabLength)
            let startNode = startLayerAndNode?.node
            let endNode = endLayerAndNode?.node
            return indentController.strategyForInsertingLineBreak(
                between: startNode,
                and: endNode,
                caretStartPosition: startLinePosition,
                caretEndPosition: endLinePosition)
        } else {
            return InsertLineBreakIndentStrategy(indentLevel: 0, insertExtraLineBreak: false)
        }
    }

    func syntaxNode(at linePosition: LinePosition) -> SyntaxNode? {
        if let node = rootLanguageLayer.layerAndNode(at: linePosition)?.node, let type = node.type {
            let startLocation = TextLocation(LinePosition(node.startPoint))
            let endLocation = TextLocation(LinePosition(node.endPoint))
            return SyntaxNode(type: type, startLocation: startLocation, endLocation: endLocation)
        } else {
            return nil
        }
    }

    func detectIndentStrategy() -> DetectedIndentStrategy {
        if let tree = rootLanguageLayer.tree {
            let detector = TreeSitterIndentStrategyDetector(lineManager: lineManager, tree: tree, stringView: stringView)
            return detector.detect()
        } else {
            return .unknown
        }
    }
}

extension TreeSitterInternalLanguageMode: TreeSitterParserDelegate {
    func parser(_ parser: TreeSitterParser, bytesAt byteIndex: ByteCount) -> TreeSitterTextProviderResult? {
        delegate?.treeSitterLanguageMode(self, bytesAt: byteIndex)
    }
}


Now I have enough information. Let me compile a comprehensive report:

>>>REPORT
# Runestone Library Syntax Highlighting Internals

## 1. HighlightName Enum (Internal Use)

**File:** `Sources/Runestone/TextView/Appearance/HighlightName.swift` (from GitHub)

The `HighlightName` enum is an **internal** enum with limited highlight names:
```swift
enum HighlightName: String {
    case comment
    case constantBuiltin = "constant.builtin"
    case constantCharacter = "constant.character"
    case constructor
    case function
    case keyword
    case number
    case `operator`
    case property
    case punctuation
    case string
    case type
    case variable
    case variableBuiltin = "variable.builtin"
}
```

**Critical behavior:** The custom initializer implements longest-match fallback:
```swift
init?(_ rawHighlightName: String) {
    var comps = rawHighlightName.split(separator: ".")
    while !comps.isEmpty {
        let candidateRawHighlightName = comps.joined(separator: ".")
        if let highlightName = Self(rawValue: candidateRawHighlightName) {
            self = highlightName
            return
        }
        comps.removeLast()  // Try shorter match
    }
    return nil  // No match found
}
```

**IMPORTANT:** This enum is only used by Runestone's `DefaultTheme`. Custom themes receive **raw strings** directly!

## 2. Theme Protocol & textColor(for:) Delegate

**File:** `Sources/Runestone/TextView/Appearance/Theme.swift`

```swift
public protocol Theme: AnyObject {
    var font: UIFont { get }
    var textColor: UIColor { get }
    // ... other properties ...
    
    // SYNTAX HIGHLIGHTING METHODS - receive RAW highlight name strings
    func textColor(for highlightName: String) -> UIColor?
    func font(for highlightName: String) -> UIFont?
    func fontTraits(for highlightName: String) -> FontTraits
    func shadow(for highlightName: String) -> NSShadow?
}
```

The Theme protocol methods receive the **raw capture name** from Tree-sitter's `highlights.scm` query file (e.g., "keyword", "string.special.key", "function.method.call").

## 3. How textColor(for:) Is Invoked - Full Pipeline

### Step-by-step execution flow:

1. **TextView renders a line** → calls `LineController`

2. **LineController** → creates `LineSyntaxHighlighterInput` with:
   - `attributedString`: the line's NSMutableAttributedString
   - `byteRange`: the byte range of the line

3. **TreeSitterSyntaxHighlighter.syntaxHighlight(input)** is called:
   ```swift
   func syntaxHighlight(_ input: LineSyntaxHighlighterInput) {
       let captures = languageMode.captures(in: input.byteRange)
       let tokens = self.tokens(for: captures, localTo: input.byteRange)
       setAttributes(for: tokens, on: input.attributedString)
   }
   ```

4. **captures(in:)** returns `[TreeSitterCapture]` from the parsed Tree-sitter tree

5. **For each capture**, creates a token by calling Theme methods:
   ```swift
   private func token(from capture: TreeSitterCapture, in byteRange: ByteRange) -> TreeSitterSyntaxHighlightToken {
       let range = NSRange(byteRange)
       let textColor = theme.textColor(for: capture.name)  // ← HERE!
       let shadow = theme.shadow(for: capture.name)
       let font = theme.font(for: capture.name)
       let fontTraits = theme.fontTraits(for: capture.name)
       return TreeSitterSyntaxHighlightToken(range: range, textColor: textColor, shadow: shadow, font: font, fontTraits: fontTraits)
   }
   ```

6. **setAttributes** applies tokens to the NSMutableAttributedString:
   ```swift
   for token in tokens {
       var attributes: [NSAttributedString.Key: Any] = [:]
       if let foregroundColor = token.textColor {
           attributes[.foregroundColor] = foregroundColor
       }
       // ... handle bold/italic traits, font, shadow ...
       attributedString.addAttributes(attributes, range: token.range)
   }
   ```

## 4. Project's Implementation

**File:** `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift`

The project correctly implements a custom `RunestoneEditorTheme` class (line 460) that:

1. **textColor(for:)** (lines 586-686): Uses string matching with `contains()` and `hasPrefix()`:
   ```swift
   func textColor(for rawHighlightName: String) -> UIColor? {
       let highlightName = rawHighlightName.lowercased()
       
       if highlightName.contains("keyword") { return _keywordColor }
       if highlightName.hasPrefix("string.special") { return _variableColor }
       if highlightName.contains("string") { return _stringColor }
       // ... etc
   }
   ```

2. **fontTraits(for:)** (lines 688-700): Returns `.italic` for comments, `.bold` for keywords

## 5. Key Insights

1. **HighlightName enum is NOT used by custom themes** - it's internal to DefaultTheme only
2. **Raw strings flow through** - Your theme's `textColor(for:)` receives exact Tree-sitter capture names like "string.special.key"
3. **Order matters** - Check specific patterns (e.g., "string.special") BEFORE generic ones (e.g., "string")
4. **Highlight names vary by language** - JSON uses "string.special.key", Swift uses "property", etc. Check each language's `highlights.scm` file

## Files Examined
- GitHub: `Sources/Runestone/TextView/Appearance/HighlightName.swift`
- GitHub: `Sources/Runestone/TextView/Appearance/Theme.swift`
- GitHub: `Sources/Runestone/TextView/Appearance/FontTraits.swift`
- GitHub: `Sources/Runestone/TextView/LineController/LineSyntaxHighlighter.swift`
- GitHub: `Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift`
- GitHub: `Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterInternalLanguageMode.swift`
- Local: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (lines 460-700)
- Local: `VSCodeiPadOS/VSCodeiPadOS/Services/RunestoneThemeAdapter.swift`
>>>END
