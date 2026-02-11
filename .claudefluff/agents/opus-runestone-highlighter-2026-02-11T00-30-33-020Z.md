# Agent: opus-runestone-highlighter
**Status:** done
**Tokens:** 20,243
**Cost:** $0.0000
**Time:** 2026-02-11T00:30:33.021Z

## Task
CRITICAL: Analyze how Runestone processes TreeSitter syntax highlighting. Read the ENTIRE TreeSitterSyntaxHighlighter.swift file and trace exactly how captures become colors. Find: 1) How captures are extracted from TreeSitter 2) How they're passed to the theme delegate 3) Why overlapping captures might ALL show same color. Report the exact code flow and any bugs.

## Response
I'll analyze the TreeSitter syntax highlighting flow in Runestone. Let me start by finding and reading the full TreeSitterSyntaxHighlighter.swift file.

>>>TOOL read_file
{"path": "Dependencies/Runestone/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift"}
>>>END

Let me search for the TreeSitterSyntaxHighlighter file location.

>>>TOOL search
{"query": "TreeSitterSyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitterSyntaxHighlighter"


Let me search more broadly for TreeSitter syntax highlighting related files.

>>>TOOL search
{"query": "TreeSitter syntax highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitter syntax highlight"


Let me explore the project structure to find Runestone-related files.

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


>>>TOOL search
{"query": "Runestone", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Runestone"


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


>>>TOOL read_file
{"path": "VSCodeiPadOS/Package.swift"}
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
{"query": "Runestone", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Runestone"


>>>TOOL search
{"query": "TreeSitter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitter"


>>>TOOL read_file
{"path": "VSCodeiPadOS/TreeSitterLanguages.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/TreeSitterLanguages.swift (lines 1-342 of 342)
────────────────────────────────────────
1: //
2: //  TreeSitterLanguages.swift
3: //  VSCodeiPadOS
4: //
5: //  Created on 2025-01-31.
6: //
7: 
8: import Foundation
9: 
10: // TODO: Uncomment these imports as TreeSitter Swift packages become available
11: // import TreeSitterSwift
12: // import TreeSitterJavaScript
13: // import TreeSitterTypeScript
14: // import TreeSitterPython
15: // import TreeSitterJSON
16: // import TreeSitterHTML
17: // import TreeSitterCSS
18: // import TreeSitterMarkdown
19: // import TreeSitterGo
20: // import TreeSitterRust
21: // import TreeSitterRuby
22: // import TreeSitterJava
23: // import TreeSitterC
24: // import TreeSitterCPP
25: // import TreeSitterBash
26: // import TreeSitterYAML
27: // import TreeSitterSQL
28: //
29: // TODO: Additional languages from the current implementation:
30: // import TreeSitterKotlin        // For kt, kts files
31: // import TreeSitterObjectiveC     // For m, mm files
32: // import TreeSitterSCSS           // For scss, sass files
33: // import TreeSitterLess           // For less files
34: // import TreeSitterXML            // For xml, plist, svg files
35: // import TreeSitterGraphQL        // For graphql, gql files
36: // import TreeSitterPHP            // For php files
37: 
38: /// Provides language modes for syntax highlighting based on file extensions.
39: /// This struct maps file extensions and special filenames to their appropriate
40: /// TreeSitter language modes for syntax highlighting.
41: public struct TreeSitterLanguages {
42:     
43:     /// Returns the appropriate language mode for a given filename.
44:     /// - Parameter filename: The filename (with or without path) to analyze
45:     /// - Returns: A LanguageMode instance for the detected language, or PlainTextLanguageMode() if unknown
46:     public static func languageMode(for filename: String) -> LanguageMode {
47:         let lower = filename.lowercased()
48:         let ext = (filename as NSString).pathExtension.lowercased()
49:         
50:         // Special-case filenames without extensions
51:         let lastComponent = (filename as NSString).lastPathComponent.lowercased()
52:         if lastComponent == "dockerfile" || lastComponent == "dockerfile.*" {
53:             // Dockerfile is typically bash-like, could use TreeSitterBash when available
54:             return bashLanguageMode() // or PlainTextLanguageMode()
55:         }
56:         if lastComponent == ".env" || lower.hasSuffix("/.env") {
57:             return PlainTextLanguageMode()
58:         }
59:         
60:         switch ext {
61:         // Swift
62:         case "swift":
63:             return swiftLanguageMode()
64:         
65:         // JavaScript
66:         case "js", "mjs", "cjs":
67:             return javaScriptLanguageMode()
68:         case "jsx":
69:             // JSX typically uses JavaScript grammar with JSX extensions
70:             return javaScriptLanguageMode()
71:         
72:         // TypeScript
73:         case "ts", "mts", "cts":
74:             return typeScriptLanguageMode()
75:         case "tsx":
76:             // TSX typically uses TypeScript grammar with JSX extensions
77:             return typeScriptLanguageMode()
78:         
79:         // Python
80:         case "py", "pyw":
81:             return pythonLanguageMode()
82:         
83:         // Ruby
84:         case "rb", "ruby":
85:             return rubyLanguageMode()
86:         
87:         // Go
88:         case "go":
89:             return goLanguageMode()
90:         
91:         // Rust
92:         case "rs":
93:             return rustLanguageMode()
94:         
95:         // Java
96:         case "java":
97:             return javaLanguageMode()
98:         
99:         // Kotlin (TODO: may not have Swift package yet)
100:         case "kt", "kts":
101:             return kotlinLanguageMode()
102:         
103:         // C
104:         case "c", "h":
105:             return cLanguageMode()
106:         
107:         // C++
108:         case "cpp", "cc", "cxx", "hpp", "hh", "hxx":
109:             return cppLanguageMode()
110:         
111:         // Objective-C (TODO: may not have Swift package yet)
112:         case "m", "mm":
113:             return objectiveCLanguageMode()
114:         
115:         // HTML
116:         case "html", "htm":
117:             return htmlLanguageMode()
118:         
119:         // CSS
120:         case "css":
121:             return cssLanguageMode()
122:         
123:         // SCSS/SASS (TODO: may not have Swift package yet)
124:         case "scss", "sass":
125:             return scssLanguageMode()
126:         
127:         // Less (TODO: may not have Swift package yet)
128:         case "less":
129:             return lessLanguageMode()
130:         
131:         // JSON
132:         case "json", "jsonc":
133:             return jsonLanguageMode()
134:         
135:         // XML (TODO: may not have Swift package yet)
136:         case "xml", "plist", "svg":
137:             return xmlLanguageMode()
138:         
139:         // YAML
140:         case "yml", "yaml":
141:             return yamlLanguageMode()
142:         
143:         // SQL
144:         case "sql":
145:             return sqlLanguageMode()
146:         
147:         // Shell scripts
148:         case "sh", "bash", "zsh", "fish":
149:             return bashLanguageMode()
150:         
151:         // Dockerfile (when it has an extension)
152:         case "dockerfile":
153:             return bashLanguageMode() // or PlainTextLanguageMode()
154:         
155:         // GraphQL (TODO: may not have Swift package yet)
156:         case "graphql", "gql":
157:             return graphqlLanguageMode()
158:         
159:         // Markdown
160:         case "md", "markdown":
161:             return markdownLanguageMode()
162:         
163:         // PHP (TODO: may not have Swift package yet)
164:         case "php":
165:             return phpLanguageMode()
166:         
167:         // Environment files
168:         case "env":
169:             return PlainTextLanguageMode()
170:         
171:         default:
172:             return PlainTextLanguageMode()
173:         }
174:     }
175:     
176:     // MARK: - Language Mode Factory Methods
177:     
178:     private static func swiftLanguageMode() -> LanguageMode {
179:         // TODO: Return TreeSitterSwift() when package is available
180:         // return TreeSitterSwift()
181:         return PlainTextLanguageMode()
182:     }
183:     
184:     private static func javaScriptLanguageMode() -> LanguageMode {
185:         // TODO: Return TreeSitterJavaScript() when package is available
186:         // return TreeSitterJavaScript()
187:         return PlainTextLanguageMode()
188:     }
189:     
190:     private static func typeScriptLanguageMode() -> LanguageMode {
191:         // TODO: Return TreeSitterTypeScript() when package is available
192:         // return TreeSitterTypeScript()
193:         return PlainTextLanguageMode()
194:     }
195:     
196:     private static func pythonLanguageMode() -> LanguageMode {
197:         // TODO: Return TreeSitterPython() when package is available
198:         // return TreeSitterPython()
199:         return PlainTextLanguageMode()
200:     }
201:     
202:     private static func jsonLanguageMode() -> LanguageMode {
203:         // TODO: Return TreeSitterJSON() when package is available
204:         // return TreeSitterJSON()
205:         return PlainTextLanguageMode()
206:     }
207:     
208:     private static func htmlLanguageMode() -> LanguageMode {
209:         // TODO: Return TreeSitterHTML() when package is available
210:         // return TreeSitterHTML()
211:         return PlainTextLanguageMode()
212:     }
213:     
214:     private static func cssLanguageMode() -> LanguageMode {
215:         // TODO: Return TreeSitterCSS() when package is available
216:         // return TreeSitterCSS()
217:         return PlainTextLanguageMode()
218:     }
219:     
220:     private static func markdownLanguageMode() -> LanguageMode {
221:         // TODO: Return TreeSitterMarkdown() when package is available
222:         // return TreeSitterMarkdown()
223:         return PlainTextLanguageMode()
224:     }
225:     
226:     private static func goLanguageMode() -> LanguageMode {
227:         // TODO: Return TreeSitterGo() when package is available
228:         // return TreeSitterGo()
229:         return PlainTextLanguageMode()
230:     }
231:     
232:     private static func rustLanguageMode() -> LanguageMode {
233:         // TODO: Return TreeSitterRust() when package is available
234:         // return TreeSitterRust()
235:         return PlainTextLanguageMode()
236:     }
237:     
238:     private static func rubyLanguageMode() -> LanguageMode {
239:         // TODO: Return TreeSitterRuby() when package is available
240:         // return TreeSitterRuby()
241:         return PlainTextLanguageMode()
242:     }
243:     
244:     private static func javaLanguageMode() -> LanguageMode {
245:         // TODO: Return TreeSitterJava() when package is available
246:         // return TreeSitterJava()
247:         return PlainTextLanguageMode()
248:     }
249:     
250:     private static func cLanguageMode() -> LanguageMode {
251:         // TODO: Return TreeSitterC() when package is available
252:         // return TreeSitterC()
253:         return PlainTextLanguageMode()
254:     }
255:     
256:     private static func cppLanguageMode() -> LanguageMode {
257:         // TODO: Return TreeSitterCPP() when package is available
258:         // return TreeSitterCPP()
259:         return PlainTextLanguageMode()
260:     }
261:     
262:     private static func bashLanguageMode() -> LanguageMode {
263:         // TODO: Return TreeSitterBash() when package is available
264:         // return TreeSitterBash()
265:         return PlainTextLanguageMode()
266:     }
267:     
268:     private static func yamlLanguageMode() -> LanguageMode {
269:         // TODO: Return TreeSitterYAML() when package is available
270:         // return TreeSitterYAML()
271:         return PlainTextLanguageMode()
272:     }
273:     
274:     private static func sqlLanguageMode() -> LanguageMode {
275:         // TODO: Return TreeSitterSQL() when package is available
276:         // return TreeSitterSQL()
277:         return PlainTextLanguageMode()
278:     }
279:     
280:     // MARK: - Additional Language Factory Methods
281:     
282:     private static func kotlinLanguageMode() -> LanguageMode {
283:         // TODO: Return TreeSitterKotlin() when package is available
284:         return PlainTextLanguageMode()
285:     }
286:     
287:     private static func objectiveCLanguageMode() -> LanguageMode {
288:         // TODO: Return TreeSitterObjectiveC() when package is available
289:         return PlainTextLanguageMode()
290:     }
291:     
292:     private static func scssLanguageMode() -> LanguageMode {
293:         // TODO: Return TreeSitterSCSS() when package is available
294:         return PlainTextLanguageMode()
295:     }
296:     
297:     private static func lessLanguageMode() -> LanguageMode {
298:         // TODO: Return TreeSitterLess() when package is available
299:         return PlainTextLanguageMode()
300:     }
301:     
302:     private static func xmlLanguageMode() -> LanguageMode {
303:         // TODO: Return TreeSitterXML() when package is available
304:         return PlainTextLanguageMode()
305:     }
306:     
307:     private static func graphqlLanguageMode() -> LanguageMode {
308:         // TODO: Return TreeSitterGraphQL() when package is available
309:         return PlainTextLanguageMode()
310:     }
311:     
312:     private static func phpLanguageMode() -> LanguageMode {
313:         // TODO: Return TreeSitterPHP() when package is available
314:         return PlainTextLanguageMode()
315:     }
316: }
317: 
318: // MARK: - LanguageMode Protocol
319: 
320: /// Protocol that all TreeSitter language modes must conform to.
321: /// This will be implemented by each TreeSitter language wrapper.
322: public protocol LanguageMode {
323:     /// The name of the language
324:     var name: String { get }
325:     
326:     /// The file extensions associated with this language
327:     var extensions: [String] { get }
328:     
329:     /// Create a new language mode instance
330:     init()
331: }
332: 
333: // MARK: - Plain Text Language Mode
334: 
335: /// Fallback language mode for files without specific syntax highlighting.
336: public struct PlainTextLanguageMode: LanguageMode {
337:     public let name = "Plain Text"
338:     public let extensions: [String] = []
339:     
340:     public init() {}
341: }
342: 


Let me search for any actual syntax highlighting implementation or Runestone package references.

>>>TOOL search
{"query": "syntax highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "syntax highlight"


>>>TOOL search
{"query": "highlight", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "highlight"


Let me search for editor-related implementations.

>>>TOOL search
{"query": "textColor", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "textColor"


>>>TOOL search
{"query": "capture", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "capture"


>>>TOOL list_dir
{"path": "Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/
📁 Editor/
📁 Panels/


>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
   (empty directory)




>>>TOOL list_dir
{"path": "Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 Views/Editor/
   (empty directory)
(cached)


Let me check if there are any external dependencies or packages that might contain this code.

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


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimizations.md"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/SyntaxHighlighter_Optimizations.md (lines 1-69 of 69)
────────────────────────────────────────
1: # SyntaxHighlighter Performance Optimizations
2: 
3: ## Overview
4: This document describes the performance optimizations made to the SyntaxHighlighter class.
5: 
6: ## Key Optimizations
7: 
8: ### 1. Pre-compiled Regex Patterns
9: - **Before**: Regex patterns were compiled on every `highlight()` call
10: - **After**: All regex patterns are compiled once as static properties
11: - **Impact**: ~40-50% performance improvement
12: 
13: ### 2. NSRegularExpression Instead of Swift Regex
14: - **Before**: Using Swift's Regex type
15: - **After**: Using NSRegularExpression for better performance on iOS
16: - **Impact**: More efficient pattern matching
17: 
18: ### 3. Static Color and Font Properties
19: - **Before**: Colors and fonts created on each use
20: - **After**: Pre-created static properties
21: - **Impact**: Reduced object allocation overhead
22: 
23: ### 4. Efficient Range Operations
24: - **Before**: Multiple string searches for the same content
25: - **After**: Using NSString and NSRange for efficient range operations
26: - **Impact**: Faster range conversions and lookups
27: 
28: ### 5. Range Conflict Resolution
29: - **Before**: Overlapping highlights could cause issues
30: - **After**: Track highlighted ranges to prevent conflicts
31: - **Impact**: More accurate highlighting, prevents double-processing
32: 
33: ### 6. Combined Type Sets
34: - **Before**: Checking types and swiftUITypes separately
35: - **After**: Pre-combined set for single lookup
36: - **Impact**: Faster type checking
37: 
38: ## Performance Improvements
39: 
40: ### Estimated Performance Gains:
41: - **Small files (<1000 chars)**: 40-50% faster
42: - **Medium files (1000-5000 chars)**: 50-60% faster
43: - **Large files (>5000 chars)**: 60-70% faster
44: 
45: ### Memory Usage:
46: - Slightly higher static memory usage (pre-compiled patterns)
47: - Lower dynamic memory allocation during highlighting
48: - Overall memory efficiency improved for repeated highlighting
49: 
50: ## Usage
51: The API remains unchanged. Simply use the SyntaxHighlighter as before:
52: 
53: ```swift
54: let highlighter = SyntaxHighlighter()
55: highlighter.highlight(codeString)
56: let highlighted = highlighter.highlightedText
57: ```
58: 
59: ## Testing
60: Run the performance test to verify improvements:
61: ```swift
62: SyntaxHighlighterPerformanceTest.runPerformanceTest()
63: ```
64: 
65: ## Future Optimizations
66: 1. Implement incremental highlighting for real-time editing
67: 2. Add caching for recently highlighted code
68: 3. Consider background queue processing for very large files
69: 4. Implement language-specific highlighters for better accuracy


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


>>>TOOL search
{"query": "SyntaxHighlighter", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "SyntaxHighlighter"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS.xcodeproj"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS.xcodeproj/
📁 project.xcworkspace/
📁 xcshareddata/
   project.pbxproj
   project.pbxproj.backup
(cached)


>>>TOOL search
{"query": "Runestone", "glob": "project.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Runestone"


>>>TOOL search
{"query": "import Runestone", "glob": "*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "import Runestone"


Let me verify if there's any external package or pod reference to Runestone.

>>>TOOL search
{"query": "package", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "package"


>>>TOOL search
{"query": "theme", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "theme"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/
📁 Editor/
📁 Panels/
   _tmp.txt
   BranchMenu.swift
   CommandPalette.swift
   CommandPaletteView.swift
   DiffComponents.swift
   FileIconView.swift
   FileTreeView.swift
   GoToSymbol.swift
   LaunchConfigView.swift
   QuickOpen.swift
   RunConfigView.swift
   SidebarView.swift
   SnippetPickerView.swift
   StatusBarView.swift
   TabBarView.swift
   TasksView.swift
   WorkspaceSettingsView.swift
   WorkspaceTrustDialog.swift


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Editor/
   BreadcrumbsView.swift
   ColorPickerView.swift
   EditorSplitView.swift
   FoldingLayoutManager.swift
   GitGutterView.swift
   HoverInfoView.swift
   InlayHintsOverlay.swift
   InlineSuggestionView.swift
   JSONTreeView.swift
   MergeConflictView.swift
   MinimapView.swift
   ModifierTapGestureRecognizer.swift
   MultiCursorTextView.swift
   PeekDefinitionView.swift
   RunestoneEditorView 2.swift
   RunestoneEditorView.swift
   SplitEditorView.swift
   StickyHeaderView.swift
   SyntaxHighlightingTextView_Update.swift
   SyntaxHighlightingTextView.swift


Let me read the RunestoneEditorView.swift to find how it handles syntax highlighting.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 1-741 of 741)
────────────────────────────────────────
1: //
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
101:         
102:         // Set theme and appearance
103:         textView.theme = makeRunestoneTheme()
104:         textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
105:         
106:         // Content insets for padding
107:         textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
108:         
109:         // Set text with TreeSitter language support
110:         if let language = getTreeSitterLanguage(for: filename) {
111:             let state = TextViewState(text: text, language: language)
112:             textView.setState(state)
113:         } else {
114:             // No language support - fallback to plain text
115:             textView.text = text
116:         }
117:         
118:         // Store reference for coordinator
119:         context.coordinator.textView = textView
120:         
121:         // Initial line count
122:         DispatchQueue.main.async {
123:             self.totalLines = self.countLines(in: text)
124:         }
125:         
126:         return textView
127:     }
128:     
129:     func updateUIView(_ textView: TextView, context: Context) {
130:         // Update coordinator's parent reference for current bindings
131:         context.coordinator.parent = self
132:         
133:         // Update theme if changed
134:         let currentThemeId = ThemeManager.shared.currentTheme.id
135:         if context.coordinator.lastThemeId != currentThemeId {
136:             context.coordinator.lastThemeId = currentThemeId
137:             textView.theme = makeRunestoneTheme()
138:             textView.backgroundColor = UIColor(ThemeManager.shared.currentTheme.editorBackground)
139:         }
140:         
141:         // Update font size if changed
142:         if context.coordinator.lastFontSize != fontSize {
143:             context.coordinator.lastFontSize = fontSize
144:             textView.theme = makeRunestoneTheme()
145:         }
146:         
147:         // Update settings if changed (live toggle support)
148:         if textView.showLineNumbers != showLineNumbers {
149:             textView.showLineNumbers = showLineNumbers
150:         }
151:         if textView.isLineWrappingEnabled != wordWrapEnabled {
152:             textView.isLineWrappingEnabled = wordWrapEnabled
153:         }
154:         
155:         // CRITICAL: Only call setState() when safe (not during active editing)
156:         // Calling setState() during editing corrupts Runestone's lineManager
157:         // and causes crash at TextEditHelper.swift:27 (force unwrap on linePosition)
158:         
159:         let isFileSwitching = context.coordinator.lastFilename != filename
160:         let currentText = textView.text
161:         let textChanged = currentText != text
162:         let isActivelyEditing = textView.isFirstResponder
163:         
164:         if isFileSwitching {
165:             // User switched to a different file - safe to call setState()
166:             context.coordinator.lastFilename = filename
167:             context.coordinator.hasBeenEdited = false
168:             
169:             if let language = getTreeSitterLanguage(for: filename) {
170:                 let state = TextViewState(text: text, language: language)
171:                 textView.setState(state)
172:             } else {
173:                 textView.text = text
174:             }
175:             
176:             // Reset cursor to start for new file
177:             textView.selectedRange = NSRange(location: 0, length: 0)
178:             
179:             // Update line count
180:             DispatchQueue.main.async {
181:                 self.totalLines = self.countLines(in: text)
182:             }
183:         } else if textChanged && !context.coordinator.hasBeenEdited && !isActivelyEditing && !context.coordinator.isUpdatingFromTextView {
184:             // Text changed externally (e.g., initial load, external modification)
185:             // Safe to update since user hasn't started editing yet
186:             if let language = getTreeSitterLanguage(for: filename) {
187:                 let state = TextViewState(text: text, language: language)
188:                 textView.setState(state)
189:             } else {
190:                 textView.text = text
191:             }
192:             
193:             // Update line count
194:             DispatchQueue.main.async {
195:                 self.totalLines = self.countLines(in: text)
196:             }
197:         }
198:         // If user HAS edited OR is actively editing, DO NOTHING
199:         // Let the user's edits remain - don't corrupt the lineManager
200:     }
201:     
202:     // MARK: - Runestone Theme Factory
203:     
204:     private func makeRunestoneTheme() -> RunestoneEditorTheme {
205:         let appTheme = ThemeManager.shared.currentTheme
206:         return RunestoneEditorTheme(
207:             fontSize: fontSize,
208:             backgroundColor: UIColor(appTheme.editorBackground),
209:             textColor: UIColor(appTheme.editorForeground),
210:             gutterBackgroundColor: UIColor(appTheme.editorBackground),
211:             gutterHairlineColor: UIColor(appTheme.lineNumber).withAlphaComponent(0.3),
212:             lineNumberColor: UIColor(appTheme.lineNumber),
213:             selectedLineBackgroundColor: UIColor(appTheme.currentLineHighlight),
214:             selectedLinesLineNumberColor: UIColor(appTheme.lineNumberActive),
215:             selectedLinesGutterBackgroundColor: UIColor(appTheme.currentLineHighlight),
216:             invisibleCharactersColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.3),
217:             pageGuideHairlineColor: UIColor(appTheme.editorForeground).withAlphaComponent(0.1),
218:             pageGuideBackgroundColor: UIColor(appTheme.editorBackground),
219:             markedTextBackgroundColor: UIColor(appTheme.selection).withAlphaComponent(0.5),
220:             keywordColor: UIColor(appTheme.keyword),
221:             stringColor: UIColor(appTheme.string),
222:             numberColor: UIColor(appTheme.number),
223:             commentColor: UIColor(appTheme.comment),
224:             functionColor: UIColor(appTheme.function),
225:             typeColor: UIColor(appTheme.type),
226:             variableColor: UIColor(appTheme.variable)
227:         )
228:     }
229:     
230:     // MARK: - Language Mode Mapping
231:     
232:     /// Gets the actual TreeSitter Language object for a given filename
233:     /// Returns nil for plain text files (no syntax highlighting)
234:     private func getTreeSitterLanguage(for filename: String) -> Runestone.TreeSitterLanguage? {
235:         let ext = (filename as NSString).pathExtension.lowercased()
236:         let lastComponent = (filename as NSString).lastPathComponent.lowercased()
237:         
238:         // Special-case filenames without extensions
239:         if lastComponent == "dockerfile" || lastComponent.hasPrefix("dockerfile.") {
240:             return nil // Bash support not in package list yet
241:         }
242:         if lastComponent == ".env" || lastComponent.hasPrefix(".env.") {
243:             return nil // Plain text
244:         }
245:         if lastComponent == "makefile" || lastComponent == "gnumakefile" {
246:             return nil // Bash support not in package list yet
247:         }
248:         if lastComponent == "podfile" || lastComponent == "gemfile" {
249:             return nil // Ruby support not in package list yet
250:         }
251:         if lastComponent == "package.json" || lastComponent == "tsconfig.json" {
252:             return TreeSitterLanguage.json
253:         }
254:         
255:         switch ext {
256:         // Swift
257:         case "swift":
258:             return TreeSitterLanguage.swift
259:         
260:         // JavaScript
261:         case "js", "mjs", "cjs", "jsx":
262:             return TreeSitterLanguage.javaScript
263:         
264:         // TypeScript - use JavaScript as fallback
265:         case "ts", "mts", "cts", "tsx":
266:             return TreeSitterLanguage.javaScript
267:         
268:         // Python
269:         case "py", "pyw", "pyi":
270:             return TreeSitterLanguage.python
271:         
272:         // Go
273:         case "go":
274:             return TreeSitterLanguage.go
275:         
276:         // Rust
277:         case "rs":
278:             return TreeSitterLanguage.rust
279:         
280:         // JSON
281:         case "json", "jsonc":
282:             return TreeSitterLanguage.json
283:         
284:         // HTML
285:         case "html", "htm", "xhtml":
286:             return TreeSitterLanguage.html
287:         
288:         // CSS
289:         case "css", "scss":
290:             return TreeSitterLanguage.css
291:         
292:         // XML - use HTML as fallback
293:         case "xml", "plist", "svg":
294:             return TreeSitterLanguage.html
295:         
296:         // Default - no syntax highlighting
297:         default:
298:             return nil
299:         }
300:     }
301: 
302:     
303:     // MARK: - Helpers
304:     
305:     private func countLines(in text: String) -> Int {
306:         guard !text.isEmpty else { return 1 }
307:         var count = 1
308:         var index = text.startIndex
309:         while index < text.endIndex {
310:             if text[index] == "\n" {
311:                 count += 1
312:             }
313:             index = text.index(after: index)
314:         }
315:         return count
316:     }
317:     
318:     // MARK: - Coordinator
319:     
320:     class Coordinator: NSObject, TextViewDelegate {
321:         var parent: RunestoneEditorView
322:         weak var textView: TextView?
323:         var isUpdatingFromTextView = false
324:         var lastFontSize: CGFloat = 14.0
325:         var lastThemeId: String = ""
326:         var currentLanguage: Language?
327:         
328:         // Track file identity to know when to call setState()
329:         var lastFilename: String = ""
330:         var hasBeenEdited: Bool = false
331:         
332:         // Debounced text sync to avoid SwiftUI re-renders on every keystroke
333:         private var textSyncWorkItem: DispatchWorkItem?
334:         private let debounceInterval: TimeInterval = 0.5 // 500ms
335:         
336:         init(_ parent: RunestoneEditorView) {
337:             self.parent = parent
338:             self.lastFontSize = parent.fontSize
339:             self.lastThemeId = ThemeManager.shared.currentTheme.id
340:             self.lastFilename = parent.filename
341:         }
342:         
343:         deinit {
344:             // Cancel any pending debounced updates
345:             textSyncWorkItem?.cancel()
346:         }
347:         
348:         // MARK: - TextViewDelegate
349:         
350:         func textViewDidChange(_ textView: TextView) {
351:             // Mark that user has edited - blocks setState() calls until file switch
352:             hasBeenEdited = true
353:             
354:             // Cancel any pending debounced update
355:             textSyncWorkItem?.cancel()
356:             
357:             // Create new debounced work item
358:             let workItem = DispatchWorkItem { [weak self] in
359:                 guard let self = self else { return }
360:                 self.isUpdatingFromTextView = true
361:                 defer { self.isUpdatingFromTextView = false }
362:                 
363:                 // Update text binding (debounced - only after typing stops)
364:                 self.parent.text = textView.text
365:                 
366:                 // Update line count
367:                 DispatchQueue.main.async {
368:                     self.parent.totalLines = self.parent.countLines(in: textView.text)
369:                 }
370:             }
371:             
372:             // Schedule the update after debounce interval
373:             textSyncWorkItem = workItem
374:             DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
375:         }
376:         
377:         /// Immediately sync text to SwiftUI binding (call on save/tab-switch)
378:         func syncTextImmediately() {
379:             // Cancel any pending debounced update
380:             textSyncWorkItem?.cancel()
381:             
382:             guard let textView = textView else { return }
383:             
384:             isUpdatingFromTextView = true
385:             defer { isUpdatingFromTextView = false }
386:             
387:             // Immediate sync
388:             parent.text = textView.text
389:             parent.totalLines = parent.countLines(in: textView.text)
390:         }
391:         
392:         func textViewDidChangeSelection(_ textView: TextView) {
393:             updateCursorPosition(in: textView)
394:         }
395:         
396:         func textViewDidBeginEditing(_ textView: TextView) {
397:             // Could be used for focus handling
398:         }
399:         
400:         func textViewDidEndEditing(_ textView: TextView) {
401:             // Could be used for focus handling
402:         }
403:         
404:         func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
405:             // Handle Tab key for autocomplete acceptance
406:             if text == "\t" {
407:                 if let onAccept = parent.onAcceptAutocomplete, onAccept() {
408:                     return false
409:                 }
410:             }
411:             
412:             // Handle Escape key for autocomplete dismissal
413:             // Note: Escape key events are typically handled via key commands, not here
414:             
415:             return true
416:         }
417:         
418:         func scrollViewDidScroll(_ scrollView: UIScrollView) {
419:             // Update scroll offset binding for gutter synchronization
420:             DispatchQueue.main.async {
421:                 self.parent.scrollOffset = scrollView.contentOffset.y
422:             }
423:         }
424:         
425:         // MARK: - Cursor Position Calculation
426:         
427:         private func updateCursorPosition(in textView: TextView) {
428:             let selectedRange = textView.selectedRange
429:             let text = textView.text as NSString
430:             let cursorLocation = selectedRange.location
431:             
432:             // Calculate line and column from cursor location
433:             var lineNumber = 1
434:             var columnNumber = 1
435:             var currentLineStart = 0
436:             
437:             for i in 0..<min(cursorLocation, text.length) {
438:                 if text.character(at: i) == UInt16(UnicodeScalar("\n").value) {
439:                     lineNumber += 1
440:                     currentLineStart = i + 1
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


Now I can see this app uses the Runestone framework. The theme delegate method `textColor(for rawHighlightName: String)` at lines 586-686 is how captures become colors. Let me search for the actual Runestone package source to understand the full flow.

>>>TOOL search
{"query": "TreeSitterSyntaxHighlighter", "glob": "*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitterSyntaxHighlighter"


Let me search for Runestone package files or any documentation about its highlighting flow.

>>>TOOL search
{"query": "textColor for highlightName", "glob": "*"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "textColor for highlightName"


Let me search for any Runestone package cache or local copy.

>>>TOOL list_dir
{"path": ".build"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
Error: Directory ".build" not found


Let me check if there are any SPM or Xcode package dependencies cached locally.

>>>TOOL search
{"query": "import Runestone", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "import Runestone"


Let me try a web search to understand how Runestone's TreeSitter syntax highlighting works internally.

>>>TOOL web_search
{"query": "Runestone Swift TreeSitter syntax highlighting textColor highlightName captures how it works source code", "max_results": 5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "Runestone Swift TreeSitter syntax highlighting textColor highlightName captures how it works source code" (5 results):

1. **Syntax Highlighting - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html
   The Tree-sitter syntax highlighting system can help you to achieve this by keeping track of local scopes and variables. The local variables query is different from the highlights query in that, while the highlights query uses arbitrary capture names, which can then be mapped to colors, the locals variable query uses a fixed set of capture names ...

2. **tree-sitter/docs/src/3-syntax-highlighting.md at master - GitHub**
   https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/3-syntax-highlighting.md
   This document explains how the Tree-sitter syntax highlighting system works, using the command line interface. If you are using tree-sitter-highlight library (either from C or from Rust), all of these concepts are still applicable, but the configuration data is provided using in-memory objects, rather than files.

3. **Syntax Highlighting Queries | tree-sitter/tree-sitter-javascript | DeepWiki**
   https://deepwiki.com/tree-sitter/tree-sitter-javascript/4.1-syntax-highlighting-queries
   This document covers the syntax highlighting query system in tree-sitter-javascript, which defines how JavaScript and JSX code should be colorized and styled in editors and other tools. The highlighting queries map AST nodes produced by the parser to semantic highlight categories that editors can render with appropriate colors and styles.

4. **Creating a Theme | Documentation - docs.runestone.app**
   https://docs.runestone.app/documentation/runestone/creatingatheme/
   The theme determines the text styling and colors to use when syntax highlighting text. Implement the following methods on Theme to specify the text styling and color of syntax highlighted text.

5. **tree-sitter/docs/section-4-syntax-highlighting.md at master**
   https://gitea.com/tree-sitter/tree-sitter/src/branch/master/docs/section-4-syntax-highlighting.md
   The Tree-sitter highlighting system works by annotating ranges of source code with logical &quot;highlight names&quot; like function.method, type.builtin, keyword, etc. In order to decide what color should be used for rendering each highlight, a theme is needed.


>>>TOOL web_fetch
{"url": "https://docs.runestone.app/documentation/runestone/creatingatheme/", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://docs.runestone.app/documentation/runestone/creatingatheme/

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.61s 
[SCRAPE].. ◆ https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.01s 
[COMPLETE] ● https://docs.runestone.app/documentation/runestone/creatingatheme/ 
| ✓ | ⏱: 0.62s 
[Skip Navigation](https://docs.runestone.app/documentation/runestone/creatingatheme/#main)
## [ Runestone  ](https://docs.runestone.app/documentation/runestone)
Navigator is loading 
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


Let me search for the Runestone source code to find the TreeSitterSyntaxHighlighter implementation.

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/blob/main/S...one/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 1.15s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/blob/main/S...one/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/blob/main/S...one/TreeSitter/TreeSitterSynt
axHighlighter.swift  | ✓ | ⏱: 1.20s 
[Skip to content](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTreeSitter%2FTreeSitterSyntaxHighlighter.swift)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTreeSitter%2FTreeSitterSyntaxHighlighter.swift)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Fblob%2Fmain%2FSources%2FRunestone%2FTreeSitter%2FTreeSitterSyntaxHighlighter.swift)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift) to refresh your session. Dismiss alert
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
  4. /[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter)


/
# TreeSitterSyntaxHighlighter.swift
/
Copy path
404 - page not found
The 
main
branch of 
Runestone
does not contain the path 
Sources/Runestone/TreeSitter/TreeSitterSyntaxHighlighter.swift.
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter     
| ✓ | ⏱: 1.27s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter     
| ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter     
| ✓ | ⏱: 1.31s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTreeSitter)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTreeSitter)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TreeSitter) to refresh your session. Dismiss alert
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
        * TreeSitterCapture.swift
        * TreeSitterInputEdit.swift
        * TreeSitterNode.swift
        * TreeSitterParser.swift
        * TreeSitterPredicate.swift
        * TreeSitterPredicateMapper.swift
        * TreeSitterQuery.swift
        * TreeSitterQueryCursor.swift
        * TreeSitterQueryMatch.swift
        * TreeSitterTextInput.swift
        * TreeSitterTextPoint.swift
        * TreeSitterTextPredicate.swift
        * TreeSitterTextRange.swift
        * TreeSitterTree.swift
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
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TreeSitter)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TreeSitter)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)


/
# TreeSitter
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)  
[TreeSitterCapture.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterCapture.swift "TreeSitterCapture.swift") | [TreeSitterCapture.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterCapture.swift "TreeSitterCapture.swift") |  |   
[TreeSitterInputEdit.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterInputEdit.swift "TreeSitterInputEdit.swift") | [TreeSitterInputEdit.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterInputEdit.swift "TreeSitterInputEdit.swift") |  |   
[TreeSitterNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterNode.swift "TreeSitterNode.swift") | [TreeSitterNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterNode.swift "TreeSitterNode.swift") |  |   
[TreeSitterParser.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterParser.swift "TreeSitterParser.swift") | [TreeSitterParser.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterParser.swift "TreeSitterParser.swift") |  |   
[TreeSitterPredicate.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterPredicate.swift "TreeSitterPredicate.swift") | [TreeSitterPredicate.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterPredicate.swift "TreeSitterPredicate.swift") |  |   
[TreeSitterPredicateMapper.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterPredicateMapper.swift "TreeSitterPredicateMapper.swift") | [TreeSitterPredicateMapper.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterPredicateMapper.swift "TreeSitterPredicateMapper.swift") |  |   
[TreeSitterQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQuery.swift "TreeSitterQuery.swift") | [TreeSitterQuery.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQuery.swift "TreeSitterQuery.swift") |  |   
[TreeSitterQueryCursor.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQueryCursor.swift "TreeSitterQueryCursor.swift") | [TreeSitterQueryCursor.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQueryCursor.swift "TreeSitterQueryCursor.swift") |  |   
[TreeSitterQueryMatch.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQueryMatch.swift "TreeSitterQueryMatch.swift") | [TreeSitterQueryMatch.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterQueryMatch.swift "TreeSitterQueryMatch.swift") |  |   
[TreeSitterTextInput.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextInput.swift "TreeSitterTextInput.swift") | [TreeSitterTextInput.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextInput.swift "TreeSitterTextInput.swift") |  |   
[TreeSitterTextPoint.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextPoint.swift "TreeSitterTextPoint.swift") | [TreeSitterTextPoint.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextPoint.swift "TreeSitterTextPoint.swift") |  |   
[TreeSitterTextPredicate.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextPredicate.swift "TreeSitterTextPredicate.swift") | [TreeSitterTextPredicate.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextPredicate.swift "TreeSitterTextPredicate.swift") |  |   
[TreeSitterTextRange.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextRange.swift "TreeSitterTextRange.swift") | [TreeSitterTextRange.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTextRange.swift "TreeSitterTextRange.swift") |  |   
[TreeSitterTree.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTree.swift "TreeSitterTree.swift") | [TreeSitterTree.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TreeSitter/TreeSitterTree.swift "TreeSitterTree.swift") |  |   
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


Let me fetch the key Runestone source files to understand the capture flow.

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TreeSitter/TreeSitterCapture.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TreeSitter/TreeSitterCapture.swift

import Foundation

final class TreeSitterCapture {
    let node: TreeSitterNode
    let index: UInt32
    let name: String
    let byteRange: ByteRange
    let properties: [String: String]
    let textPredicates: [TreeSitterTextPredicate]
    let nameComponentCount: Int

    convenience init(node: TreeSitterNode, index: UInt32, name: String, predicates: [TreeSitterPredicate]) {
        self.init(node: node, index: index, name: name, byteRange: node.byteRange, predicates: predicates)
    }

    private init(node: TreeSitterNode, index: UInt32, name: String, byteRange: ByteRange, predicates: [TreeSitterPredicate]) {
        let predicateMapResult = TreeSitterPredicateMapper.map(predicates)
        self.node = node
        self.index = index
        self.name = name
        self.byteRange = byteRange
        self.properties = predicateMapResult.properties
        self.textPredicates = predicateMapResult.textPredicates
        self.nameComponentCount = name.split(separator: ".").count
    }
}

extension TreeSitterCapture: CustomDebugStringConvertible {
    var debugDescription: String {
        "[TreeSitterCapture byteRange=\(byteRange) name=\(name) properties=\(properties) textPredicates=\(textPredicates)]"
    }
}


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/StringSyntaxHighlighter.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/StringSyntaxHighlighter.swift

import UIKit

/// Syntax highlights a string.
///
/// An instance of `StringSyntaxHighlighter` can be used to syntax highlight a string without needing to create a `TextView`.
public final class StringSyntaxHighlighter {
    /// The theme to use when syntax highlighting the text.
    public var theme: Theme
    /// The language to use when parsing the text.
    public var language: TreeSitterLanguage
    /// Object that can provide embedded languages on demand. A strong reference will be stored to the language provider.
    public var languageProvider: TreeSitterLanguageProvider?
    /// The number of points by which to adjust kern.
    ///
    /// The default value is 0 meaning that kerning is disabled.
    public var kern: CGFloat = 0
    /// The tab length determines the width of the tab measured in space characers.
    ///
    /// The default value is 4 meaning that a tab is four spaces wide.
    public var tabLength: Int = 4
    /// The line-height is multiplied with the value.
    public var lineHeightMultiplier: CGFloat = 1

    /// Creates an object that can syntax highlight a text.
    /// - Parameters:
    ///   - theme: The theme to use when syntax highlighting the text.
    ///   - language: The language to use when parsing the text
    ///   - languageProvider: Object that can provide embedded languages on demand. A strong reference will be stored to the language provider..
    public init(
        theme: Theme = DefaultTheme(),
        language: TreeSitterLanguage,
        languageProvider: TreeSitterLanguageProvider? = nil
    ) {
        self.theme = theme
        self.language = language
        self.languageProvider = languageProvider
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Syntax highlights the text using the configured syntax highlighter.
    /// - Parameter text: The text to be syntax highlighted.
    /// - Returns: An attributed string containing the syntax highlighted text.
    public func syntaxHighlight(_ text: String) -> NSAttributedString {
        let mutableString = NSMutableString(string: text)
        let stringView = StringView(string: mutableString)
        let lineManager = LineManager(stringView: stringView)
        lineManager.rebuild()
        let languageMode = TreeSitterLanguageMode(language: language, languageProvider: languageProvider)
        let internalLanguageMode = languageMode.makeInternalLanguageMode(
            stringView: stringView,
            lineManager: lineManager
        )
        internalLanguageMode.parse(mutableString)
        let tabWidth = TabWidthMeasurer.tabWidth(tabLength: tabLength, font: theme.font)
        let mutableAttributedString = NSMutableAttributedString(string: text)
        let defaultAttributes = DefaultStringAttributes(
            textColor: theme.textColor,
            font: theme.font,
            kern: kern,
            tabWidth: tabWidth
        )
        defaultAttributes.apply(to: mutableAttributedString)
        applyLineHeightMultiplier(to: mutableAttributedString)
        let byteRange = ByteRange(from: 0, to: text.byteCount)
        let syntaxHighlighter = internalLanguageMode.createLineSyntaxHighlighter()
        syntaxHighlighter.theme = theme
        let syntaxHighlighterInput = LineSyntaxHighlighterInput(
            attributedString: mutableAttributedString,
            byteRange: byteRange
        )
        syntaxHighlighter.syntaxHighlight(syntaxHighlighterInput)
        return mutableAttributedString
    }
}

private extension StringSyntaxHighlighter {
    private func applyLineHeightMultiplier(to attributedString: NSMutableAttributedString) {
        let scaledLineHeight = theme.font.totalLineHeight * lineHeightMultiplier
        let mutableParagraphStyle = getMutableParagraphStyle(from: attributedString)
        mutableParagraphStyle.lineSpacing = scaledLineHeight - theme.font.totalLineHeight
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.beginEditing()
        attributedString.removeAttribute(.paragraphStyle, range: range)
        attributedString.addAttribute(.paragraphStyle, value: mutableParagraphStyle, range: range)
        attributedString.endEditing()
    }

    private func getMutableParagraphStyle(
        from attributedString: NSMutableAttributedString
    ) -> NSMutableParagraphStyle {
        guard let attributeValue = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) else {
            return NSMutableParagraphStyle()
        }
        guard let paragraphStyle = attributeValue as? NSParagraphStyle else {
            fatalError("Expected .paragraphStyle attribute to be instance of NSParagraphStyle")
        }
        guard let mutableParagraphStyle = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle else {
            fatalError("Expected mutableCopy() to return an instance of NSMutableParagraphStyle")
        }
        return mutableParagraphStyle
    }
}


>>>TOOL web_search
{"query": "site:github.com/simonbs/Runestone LineSyntaxHighlighter syntaxHighlight captures textColor", "max_results": 5}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "site:github.com/simonbs/Runestone LineSyntaxHighlighter syntaxHighlight captures textColor" (5 results):

1. **Releases · simonbs/Runestone · GitHub**
   https://github.com/simonbs/Runestone/releases
   📝 Performant plain text editor for iOS with syntax highlighting, line numbers, invisible characters and much more. - simonbs/Runestone

2. **After upgrading TreeSitterLanguages from 0.1.6 to 0.1.7 ... - GitHub**
   https://github.com/simonbs/Runestone/issues/259
   What happened? In 0.2.12 with TreeSitterLanguages in 0.1.4 markdown bold text **bold** is parsed as HighlightName.strong in public func fontTraits(for rawHighlightName: String) -&gt; FontTraits This a...

3. **Cannot use with SwiftTreeSitter · Issue #294 - GitHub**
   https://github.com/simonbs/Runestone/issues/294
   What happened? I am developing a tree-sitter grammar for the ABC music notation. I was initially focusing on providing syntax highlighting with Runestone, but now that I am familiar with tree-sitte...

4. **Blocking UI on closing bracket deletion in medium size TS file #132**
   https://github.com/simonbs/Runestone/issues/132
   The reason for performing syntax highlighting on the main thread is to avoid the text being incorrectly colored immediately after editing. I&#x27;ve found it to be fine to perform this operation on the main thread as Runestone will rehighlight only a small amount of text when editing. Naturally, you found a case where this wasn&#x27;t true but that should be fixed now 😊 👍 1 rebornix reacted with ...

5. **Show character code point on selected code or current character at ...**
   https://github.com/simonbs/Runestone/issues/336
   Is your feature request related to a problem? No What solution would you like? I&#x27;d like to see the code point for the character I highlighted (or equivalent code unit in encoding code space) This i...


>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/LineSyntaxHighlighter.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
Error: https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/LineSyntaxHighlighter.swift returned 404


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
| ✓ | ⏱: 1.17s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 0.05s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView       
| ✓ | ⏱: 1.23s 
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
[Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") | [Appearance](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Appearance "Appearance") |  [No longer uses system colors (](https://github.com/simonbs/Runestone/commit/bea27981428993589e739985bf5e4f502c927de9 "No longer uses system colors \(#352\)")[#352](https://github.com/simonbs/Runestone/pull/352)[)](https://github.com/simonbs/Runestone/commit/bea27981428993589e739985bf5e4f502c927de9 "No longer uses system colors \(#352\)") | Feb 28, 2024  
[CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") | [CharacterPairs](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/CharacterPairs "CharacterPairs") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
[Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") | [Core](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Core "Core") |  [Scroll edge effect blurs line numbers on iOS 26 (](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)")[#404](https://github.com/simonbs/Runestone/pull/404)[)](https://github.com/simonbs/Runestone/commit/d490289ca660c6e2691e7a3f282d353ac99bded7 "Scroll edge effect blurs line numbers on iOS 26 \(#404\)") | Aug 31, 2025  
[Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") | [Gutter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Gutter "Gutter") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") | [Highlight](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Highlight "Highlight") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") | [Indent](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Indent "Indent") |  [Adds TabWidthMeasurer (](https://github.com/simonbs/Runestone/commit/e21d5accc8ac1fc4988cd0bbe61fedb7311e9deb "Adds TabWidthMeasurer \(#360\)

* Adds TabWidthMeasurer

* Fixes typo")[#360](https://github.com/simonbs/Runestone/pull/360)[)](https://github.com/simonbs/Runestone/commit/e21d5accc8ac1fc4988cd0bbe61fedb7311e9deb "Adds TabWidthMeasurer \(#360\)

* Adds TabWidthMeasurer

* Fixes typo") | Mar 16, 2024  
[InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") | [InvisibleCharacters](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/InvisibleCharacters "InvisibleCharacters") |  [Moves logic out of LayoutManager and into separate types (](https://github.com/simonbs/Runestone/commit/a1952da06a41d78697ff71adeb726038f2c04e39 "Moves logic out of LayoutManager and into separate types \(#184\)

* WIP services

* Moves files into separate folders

* Adds missing structure to documentation

* Moves services

* Only calls delegate when content size is invalid

* Fixes path to resources for default theme

* Passes invisible character configuration around

* Properly invalidates soft line break symbol

* Notifies delegate about updated gutter width

* Adds proper implementation of line number observer

* Fixes SwiftLint warnings

* Fixes unit tests

* Removes comments

* Sends gutter width updated when showLineNumbers changes

* Fixes issue where content size was not updated

* Removes comments

* Renames function")[#184](https://github.com/simonbs/Runestone/pull/184)[)](https://github.com/simonbs/Runestone/commit/a1952da06a41d78697ff71adeb726038f2c04e39 "Moves logic out of LayoutManager and into separate types \(#184\)

* WIP services

* Moves files into separate folders

* Adds missing structure to documentation

* Moves services

* Only calls delegate when content size is invalid

* Fixes path to resources for default theme

* Passes invisible character configuration around

* Properly invalidates soft line break symbol

* Notifies delegate about updated gutter width

* Adds proper implementation of line number observer

* Fixes SwiftLint warnings

* Fixes unit tests

* Removes comments

* Sends gutter width updated when showLineNumbers changes

* Fixes issue where content size was not updated

* Removes comments

* Renames function") | Sep 19, 2022  
[LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") | [LineController](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/LineController "LineController") |  [Adds DefaultStringAttributes (](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)")[#359](https://github.com/simonbs/Runestone/pull/359)[)](https://github.com/simonbs/Runestone/commit/392e97fd08b574cd15edc2e963c659215a4f5e60 "Adds DefaultStringAttributes \(#359\)") | Mar 16, 2024  
[Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") | [Navigation](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Navigation "Navigation") |  [Allow TextLocation to be created (](https://github.com/simonbs/Runestone/commit/81e23a9a9e90d52b5b407f60d378731875aaea6b "Allow TextLocation to be created \(#372\)")[#372](https://github.com/simonbs/Runestone/pull/372)[)](https://github.com/simonbs/Runestone/commit/81e23a9a9e90d52b5b407f60d378731875aaea6b "Allow TextLocation to be created \(#372\)") | May 13, 2024  
[PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") | [PageGuide](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/PageGuide "PageGuide") | [Compiles for visionOS](https://github.com/simonbs/Runestone/commit/5f8daeee2b1edb5e0ce022fcd2a831809f6e0579 "Compiles for visionOS") | Jul 9, 2023  
[SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") | [SearchAndReplace](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SearchAndReplace "SearchAndReplace") |  [Removes compiler version checks (](https://github.com/simonbs/Runestone/commit/0ebbd666729bd95d7864a28a11cb81259c54401e "Removes compiler version checks \(#318\)

* Removes compiler version checks

* Fixes SwiftLint errors")[#318](https://github.com/simonbs/Runestone/pull/318)[)](https://github.com/simonbs/Runestone/commit/0ebbd666729bd95d7864a28a11cb81259c54401e "Removes compiler version checks \(#318\)

* Removes compiler version checks

* Fixes SwiftLint errors") | Sep 24, 2023  
[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") | [SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting "SyntaxHighlighting") | [Add a lock around parse, to prevent concurrent access to the underlyi…](https://github.com/simonbs/Runestone/commit/36d91bfd44170935461618316e1433a1246c44fc "Add a lock around parse, to prevent concurrent access to the underlying parse tree. \(#367\)

* Add a lock around parse, as we can have both the OperationQueue-based parse and this parse happen at the same time

* Fixes SwiftLint violation

---------

Co-authored-by: Simon Støvring <mail@simonbs.dk>") | Apr 15, 2024  
[TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") | [TextSelection](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/TextSelection "TextSelection") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.09s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/Syntax
Highlighting         | ✓ | ⏱: 1.13s 
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
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting)
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
[Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") | [Internal](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal "Internal") |  |   
[PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") | [PlainText](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/PlainText "PlainText") |  |   
[TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") | [TreeSitter](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter "TreeSitter") |  |   
[LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") | [LanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/LanguageMode.swift "LanguageMode.swift") |  |   
[SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") | [SyntaxNode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/SyntaxNode.swift "SyntaxNode.swift") |  |   
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/S...Runestone/TextView/SyntaxHigh
lighting/TreeSitter  | ✓ | ⏱: 1.13s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S...Runestone/TextView/SyntaxHigh
lighting/TreeSitter  | ✓ | ⏱: 0.04s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S...Runestone/TextView/SyntaxHigh
lighting/TreeSitter  | ✓ | ⏱: 1.17s 
[Skip to content](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FTreeSitter)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FRunestone%2Ftree%2Fmain%2FSources%2FRunestone%2FTextView%2FSyntaxHighlighting%2FTreeSitter)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FRunestone)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter) to refresh your session. Dismiss alert
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
            * TreeSitterIndentationScopes.swift
            * TreeSitterLanguage.swift
            * TreeSitterLanguageMode.swift
            * TreeSitterLanguageProvider.swift
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
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter)
[](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter)History
## Breadcrumbs
  1. [Runestone](https://github.com/simonbs/Runestone/tree/main)
  2. /[Sources](https://github.com/simonbs/Runestone/tree/main/Sources)
  3. /[Runestone](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone)
  4. /[TextView](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView)
  5. /[SyntaxHighlighting](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)


/
# TreeSitter
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting)  
[TreeSitterIndentationScopes.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterIndentationScopes.swift "TreeSitterIndentationScopes.swift") | [TreeSitterIndentationScopes.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterIndentationScopes.swift "TreeSitterIndentationScopes.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[TreeSitterLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguage.swift "TreeSitterLanguage.swift") | [TreeSitterLanguage.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguage.swift "TreeSitterLanguage.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
[TreeSitterLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguageMode.swift "TreeSitterLanguageMode.swift") | [TreeSitterLanguageMode.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguageMode.swift "TreeSitterLanguageMode.swift") |  [Adds implicit_return SwiftLint rule (](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning")[#265](https://github.com/simonbs/Runestone/pull/265)[)](https://github.com/simonbs/Runestone/commit/1db0e1be270f758b762f87c8a585e6f9c6790028 "Adds implicit_return SwiftLint rule \(#265\)

* Adds implicit_return SwiftLint rule

* Fixes SwiftLint rules

* Fixes compile issue

* Fixes SwiftLint warning") | Feb 6, 2023  
[TreeSitterLanguageProvider.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguageProvider.swift "TreeSitterLanguageProvider.swift") | [TreeSitterLanguageProvider.swift](https://github.com/simonbs/Runestone/blob/main/Sources/Runestone/TextView/SyntaxHighlighting/TreeSitter/TreeSitterLanguageProvider.swift "TreeSitterLanguageProvider.swift") |  [Moves files into separate folders (](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)")[#183](https://github.com/simonbs/Runestone/pull/183)[)](https://github.com/simonbs/Runestone/commit/3ef4fc59acdd65ea0167e2d0cba29d3fbc15898c "Moves files into separate folders \(#183\)") | Sep 18, 2022  
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
ghlighting/Internal  | ✓ | ⏱: 1.18s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 0.06s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S...s/Runestone/TextView/SyntaxHi
ghlighting/Internal  | ✓ | ⏱: 1.24s 
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
{"url": "https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/Runestone/tree/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 1.16s 
[SCRAPE].. ◆ 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 0.07s 
[COMPLETE] ● 
https://github.com/simonbs/Runestone/tree/main/S.../TextView/SyntaxHighlighting/
Internal/TreeSitter  | ✓ | ⏱: 1.23s 
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
## History
[History](https://github.com/simonbs/Runestone/commits/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter)
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


Now let me fetch the key file - TreeSitterSyntaxHighlighter.swift:

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


Now let me fetch how captures are generated - the TreeSitterLanguageLayer.swift:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayer.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayer.swift

import Foundation

final class TreeSitterLanguageLayer {
    typealias LayerAndNodeTuple = (layer: TreeSitterLanguageLayer, node: TreeSitterNode)

    let language: TreeSitterInternalLanguage
    private(set) var tree: TreeSitterTree?
    var canHighlight: Bool {
        parser.language != nil && tree != nil
    }

    private let lineManager: LineManager
    private let parser: TreeSitterParser
    private let stringView: StringView
    private var childLanguageLayerStore = TreeSitterLanguageLayerStore()
    private weak var parentLanguageLayer: TreeSitterLanguageLayer?
    private let languageProvider: TreeSitterLanguageProvider?
    private var isEmpty: Bool {
        if let rootNode = tree?.rootNode {
            return rootNode.endByte - rootNode.startByte  LineChangeSet {
        let ranges = [tree?.rootNode.textRange].compactMap { $0 }
        return apply(edit, parsing: ranges)
    }

    func layerAndNode(at linePosition: LinePosition) -> LayerAndNodeTuple? {
        let point = TreeSitterTextPoint(linePosition)
        guard let node = tree?.rootNode.descendantForRange(from: point, to: point) else {
            return nil
        }
        var result: LayerAndNodeTuple = (layer: self, node: node)
        for childLanguageLayer in childLanguageLayerStore.allLayers {
            if let childRootNode = childLanguageLayer.tree?.rootNode, childRootNode.contains(point) {
                if let childResult = childLanguageLayer.layerAndNode(at: linePosition) {
                    if childResult.node.byteRange.length  LineChangeSet {
        // Apply edit to tree.
        let oldTree = tree
        tree?.apply(edit)
        prepareParser(toParse: ranges)
        tree = parser.parse(oldTree: tree)
        // Gather changed lines.
        let lineChangeSet = LineChangeSet()
        if let oldTree = oldTree, let newTree = tree {
            let changedRanges = oldTree.rangesChanged(comparingTo: newTree)
            for changedRange in changedRanges {
                let startRow = Int(changedRange.startPoint.row)
                let endRow = Int(changedRange.endPoint.row)
                for row in startRow ... endRow {
                    let line = lineManager.line(atRow: row)
                    lineChangeSet.markLineEdited(line)
                }
            }
        }
        let childLineChangeSet = updateChildLayers(applying: edit)
        lineChangeSet.union(with: childLineChangeSet)
        return lineChangeSet
    }

    private func prepareParser(toParse ranges: [TreeSitterTextRange]) {
        parser.language = language.languagePointer
        if !ranges.isEmpty && parentLanguageLayer != nil {
            parser.setIncludedRanges(ranges)
        } else {
            parser.removeAllIncludedRanges()
        }
    }

    private func parse(_ ranges: [TreeSitterTextRange], from text: NSString) {
        prepareParser(toParse: ranges)
        tree = parser.parse(text)
        childLanguageLayerStore.removeAll()
        guard let injectionsQuery = language.injectionsQuery, let node = tree?.rootNode else {
            return
        }
        let queryCursor = TreeSitterQueryCursor(query: injectionsQuery, node: node)
        queryCursor.execute()
        let captures = queryCursor.validCaptures(in: stringView)
        let injectedLanguages = injectedLanguages(from: captures)
        for injectedLanguage in injectedLanguages {
            if let childLanguageLayer = childLanguageLayer(withID: injectedLanguage.id, forLanguageNamed: injectedLanguage.languageName) {
                childLanguageLayer.parse([injectedLanguage.textRange], from: text)
            }
        }
    }
}

// MARK: - Syntax Highlighting
extension TreeSitterLanguageLayer {
    func captures(in range: ByteRange) -> [TreeSitterCapture] {
        guard !range.isEmpty else {
            return []
        }
        var captures = allValidCaptures(in: range)
        captures.sort(by: TreeSitterCapture.captureLayerSorting)
        return captures
    }

    private func allValidCaptures(in range: ByteRange) -> [TreeSitterCapture] {
        guard let tree = tree else {
            return []
        }
        guard let highlightsQuery = language.highlightsQuery else {
            return []
        }
        let queryCursor = TreeSitterQueryCursor(query: highlightsQuery, node: tree.rootNode)
        queryCursor.setQueryRange(range)
        queryCursor.execute()
        let captures = queryCursor.validCaptures(in: stringView)
        let capturesInChildren = childLanguageLayerStore.allLayers.reduce(into: []) { $0 += $1.allValidCaptures(in: range) }
        return captures + capturesInChildren
    }
}

// MARK: - Child Language Layers
private extension TreeSitterLanguageLayer {
    @discardableResult
    private func childLanguageLayer(withID id: UnsafeRawPointer, forLanguageNamed languageName: String) -> TreeSitterLanguageLayer? {
        if let childLanguageLayer = childLanguageLayerStore.layer(forKey: id) {
            return childLanguageLayer
        } else if let language = languageProvider?.treeSitterLanguage(named: languageName) {
            let childLanguageLayer = TreeSitterLanguageLayer(
                language: language.internalLanguage,
                languageProvider: languageProvider,
                parser: parser,
                stringView: stringView,
                lineManager: lineManager)
            childLanguageLayer.parentLanguageLayer = self
            childLanguageLayerStore.storeLayer(childLanguageLayer, forKey: id)
            return childLanguageLayer
        } else {
            return nil
        }
    }

    private func updateChildLayers(applying edit: TreeSitterInputEdit) -> LineChangeSet {
        guard let injectionsQuery = language.injectionsQuery, let node = tree?.rootNode else {
            childLanguageLayerStore.removeAll()
            return LineChangeSet()
        }
        let injectionsQueryCursor = TreeSitterQueryCursor(query: injectionsQuery, node: node)
        injectionsQueryCursor.execute()
        let captures = injectionsQueryCursor.validCaptures(in: stringView)
        let injectedLanguages = injectedLanguages(from: captures)
        let capturedIDs = injectedLanguages.map(\.id)
        let currentIDs = childLanguageLayerStore.allIDs
        for id in currentIDs {
            if !capturedIDs.contains(id) {
                // Remove languages that we no longer have any captures for.
                childLanguageLayerStore.removeLayer(forKey: id)
            } else if let rootNode = childLanguageLayerStore.layer(forKey: id)?.tree?.rootNode, rootNode.byteRange.length  [TreeSitterInjectedLanguage] {
        let mapper = TreeSitterInjectedLanguageMapper(captures: captures)
        mapper.delegate = self
        return mapper.map()
    }
}

// MARK: - TreeSitterInjectedLanguageMapperDelegate
extension TreeSitterLanguageLayer: TreeSitterInjectedLanguageMapperDelegate {
    func treeSitterInjectedLanguageMapper(_ mapper: TreeSitterInjectedLanguageMapper, textIn textRange: TreeSitterTextRange) -> String? {
        let byteRange = ByteRange(from: textRange.startByte, to: textRange.endByte)
        let range = NSRange(byteRange)
        return stringView.substring(in: range)
    }
}

// MARK: - Debugging Language Layers
extension TreeSitterLanguageLayer {
    func languageHierarchyStringRepresentation() -> String {
        var str = ""
        if let rootNode = tree?.rootNode {
            str += "● [\(rootNode.byteRange.lowerBound) - \(rootNode.byteRange.upperBound)]"
        } else {
            str += "●"
        }
        if !childLanguageLayerStore.isEmpty {
            str += "\n"
            str += childLanguageHierarchy(indent: 1)
        }
        return str
    }

    private func childLanguageHierarchy(indent: Int) -> String {
        var str = ""
        let languageIDs = childLanguageLayerStore.allIDs
        for (idx, languageID) in languageIDs.enumerated() {
            let indentStr = String(repeating: "  ", count: indent)
            let childLanguageLayer = childLanguageLayerStore.layer(forKey: languageID)!
            if let rootNode = childLanguageLayer.tree?.rootNode {
                str += indentStr + "\(languageID) [\(rootNode.byteRange.lowerBound) - \(rootNode.byteRange.upperBound)]"
            } else {
                str += indentStr + "\(languageID)"
            }
            if !childLanguageLayer.childLanguageLayerStore.isEmpty {
                str += "\n"
                str += childLanguageLayer.childLanguageHierarchy(indent: indent + 1)
            }
            if idx  Bool {
        // We sort the captures by three parameters:
        // 1. The location. Captures that are early in the text should be sorted first.
        // 2. The length of the capture. If two captures start at the same location, then we sort the longest capture first.
        //    Short captures that start at that location adds another "layer" of capturing on top of a previous capture.
        // 3. The number of components in the name. E.g. "variable.builtin" is sorted after "variable" as the styling of "variable.builtin"
        //    should be applied after applying the styling of "variable", since it's a specialization.
        if lhs.byteRange.location  rhs.byteRange.location {
            return false
        } else if lhs.byteRange.length > rhs.byteRange.length {
            return true
        } else if lhs.byteRange.length  Bool {
        let containsStart = point.row > startPoint.row || (point.row == startPoint.row && point.column >= startPoint.column)
        let containsEnd = point.row < endPoint.row || (point.row == endPoint.row && point.column <= endPoint.column)
        return containsStart && containsEnd
    }
}


Now let me get the TreeSitterSyntaxHighlightToken to complete the picture:

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


Now I have the complete picture. Let me also check the TreeSitterQueryCursor to see how validCaptures works:

>>>TOOL web_fetch
{"url": "https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TreeSitter/TreeSitterQueryCursor.swift", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/Runestone/main/Sources/Runestone/TreeSitter/TreeSitterQueryCursor.swift

import TreeSitter

final class TreeSitterQueryCursor {
    private let pointer: OpaquePointer
    private let query: TreeSitterQuery
    private let node: TreeSitterNode
    private var haveExecuted = false

    init(query: TreeSitterQuery, node: TreeSitterNode) {
        self.pointer = ts_query_cursor_new()
        self.query = query
        self.node = node
    }

    deinit {
        ts_query_cursor_delete(pointer)
    }

    func setQueryRange(_ range: ByteRange) {
        let start = UInt32(range.location.value)
        let end = UInt32((range.location + range.length).value)
        ts_query_cursor_set_byte_range(pointer, start, end)
    }

    func execute() {
        if !haveExecuted {
            haveExecuted = true
            ts_query_cursor_exec(pointer, query.pointer, node.rawValue)
        }
    }

    func validCaptures(in stringView: StringView) -> [TreeSitterCapture] {
        guard haveExecuted else {
            fatalError("Cannot get captures of a query that has not been executed.")
        }
        var match = TSQueryMatch(id: 0, pattern_index: 0, capture_count: 0, captures: nil)
        var result: [TreeSitterCapture] = []
        while ts_query_cursor_next_match(pointer, &match) {
            let captureCount = Int(match.capture_count)
            let captureBuffer = UnsafeBufferPointer(start: match.captures, count: captureCount)
            let captures: [TreeSitterCapture] = captureBuffer.compactMap { capture in
                let node = TreeSitterNode(node: capture.node)
                let captureName = query.captureName(forId: capture.index)
                let predicates = query.predicates(forPatternIndex: UInt32(match.pattern_index))
                return TreeSitterCapture(node: node, index: capture.index, name: captureName, predicates: predicates)
            }
            let match = TreeSitterQueryMatch(captures: captures)
            let evaluator = TreeSitterTextPredicatesEvaluator(match: match, stringView: stringView)
            result += captures.filter { capture in
                capture.byteRange.length > 0 && evaluator.evaluatePredicates(in: capture)
            }
        }
        return result
    }
}


Now I have a complete understanding of the flow. Let me write my report.

>>>REPORT
## Runestone TreeSitter Syntax Highlighting Analysis

### Source Files Analyzed (from Runestone GitHub repository):
1. `Sources/Runestone/TreeSitter/TreeSitterCapture.swift` - Capture data structure
2. `Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterSyntaxHighlighter.swift` - Main highlighter
3. `Sources/Runestone/TextView/SyntaxHighlighting/Internal/TreeSitter/TreeSitterLanguageLayer.swift` - Capture extraction
4. `Sources/Runestone/TreeSitter/TreeSitterQueryCursor.swift` - Query execution
5. Local file: `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (lines 586-702) - App's theme implementation

---

### 1. HOW CAPTURES ARE EXTRACTED FROM TREESITTER

**Flow:**
```
TreeSitterSyntaxHighlighter.syntaxHighlight()
  → languageMode.captures(in: byteRange)
    → TreeSitterLanguageLayer.captures(in: range)
      → allValidCaptures(in: range)
        → TreeSitterQueryCursor.validCaptures(in: stringView)
```

**TreeSitterQueryCursor.validCaptures()** (lines 28-45):
- Iterates through all matches via `ts_query_cursor_next_match()`
- For each match, extracts all captures with their node, index, and name
- Filters captures that have `byteRange.length > 0` and pass predicate evaluation
- Returns flat array of ALL captures (no deduplication for overlapping ranges)

---

### 2. HOW CAPTURES BECOME COLORS

**TreeSitterSyntaxHighlighter.syntaxHighlight()** (lines 32-35):
```swift
let captures = languageMode.captures(in: input.byteRange)
let tokens = self.tokens(for: captures, localTo: input.byteRange)
setAttributes(for: tokens, on: input.attributedString)
```

**Capture Sorting** (TreeSitterCapture.captureLayerSorting, lines 178-193):
```swift
// Sort order:
// 1. By location (earlier first)
// 2. By length (LONGER first - so shorter captures "layer on top")
// 3. By nameComponentCount (fewer components first, e.g. "variable" before "variable.builtin")
```

**Token Creation** (token() method, lines 122-128):
```swift
private func token(from capture: TreeSitterCapture, in byteRange: ByteRange) -> TreeSitterSyntaxHighlightToken {
    let range = NSRange(byteRange)
    let textColor = theme.textColor(for: capture.name)  // ← Theme delegate called here
    let fontTraits = theme.fontTraits(for: capture.name)
    return TreeSitterSyntaxHighlightToken(range: range, textColor: textColor, ...)
}
```

**Attribute Application** (setAttributes, lines 78-108):
```swift
for token in tokens {
    if let foregroundColor = token.textColor {
        attributes[.foregroundColor] = foregroundColor
    }
    attributedString.addAttributes(attributes, range: token.range)  // ← Later tokens OVERWRITE earlier
}
```

---

### 3. WHY OVERLAPPING CAPTURES MIGHT ALL SHOW SAME COLOR

**Runestone's Design (Correct Behavior):**
Runestone is designed to handle overlapping captures correctly:
1. Captures are sorted so LONGER (less specific) captures come FIRST
2. SHORTER/MORE-SPECIFIC captures come LATER (due to `nameComponentCount` sorting)
3. Attributes are applied in order - later tokens overwrite earlier ones
4. Result: More specific captures win (correct behavior)

**Potential Bug Location - App's Theme Implementation:**
In `RunestoneEditorView.swift` lines 586-686, the `textColor(for rawHighlightName: String)` method has problematic logic:

```swift
// Line 595-604: Handles "string.special" patterns
if highlightName.hasPrefix("string.special") || ... {
    return _variableColor
}

// Line 610-619: Then handles ALL strings including generic "string"
if highlightName.contains("string") {
    if rawHighlightName == "string" {
        return _stringColor  // Returns color even for generic "string"
    }
    return _stringColor
}
```

**THE ACTUAL ISSUE:**
The developer's comments reveal confusion about Runestone's design:
```swift
// "TreeSitter JSON emits BOTH "string.special.key" AND "string" for keys"
// "We handle specific patterns first, then skip generic "string" to avoid overwrite"
```

This is BACKWARDS thinking. Runestone handles the overwrite correctly - the app just needs to return the right color for each capture name. The app returns `_stringColor` for BOTH "string" and potentially other string-related captures, causing them to look the same.

**Root Causes for "All Same Color":**
1. **Theme returns same color for multiple capture names** - The `contains()` checks are too broad
2. **Capture names not what expected** - TreeSitter grammars vary; "string.special.key" might be "string" + "label" instead
3. **Missing early returns** - The function falls through to return the same color for related captures

---

### RECOMMENDATION

Add debugging to see actual capture names:
```swift
func textColor(for rawHighlightName: String) -> UIColor? {
    print("🎨 HIGHLIGHT: '\(rawHighlightName)'")  // Uncomment line 592
    ...
}
```

Then fix theme logic to be explicit about which capture names get which colors, using exact matches or carefully ordered prefix checks instead of broad `contains()` patterns.
>>>END
