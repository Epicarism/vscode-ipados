# Agent: treesitter-json-auditor
**Status:** done
**Tokens:** 14,798
**Cost:** $0.0000
**Time:** 2026-02-10T23:59:11.395Z

## Task
URGENT: Investigate why JSON files show ALL RED text instead of proper syntax highlighting.

1. Read VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift - find getTreeSitterLanguage() for JSON
2. Check if TreeSitterJSONRunestone is imported and used correctly
3. The highlight query should send 'string.special.key' for keys and 'string' for values
4. Check textColor(for:) - does it handle 'string.special' BEFORE 'string'?
5. Report: Why are JSON keys not being detected? What's the fix?

## Response
I'll investigate the JSON syntax highlighting issue. Let me start by reading the RunestoneEditorView.swift file.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift"}
>>>END

I can see the code. The `textColor(for:)` method at line 586-680 does check for `string.special` before `string` (lines 603-608), which is correct. But the issue might be that the TreeSitter JSON grammar emits different highlight names than expected.

Let me search for what the JSON TreeSitter package actually provides:

>>>TOOL search
{"query": "highlights.scm", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "highlights.scm"


Let me check what TreeSitter packages are being used by looking at the Package.swift or project configuration:

>>>TOOL search
{"query": "TreeSitterJSONRunestone", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitterJSONRunestone"


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


Let me check the actual Xcode project dependencies or SPM packages:

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


>>>TOOL search
{"query": "TreeSitterJSONRunestone", "glob": "*.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitterJSONRunestone"


>>>TOOL search
{"query": "TreeSitterJSON", "glob": "*.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitterJSON"


>>>TOOL search
{"query": "TreeSitter", "glob": "*.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "TreeSitter"


Let me check the debug print statement output and search for Runestone package configuration:

>>>TOOL search
{"query": "Runestone", "glob": "*.pbxproj"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "Runestone"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.xcworkspace"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.xcworkspace/
📁 xcshareddata/
📁 xcuserdata/
   contents.xcworkspacedata


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj", "start_line": 1, "end_line": 200}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj (lines 2-200 of 875)
────────────────────────────────────────
2: {
3: 	archiveVersion = 1;
4: 	classes = {
5: 	};
6: 	objectVersion = 56;
7: 	objects = {
8: 
9: /* Begin PBXBuildFile section */
10: 		1001 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2001 /* ContentView.swift */; };
11: 		1002 /* VSCodeiPadOSApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2002 /* VSCodeiPadOSApp.swift */; };
12: 		1003 /* AppCommands.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2003 /* AppCommands.swift */; };
13: 		1004 /* Color+Hex.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2004 /* Color+Hex.swift */; };
14: 		1005 /* FileManager+Extension.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2005 /* FileManager+Extension.swift */; };
15: 		1006 /* FileManager+Extensions.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2006 /* FileManager+Extensions.swift */; };
16: 		1007 /* NSAttributedStringSyntaxHighlighter.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2007 /* NSAttributedStringSyntaxHighlighter.swift */; };
17: 		1009 /* EditorState.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2009 /* EditorState.swift */; };
18: 		1012 /* FileItem.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2012 /* FileItem.swift */; };
19: 		1013 /* FileItemUTType.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2013 /* FileItemUTType.swift */; };
20: 		1015 /* FindViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2015 /* FindViewModel.swift */; };
21: 		1016 /* MultiCursor.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2016 /* MultiCursor.swift */; };
22: 		1017 /* Tab.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2017 /* Tab.swift */; };
23: 		1018 /* Theme.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2018 /* Theme.swift */; };
24: 		1019 /* AutocompleteManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2019 /* AutocompleteManager.swift */; };
25: 		1020 /* ThemeManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2020 /* ThemeManager.swift */; };
26: 		1022 /* CodeFoldingManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2022 /* CodeFoldingManager.swift */; };
27: 		1023 /* EditorCore.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2023 /* EditorCore.swift */; };
28: 		1025 /* FileSystemNavigator.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2025 /* FileSystemNavigator.swift */; };
29: 		1035 /* MinimapView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2035 /* MinimapView.swift */; };
30: 		1036 /* SyntaxHighlightingTextView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2036 /* SyntaxHighlightingTextView.swift */; };
31: 		1043 /* GitView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2043 /* GitView.swift */; };
32: 		1044 /* GoToLineView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2044 /* GoToLineView.swift */; };
33: 		1050 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2050 /* SettingsView.swift */; };
34: 		1051 /* TerminalView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2051 /* TerminalView.swift */; };
35: 		1052 /* DebugManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2052 /* DebugManager.swift */; };
36: 		1053 /* DebugView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2053 /* DebugView.swift */; };
37: 		1054 /* WorkspaceTrustManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2054 /* WorkspaceTrustManager.swift */; };
38: 		1055 /* AIManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2055 /* AIManager.swift */; };
39: 		1056 /* ColorPickerManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2056 /* ColorPickerManager.swift */; };
40: 		1057 /* GitManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2057 /* GitManager.swift */; };
41: 		1058 /* GitService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2058 /* GitService.swift */; };
42: 		1059 /* HoverInfoManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2059 /* HoverInfoManager.swift */; };
43: 		1060 /* LaunchManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2060 /* LaunchManager.swift */; };
44: 		1061 /* NavigationManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2061 /* NavigationManager.swift */; };
45: 		1062 /* RecentFileManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2062 /* RecentFileManager.swift */; };
46: 		1063 /* SearchManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2063 /* SearchManager.swift */; };
47: 		1064 /* SettingsManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2064 /* SettingsManager.swift */; };
48: 		1065 /* SnippetsManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2065 /* SnippetsManager.swift */; };
49: 		1066 /* TasksManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2066 /* TasksManager.swift */; };
50: 		1067 /* WorkspaceManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2067 /* WorkspaceManager.swift */; };
51: 		1068 /* FileIcons.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2068 /* FileIcons.swift */; };
52: 		1069 /* FileTreeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2069 /* FileTreeView.swift */; };
53: 		1070 /* SpotlightManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2070 /* SpotlightManager.swift */; };
54: 		1099 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 2099 /* Assets.xcassets */; };
55: 		1101 /* BranchMenu.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2101 /* BranchMenu.swift */; };
56: 		1102 /* CommandPalette.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2102 /* CommandPalette.swift */; };
57: 		1103 /* DiffComponents.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2103 /* DiffComponents.swift */; };
58: 		1104 /* FileIconView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2104 /* FileIconView.swift */; };
59: 		1105 /* GoToSymbol.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2105 /* GoToSymbol.swift */; };
60: 		1106 /* LaunchConfigView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2106 /* LaunchConfigView.swift */; };
61: 		1107 /* QuickOpen.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2107 /* QuickOpen.swift */; };
62: 		1108 /* SidebarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2108 /* SidebarView.swift */; };
63: 		1109 /* SnippetPickerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2109 /* SnippetPickerView.swift */; };
64: 		1110 /* StatusBarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2110 /* StatusBarView.swift */; };
65: 		1111 /* TabBarView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2111 /* TabBarView.swift */; };
66: 		1112 /* TasksView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2112 /* TasksView.swift */; };
67: 		1113 /* WorkspaceSettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2113 /* WorkspaceSettingsView.swift */; };
68: 		1114 /* WorkspaceTrustDialog.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2114 /* WorkspaceTrustDialog.swift */; };
69: 		1115 /* OutputView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2115 /* OutputView.swift */; };
70: 		1116 /* SearchView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2116 /* SearchView.swift */; };
71: 		1117 /* MarkdownPreviewView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2117 /* MarkdownPreviewView.swift */; };
72: 		1118 /* AIAssistantView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2118 /* AIAssistantView.swift */; };
73: 		1119 /* GitQuickActionsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2119 /* GitQuickActionsView.swift */; };
74: 		1120 /* MarkdownPreviewWrapper.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2120 /* MarkdownPreviewWrapper.swift */; };
75: 		1121 /* TestView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2121 /* TestView.swift */; };
76: 		1122 /* PanelView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2122 /* PanelView.swift */; };
77: 		1123 /* ProblemsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2123 /* ProblemsView.swift */; };
78: 		1124 /* OutlineView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2124 /* OutlineView.swift */; };
79: 		1125 /* TimelineView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2125 /* TimelineView.swift */; };
80: 		1126 /* DebugConsoleView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2126 /* DebugConsoleView.swift */; };
81: 		1127 /* SplitEditorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2127 /* SplitEditorView.swift */; };
82: 		1128 /* StickyHeaderView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2128 /* StickyHeaderView.swift */; };
83: 		1129 /* ColorPickerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2129 /* ColorPickerView.swift */; };
84: 		1130 /* MultiCursorTextView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2130 /* MultiCursorTextView.swift */; };
85: 		1131 /* JSONTreeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2131 /* JSONTreeView.swift */; };
86: 		1132 /* EditorSplitView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2132 /* EditorSplitView.swift */; };
87: 		1133 /* InlayHintsOverlay.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2133 /* InlayHintsOverlay.swift */; };
88: 		1135 /* HoverInfoView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2135 /* HoverInfoView.swift */; };
89: 		1136 /* BreadcrumbsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2136 /* BreadcrumbsView.swift */; };
90: 		1138 /* PeekDefinitionView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2138 /* PeekDefinitionView.swift */; };
91: 		1139 /* InlayHintsManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2139 /* InlayHintsManager.swift */; };
92: 		1140 /* FileHelpers.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2140 /* FileHelpers.swift */; };
93: 		1141 /* Notification+Search.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2141 /* Notification+Search.swift */; };
94: 		1142 /* SSHManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2142 /* SSHManager.swift */; };
95: 		1143 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2143 /* AppDelegate.swift */; };
96: 		1144 /* SceneDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2144 /* SceneDelegate.swift */; };
97: 		1145 /* NativeGitReader.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2145 /* NativeGitReader.swift */; };
98: 		1146 /* NativeGitWriter.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2146 /* NativeGitWriter.swift */; };
99: 		1147 /* RunestoneEditorView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2147 /* RunestoneEditorView.swift */; };
100: 		1148 /* RunestoneThemeAdapter.swift in Sources */ = {isa = PBXBuildFile; fileRef = 2148 /* RunestoneThemeAdapter.swift */; };
101: 		1149 /* TreeSitterLanguages.swift in Sources */ = {isa = PBXBuildFile; fileRef = 896596662F3B9FAB005B984D /* TreeSitterLanguages.swift */; };
102: 		896596672F3B9FAC005B984D /* FeatureFlags.swift in Sources */ = {isa = PBXBuildFile; fileRef = 896596632F3B9FAB005B984D /* FeatureFlags.swift */; };
103: /* End PBXBuildFile section */
104: 
105: /* Begin PBXFileReference section */
106: 		2001 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
107: 		2002 /* VSCodeiPadOSApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = VSCodeiPadOSApp.swift; sourceTree = "<group>"; };
108: 		2003 /* AppCommands.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppCommands.swift; sourceTree = "<group>"; };
109: 		2004 /* Color+Hex.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "Color+Hex.swift"; sourceTree = "<group>"; };
110: 		2005 /* FileManager+Extension.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "FileManager+Extension.swift"; sourceTree = "<group>"; };
111: 		2006 /* FileManager+Extensions.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "FileManager+Extensions.swift"; sourceTree = "<group>"; };
112: 		2007 /* NSAttributedStringSyntaxHighlighter.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NSAttributedStringSyntaxHighlighter.swift; sourceTree = "<group>"; };
113: 		2009 /* EditorState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EditorState.swift; sourceTree = "<group>"; };
114: 		2012 /* FileItem.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileItem.swift; sourceTree = "<group>"; };
115: 		2013 /* FileItemUTType.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileItemUTType.swift; sourceTree = "<group>"; };
116: 		2015 /* FindViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FindViewModel.swift; sourceTree = "<group>"; };
117: 		2016 /* MultiCursor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MultiCursor.swift; sourceTree = "<group>"; };
118: 		2017 /* Tab.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Tab.swift; sourceTree = "<group>"; };
119: 		2018 /* Theme.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Theme.swift; sourceTree = "<group>"; };
120: 		2019 /* AutocompleteManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AutocompleteManager.swift; sourceTree = "<group>"; };
121: 		2020 /* ThemeManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ThemeManager.swift; sourceTree = "<group>"; };
122: 		2022 /* CodeFoldingManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CodeFoldingManager.swift; sourceTree = "<group>"; };
123: 		2023 /* EditorCore.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EditorCore.swift; sourceTree = "<group>"; };
124: 		2025 /* FileSystemNavigator.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileSystemNavigator.swift; sourceTree = "<group>"; };
125: 		2035 /* MinimapView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MinimapView.swift; sourceTree = "<group>"; };
126: 		2036 /* SyntaxHighlightingTextView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SyntaxHighlightingTextView.swift; sourceTree = "<group>"; };
127: 		2043 /* GitView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GitView.swift; sourceTree = "<group>"; };
128: 		2044 /* GoToLineView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GoToLineView.swift; sourceTree = "<group>"; };
129: 		2050 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
130: 		2051 /* TerminalView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TerminalView.swift; sourceTree = "<group>"; };
131: 		2052 /* DebugManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DebugManager.swift; sourceTree = "<group>"; };
132: 		2053 /* DebugView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DebugView.swift; sourceTree = "<group>"; };
133: 		2054 /* WorkspaceTrustManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WorkspaceTrustManager.swift; sourceTree = "<group>"; };
134: 		2055 /* AIManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIManager.swift; sourceTree = "<group>"; };
135: 		2056 /* ColorPickerManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ColorPickerManager.swift; sourceTree = "<group>"; };
136: 		2057 /* GitManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GitManager.swift; sourceTree = "<group>"; };
137: 		2058 /* GitService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GitService.swift; sourceTree = "<group>"; };
138: 		2059 /* HoverInfoManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HoverInfoManager.swift; sourceTree = "<group>"; };
139: 		2060 /* LaunchManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LaunchManager.swift; sourceTree = "<group>"; };
140: 		2061 /* NavigationManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NavigationManager.swift; sourceTree = "<group>"; };
141: 		2062 /* RecentFileManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RecentFileManager.swift; sourceTree = "<group>"; };
142: 		2063 /* SearchManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchManager.swift; sourceTree = "<group>"; };
143: 		2064 /* SettingsManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsManager.swift; sourceTree = "<group>"; };
144: 		2065 /* SnippetsManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SnippetsManager.swift; sourceTree = "<group>"; };
145: 		2066 /* TasksManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TasksManager.swift; sourceTree = "<group>"; };
146: 		2067 /* WorkspaceManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WorkspaceManager.swift; sourceTree = "<group>"; };
147: 		2068 /* FileIcons.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileIcons.swift; sourceTree = "<group>"; };
148: 		2069 /* FileTreeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileTreeView.swift; sourceTree = "<group>"; };
149: 		2070 /* SpotlightManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpotlightManager.swift; sourceTree = "<group>"; };
150: 		2099 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
151: 		2101 /* BranchMenu.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BranchMenu.swift; sourceTree = "<group>"; };
152: 		2102 /* CommandPalette.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CommandPalette.swift; sourceTree = "<group>"; };
153: 		2103 /* DiffComponents.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DiffComponents.swift; sourceTree = "<group>"; };
154: 		2104 /* FileIconView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileIconView.swift; sourceTree = "<group>"; };
155: 		2105 /* GoToSymbol.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GoToSymbol.swift; sourceTree = "<group>"; };
156: 		2106 /* LaunchConfigView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LaunchConfigView.swift; sourceTree = "<group>"; };
157: 		2107 /* QuickOpen.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = QuickOpen.swift; sourceTree = "<group>"; };
158: 		2108 /* SidebarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SidebarView.swift; sourceTree = "<group>"; };
159: 		2109 /* SnippetPickerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SnippetPickerView.swift; sourceTree = "<group>"; };
160: 		2110 /* StatusBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StatusBarView.swift; sourceTree = "<group>"; };
161: 		2111 /* TabBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TabBarView.swift; sourceTree = "<group>"; };
162: 		2112 /* TasksView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TasksView.swift; sourceTree = "<group>"; };
163: 		2113 /* WorkspaceSettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WorkspaceSettingsView.swift; sourceTree = "<group>"; };
164: 		2114 /* WorkspaceTrustDialog.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WorkspaceTrustDialog.swift; sourceTree = "<group>"; };
165: 		2115 /* OutputView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OutputView.swift; sourceTree = "<group>"; };
166: 		2116 /* SearchView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SearchView.swift; sourceTree = "<group>"; };
167: 		2117 /* MarkdownPreviewView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MarkdownPreviewView.swift; sourceTree = "<group>"; };
168: 		2118 /* AIAssistantView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIAssistantView.swift; sourceTree = "<group>"; };
169: 		2119 /* GitQuickActionsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GitQuickActionsView.swift; sourceTree = "<group>"; };
170: 		2120 /* MarkdownPreviewWrapper.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MarkdownPreviewWrapper.swift; sourceTree = "<group>"; };
171: 		2121 /* TestView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TestView.swift; sourceTree = "<group>"; };
172: 		2122 /* PanelView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PanelView.swift; sourceTree = "<group>"; };
173: 		2123 /* ProblemsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProblemsView.swift; sourceTree = "<group>"; };
174: 		2124 /* OutlineView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OutlineView.swift; sourceTree = "<group>"; };
175: 		2125 /* TimelineView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TimelineView.swift; sourceTree = "<group>"; };
176: 		2126 /* DebugConsoleView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DebugConsoleView.swift; sourceTree = "<group>"; };
177: 		2127 /* SplitEditorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SplitEditorView.swift; sourceTree = "<group>"; };
178: 		2128 /* StickyHeaderView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StickyHeaderView.swift; sourceTree = "<group>"; };
179: 		2129 /* ColorPickerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ColorPickerView.swift; sourceTree = "<group>"; };
180: 		2130 /* MultiCursorTextView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MultiCursorTextView.swift; sourceTree = "<group>"; };
181: 		2131 /* JSONTreeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = JSONTreeView.swift; sourceTree = "<group>"; };
182: 		2132 /* EditorSplitView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EditorSplitView.swift; sourceTree = "<group>"; };
183: 		2133 /* InlayHintsOverlay.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = InlayHintsOverlay.swift; sourceTree = "<group>"; };
184: 		2135 /* HoverInfoView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HoverInfoView.swift; sourceTree = "<group>"; };
185: 		2136 /* BreadcrumbsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BreadcrumbsView.swift; sourceTree = "<group>"; };
186: 		2138 /* PeekDefinitionView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PeekDefinitionView.swift; sourceTree = "<group>"; };
187: 		2139 /* InlayHintsManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = InlayHintsManager.swift; sourceTree = "<group>"; };
188: 		2140 /* FileHelpers.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileHelpers.swift; sourceTree = "<group>"; };
189: 		2141 /* Notification+Search.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "Notification+Search.swift"; sourceTree = "<group>"; };
190: 		2142 /* SSHManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SSHManager.swift; sourceTree = "<group>"; };
191: 		2143 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
192: 		2144 /* SceneDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneDelegate.swift; sourceTree = "<group>"; };
193: 		2145 /* NativeGitReader.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NativeGitReader.swift; sourceTree = "<group>"; };
194: 		2146 /* NativeGitWriter.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NativeGitWriter.swift; sourceTree = "<group>"; };
195: 		2147 /* RunestoneEditorView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RunestoneEditorView.swift; sourceTree = "<group>"; };
196: 		2148 /* RunestoneThemeAdapter.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RunestoneThemeAdapter.swift; sourceTree = "<group>"; };
197: 		3000 /* VSCodeiPadOS.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = VSCodeiPadOS.app; sourceTree = BUILT_PRODUCTS_DIR; };
198: 		896596632F3B9FAB005B984D /* FeatureFlags.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FeatureFlags.swift; sourceTree = "<group>"; };
199: 		896596662F3B9FAB005B984D /* TreeSitterLanguages.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TreeSitterLanguages.swift; sourceTree = "<group>"; };
200: /* End PBXFileReference section */


Let me search for package dependencies in the project:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj", "start_line": 700, "end_line": 875}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj (lines 701-875 of 875)
────────────────────────────────────────
701: 				ENABLE_STRICT_OBJC_MSGSEND = YES;
702: 				ENABLE_TESTABILITY = YES;
703: 				GCC_C_LANGUAGE_STANDARD = gnu11;
704: 				GCC_DYNAMIC_NO_PIC = NO;
705: 				GCC_NO_COMMON_BLOCKS = YES;
706: 				GCC_OPTIMIZATION_LEVEL = 0;
707: 				GCC_PREPROCESSOR_DEFINITIONS = (
708: 					"DEBUG=1",
709: 					"$(inherited)",
710: 				);
711: 				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
712: 				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
713: 				GCC_WARN_UNDECLARED_SELECTOR = YES;
714: 				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
715: 				GCC_WARN_UNUSED_FUNCTION = YES;
716: 				GCC_WARN_UNUSED_VARIABLE = YES;
717: 				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
718: 				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
719: 				MTL_FAST_MATH = YES;
720: 				ONLY_ACTIVE_ARCH = YES;
721: 				SDKROOT = iphoneos;
722: 				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
723: 				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
724: 			};
725: 			name = Debug;
726: 		};
727: 		8002 /* Release */ = {
728: 			isa = XCBuildConfiguration;
729: 			buildSettings = {
730: 				ALWAYS_SEARCH_USER_PATHS = NO;
731: 				ASYNCK_AWAIT_ENABLED = YES;
732: 				CLANG_ANALYZER_NONNULL = YES;
733: 				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
734: 				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
735: 				CLANG_ENABLE_MODULES = YES;
736: 				CLANG_ENABLE_OBJC_ARC = YES;
737: 				CLANG_ENABLE_OBJC_WEAK = YES;
738: 				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
739: 				CLANG_WARN_BOOL_CONVERSION = YES;
740: 				CLANG_WARN_COMMA = YES;
741: 				CLANG_WARN_CONSTANT_CONVERSION = YES;
742: 				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
743: 				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
744: 				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
745: 				CLANG_WARN_EMPTY_BODY = YES;
746: 				CLANG_WARN_ENUM_CONVERSION = YES;
747: 				CLANG_WARN_INFINITE_RECURSION = YES;
748: 				CLANG_WARN_INT_CONVERSION = YES;
749: 				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
750: 				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
751: 				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
752: 				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
753: 				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
754: 				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
755: 				CLANG_WARN_STRICT_PROTOTYPES = YES;
756: 				CLANG_WARN_SUSPICIOUS_MOVE = YES;
757: 				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
758: 				CLANG_WARN_UNREACHABLE_CODE = YES;
759: 				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
760: 				COPY_PHASE_STRIP = NO;
761: 				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
762: 				ENABLE_NS_ASSERTIONS = NO;
763: 				ENABLE_STRICT_OBJC_MSGSEND = YES;
764: 				GCC_C_LANGUAGE_STANDARD = gnu11;
765: 				GCC_NO_COMMON_BLOCKS = YES;
766: 				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
767: 				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
768: 				GCC_WARN_UNDECLARED_SELECTOR = YES;
769: 				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
770: 				GCC_WARN_UNUSED_FUNCTION = YES;
771: 				GCC_WARN_UNUSED_VARIABLE = YES;
772: 				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
773: 				MTL_ENABLE_DEBUG_INFO = NO;
774: 				MTL_FAST_MATH = YES;
775: 				SDKROOT = iphoneos;
776: 				SWIFT_COMPILATION_MODE = wholemodule;
777: 				SWIFT_OPTIMIZATION_LEVEL = "-O";
778: 				VALIDATE_PRODUCT = YES;
779: 			};
780: 			name = Release;
781: 		};
782: /* End XCBuildConfiguration section */
783: 
784: /* Begin XCConfigurationList section */
785: 		6000 /* Build configuration list for PBXNativeTarget "VSCodeiPadOS" */ = {
786: 			isa = XCConfigurationList;
787: 			buildConfigurations = (
788: 				6001 /* Debug */,
789: 				6002 /* Release */,
790: 			);
791: 			defaultConfigurationIsVisible = 0;
792: 			defaultConfigurationName = Release;
793: 		};
794: 		8000 /* Build configuration list for PBXProject "VSCodeiPadOS" */ = {
795: 			isa = XCConfigurationList;
796: 			buildConfigurations = (
797: 				8001 /* Debug */,
798: 				8002 /* Release */,
799: 			);
800: 			defaultConfigurationIsVisible = 0;
801: 			defaultConfigurationName = Release;
802: 		};
803: /* End XCConfigurationList section */
804: 
805: /* Begin XCRemoteSwiftPackageReference section */
806: 		896595ED2F3B8D73005B984D /* XCRemoteSwiftPackageReference "Runestone" */ = {
807: 			isa = XCRemoteSwiftPackageReference;
808: 			repositoryURL = "https://github.com/simonbs/Runestone.git";
809: 			requirement = {
810: 				kind = upToNextMajorVersion;
811: 				minimumVersion = 0.5.1;
812: 			};
813: 		};
814: 		896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */ = {
815: 			isa = XCRemoteSwiftPackageReference;
816: 			repositoryURL = "https://github.com/simonbs/TreeSitterLanguages.git";
817: 			requirement = {
818: 				kind = upToNextMajorVersion;
819: 				minimumVersion = 0.1.10;
820: 			};
821: 		};
822: /* End XCRemoteSwiftPackageReference section */
823: 
824: /* Begin XCSwiftPackageProductDependency section */
825: 		896595EE2F3B8D73005B984D /* Runestone */ = {
826: 			isa = XCSwiftPackageProductDependency;
827: 			package = 896595ED2F3B8D73005B984D /* XCRemoteSwiftPackageReference "Runestone" */;
828: 			productName = Runestone;
829: 		};
830: 		896596682F3B9FB0005B984D /* TreeSitterSwiftRunestone */ = {
831: 			isa = XCSwiftPackageProductDependency;
832: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
833: 			productName = TreeSitterSwiftRunestone;
834: 		};
835: 		896596692F3B9FB1005B984D /* TreeSitterJavaScriptRunestone */ = {
836: 			isa = XCSwiftPackageProductDependency;
837: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
838: 			productName = TreeSitterJavaScriptRunestone;
839: 		};
840: 		8965966A2F3B9FB2005B984D /* TreeSitterPythonRunestone */ = {
841: 			isa = XCSwiftPackageProductDependency;
842: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
843: 			productName = TreeSitterPythonRunestone;
844: 		};
845: 		8965966B2F3B9FB3005B984D /* TreeSitterJSONRunestone */ = {
846: 			isa = XCSwiftPackageProductDependency;
847: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
848: 			productName = TreeSitterJSONRunestone;
849: 		};
850: 		8965966C2F3B9FB4005B984D /* TreeSitterHTMLRunestone */ = {
851: 			isa = XCSwiftPackageProductDependency;
852: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
853: 			productName = TreeSitterHTMLRunestone;
854: 		};
855: 		8965966D2F3B9FB5005B984D /* TreeSitterCSSRunestone */ = {
856: 			isa = XCSwiftPackageProductDependency;
857: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
858: 			productName = TreeSitterCSSRunestone;
859: 		};
860: 		8965966E2F3B9FB6005B984D /* TreeSitterGoRunestone */ = {
861: 			isa = XCSwiftPackageProductDependency;
862: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
863: 			productName = TreeSitterGoRunestone;
864: 		};
865: 		8965966F2F3B9FB7005B984D /* TreeSitterRustRunestone */ = {
866: 			isa = XCSwiftPackageProductDependency;
867: 			package = 896595EF2F3B8F37005B984D /* XCRemoteSwiftPackageReference "TreeSitterLanguages" */;
868: 			productName = TreeSitterRustRunestone;
869: 		};
870: 
871: /* End XCSwiftPackageProductDependency section */
872: 	};
873: 	rootObject = 7000 /* Project object */;
874: }
875: 


I found the package configuration. The TreeSitterJSONRunestone is properly included. The issue is likely the highlight names the JSON grammar emits. Let me search the web to find out what highlight names the simonbs/TreeSitterLanguages JSON grammar uses:

>>>TOOL web_search
{"query": "simonbs TreeSitterLanguages JSON highlights.scm highlight names"}
>>>END

---

## 🔧 TOOL RESULTS

[web_search]
🔍 DuckDuckGo results for "simonbs TreeSitterLanguages JSON highlights.scm highlight names" (10 results):

1. **Syntax Highlighting - Tree-sitter**
   https://tree-sitter.github.io/tree-sitter/3-syntax-highlighting.html
   These keys specify relative paths from the directory containing tree-sitter.json to the files that control syntax highlighting: highlights — Path to a highlight query. Default: queries/highlights.scm locals — Path to a local variable query. Default: queries/locals.scm. injections — Path to an injection query. Default: queries/injections.scm.

2. **Official list of highlight capture names · tree-sitter tree-sitter ...**
   https://github.com/tree-sitter/tree-sitter/discussions/2025
   I see in tree-sitter/config.json there&#x27;s a list of some highlight capture names, and also I can find many examples of queries/highlight.scm files to take the names from.

3. **Syntax highlight anything with Tree-sitter - Programming for fun and profit**
   https://slar.se/syntax-highlight-anything-with-tree-sitter.html
   This means your project was correctly located. We now need to define queries for our highlight. Queries allow us to select nodes in the syntax tree and assign pre-defined semantic meaning to them. Put the following content in the file queries/highlights.scm in your project directory.

4. **Modern Tree-sitter, part 3: syntax highlighting via queries**
   https://blog.pulsar-edit.dev/posts/20231013-savetheclocktower-modern-tree-sitter-part-3/
   It&#x27;ll parse the input, figure out which parser should do the job, use that parser&#x27;s highlights.scm to map certain nodes to query capture names, and then emit highlighted output in your terminal. Last time I showed you this excerpt from tree-sitter-javascript &#x27;s highlights.scm file:

5. **Tree-sitter Syntax Highlighting. Syntax highlighting plays a crucial ...**
   https://medium.com/@linz07m/understanding-tree-sitter-syntax-highlighting-c44d40b9e1e0
   Tree-sitter offers a structured and extensible approach to syntax highlighting through its tree-sitter-highlight system, which is widely used, including on platforms like GitHub.

6. **Highlighting source code with tree-sitter - Jeff Kreeftmeijer**
   https://jeffkreeftmeijer.com/tree-sitter-highlight/
   In this case, the current directory has a local of the tree-sitter Ruby grammar. Tree-sitter searches each parser directory for sub directories with names starting with tree-sitter- 1.

7. **Syntax Highlighting and Queries | nix-community/tree-sitter-nix | DeepWiki**
   https://deepwiki.com/nix-community/tree-sitter-nix/5.2-syntax-highlighting-and-queries
   Sources: queries/highlights.scm 1-100 queries/tags.scm 1-17 tree-sitter.json 1-40 Syntax Highlighting System The highlights.scm file contains query patterns that classify AST nodes into standardized highlight groups. Each pattern uses S-expression syntax to match specific node types and assign highlight captures.

8. **Syntax Highlighting and Queries | tree-sitter/tree-sitter-go | DeepWiki**
   https://deepwiki.com/tree-sitter/tree-sitter-go/7-syntax-highlighting-and-queries
   The workflow for syntax highlighting: Tree-sitter parses Go source code into a syntax tree The query engine loads and applies patterns from highlights.scm Matches are converted to scoped tokens (e.g., function, keyword) The editor maps these scopes to colors/styles according to its theme The code is displayed with appropriate highlighting Sources: tree-sitter.json 11 queries/highlights.scm ...

9. **Adding a Tree-sitter Language - Documentation**
   https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/
   The key files are covered previously in this article but they include src/parser.c, src/tree_sitter/parser.h and queries/highlights.scm. A Tree-sitter parser is exposed as a C function with the name tree_sitter_{language}, like tree_sitter_json or tree_sitter_javascript. You will need to add the C definition for this function to your project.

10. **tree-sitter/docs/src/3-syntax-highlighting.md at master - GitHub**
   https://github.com/tree-sitter/tree-sitter/blob/master/docs/src/3-syntax-highlighting.md
   These keys specify relative paths from the directory containing tree-sitter.json to the files that control syntax highlighting: highlights — Path to a highlight query. Default: queries/highlights.scm locals — Path to a local variable query. Default: queries/locals.scm. injections — Path to an injection query. Default: queries/injections.scm.


>>>TOOL web_fetch
{"url": "https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/TreeSitterLanguages/b...n/Sources/TreeSitterJSONRunes
tone/highlights.scm  | ✓ | ⏱: 1.28s 
[SCRAPE].. ◆ 
https://github.com/simonbs/TreeSitterLanguages/b...n/Sources/TreeSitterJSONRunes
tone/highlights.scm  | ✓ | ⏱: 0.03s 
[COMPLETE] ● 
https://github.com/simonbs/TreeSitterLanguages/b...n/Sources/TreeSitterJSONRunes
tone/highlights.scm  | ✓ | ⏱: 1.31s 
[Skip to content](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Fblob%2Fmain%2FSources%2FTreeSitterJSONRunestone%2Fhighlights.scm)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Fblob%2Fmain%2FSources%2FTreeSitterJSONRunestone%2Fhighlights.scm)
####  Sign in to GitHub 
Username or email address 
Password  [Forgot password?](https://github.com/password_reset)
[ or continue with other methods ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Fblob%2Fmain%2FSources%2FTreeSitterJSONRunestone%2Fhighlights.scm)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Fblob%2Fshow&source=header-repo&source_repo=simonbs%2FTreeSitterLanguages)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/highlights.scm) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages) ** Public
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages) You must be signed in to change notification settings
  * [ 27 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)
  * [ Star  67 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)


  * [ Code ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests 3 ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security 0 ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights ](https://github.com/simonbs/TreeSitterLanguages/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests  ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions  ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security  ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights  ](https://github.com/simonbs/TreeSitterLanguages/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Sources
  * .gitignore
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md


## Breadcrumbs
  1. [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages/tree/main)
  2. /[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)
  3. /[TreeSitterJSONRunestone](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone)


/
# highlights.scm
/
Copy path
404 - page not found
The 
main
branch of 
TreeSitterLanguages
does not contain the path 
Sources/TreeSitterJSONRunestone/highlights.scm.
[Return to the repository overview](https://github.com/simonbs/TreeSitterLanguages)
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
{"url": "https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONR
unestone             | ✓ | ⏱: 1.30s 
[SCRAPE].. ◆ 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONR
unestone             | ✓ | ⏱: 0.06s 
[COMPLETE] ● 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONR
unestone             | ✓ | ⏱: 1.36s 
[Skip to content](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Ftree%2Fmain%2FSources%2FTreeSitterJSONRunestone)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Ftree%2Fmain%2FSources%2FTreeSitterJSONRunestone)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FTreeSitterLanguages)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONRunestone) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages) ** Public
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages) You must be signed in to change notification settings
  * [ 27 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)
  * [ Star  67 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)


  * [ Code ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests 3 ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security 0 ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights ](https://github.com/simonbs/TreeSitterLanguages/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests  ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions  ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security  ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights  ](https://github.com/simonbs/TreeSitterLanguages/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Sources
    * TreeSitterAstro
    * TreeSitterAstroQueries
    * TreeSitterAstroRunestone
    * TreeSitterBash
    * TreeSitterBashQueries
    * TreeSitterBashRunestone
    * TreeSitterC
    * TreeSitterCPP
    * TreeSitterCPPQueries
    * TreeSitterCPPRunestone
    * TreeSitterCQueries
    * TreeSitterCRunestone
    * TreeSitterCSS
    * TreeSitterCSSQueries
    * TreeSitterCSSRunestone
    * TreeSitterCSharp
    * TreeSitterCSharpQueries
    * TreeSitterCSharpRunestone
    * TreeSitterComment
    * TreeSitterCommentQueries
    * TreeSitterCommentRunestone
    * TreeSitterElixir
    * TreeSitterElixirQueries
    * TreeSitterElixirRunestone
    * TreeSitterElm
    * TreeSitterElmQueries
    * TreeSitterElmRunestone
    * TreeSitterGo
    * TreeSitterGoQueries
    * TreeSitterGoRunestone
    * TreeSitterHTML
    * TreeSitterHTMLQueries
    * TreeSitterHTMLRunestone
    * TreeSitterHaskell
    * TreeSitterHaskellQueries
    * TreeSitterHaskellRunestone
    * TreeSitterJSDoc
    * TreeSitterJSDocQueries
    * TreeSitterJSDocRunestone
    * TreeSitterJSON
    * TreeSitterJSON5
    * TreeSitterJSON5Queries
    * TreeSitterJSON5Runestone
    * TreeSitterJSONQueries
    * TreeSitterJSONRunestone
      * TreeSitterIndentationScopes+Helpers.swift
      * TreeSitterLanguage+Helpers.swift
    * TreeSitterJava
    * TreeSitterJavaQueries
    * TreeSitterJavaRunestone
    * TreeSitterJavaScript
    * TreeSitterJavaScriptQueries
    * TreeSitterJavaScriptRunestone
    * TreeSitterJulia
    * TreeSitterJuliaQueries
    * TreeSitterJuliaRunestone
    * TreeSitterLaTeX
    * TreeSitterLaTeXQueries
    * TreeSitterLaTeXRunestone
    * TreeSitterLanguagesCommon
    * TreeSitterLua
    * TreeSitterLuaQueries
    * TreeSitterLuaRunestone
    * TreeSitterMarkdown
    * TreeSitterMarkdownInline
    * TreeSitterMarkdownInlineQueries
    * TreeSitterMarkdownInlineRunestone
    * TreeSitterMarkdownQueries
    * TreeSitterMarkdownRunestone
    * TreeSitterOCaml
    * TreeSitterOCamlQueries
    * TreeSitterOCamlRunestone
    * TreeSitterPHP
    * TreeSitterPHPQueries
    * TreeSitterPHPRunestone
    * TreeSitterPerl
    * TreeSitterPerlQueries
    * TreeSitterPerlRunestone
    * TreeSitterPython
    * TreeSitterPythonQueries
    * TreeSitterPythonRunestone
    * TreeSitterR
    * TreeSitterRQueries
    * TreeSitterRRunestone
    * TreeSitterRegex
    * TreeSitterRegexQueries
    * TreeSitterRegexRunestone
    * TreeSitterRuby
    * TreeSitterRubyQueries
    * TreeSitterRubyRunestone
    * TreeSitterRust
    * TreeSitterRustQueries
    * TreeSitterRustRunestone
    * TreeSitterSCSS
    * TreeSitterSCSSQueries
    * TreeSitterSCSSRunestone
    * TreeSitterSQL
    * TreeSitterSQLQueries
    * TreeSitterSQLRunestone
    * TreeSitterSvelte
    * TreeSitterSvelteQueries
    * TreeSitterSvelteRunestone
    * TreeSitterSwift
    * TreeSitterSwiftQueries
    * TreeSitterSwiftRunestone
    * TreeSitterTOML
    * TreeSitterTOMLQueries
    * TreeSitterTOMLRunestone
    * TreeSitterTSX
    * TreeSitterTSXQueries
    * TreeSitterTSXRunestone
    * TreeSitterTypeScript
    * TreeSitterTypeScriptQueries
    * TreeSitterTypeScriptRunestone
    * TreeSitterYAML
    * TreeSitterYAMLQueries
    * TreeSitterYAMLRunestone
  * .gitignore
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md


## Breadcrumbs
  1. [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages/tree/main)
  2. /[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)


/
# TreeSitterJSONRunestone
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
[History](https://github.com/simonbs/TreeSitterLanguages/commits/main/Sources/TreeSitterJSONRunestone)
[](https://github.com/simonbs/TreeSitterLanguages/commits/main/Sources/TreeSitterJSONRunestone)History
## Breadcrumbs
  1. [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages/tree/main)
  2. /[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)


/
# TreeSitterJSONRunestone
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)  
[TreeSitterIndentationScopes+Helpers.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/TreeSitterIndentationScopes%2BHelpers.swift "TreeSitterIndentationScopes+Helpers.swift") | [TreeSitterIndentationScopes+Helpers.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/TreeSitterIndentationScopes%2BHelpers.swift "TreeSitterIndentationScopes+Helpers.swift") | [Adds Runestone frameworks](https://github.com/simonbs/TreeSitterLanguages/commit/2509764e3bd2debdb04204f8d8f537ef4ece4d5b "Adds Runestone frameworks") | Jan 22, 2022  
[TreeSitterLanguage+Helpers.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/TreeSitterLanguage%2BHelpers.swift "TreeSitterLanguage+Helpers.swift") | [TreeSitterLanguage+Helpers.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONRunestone/TreeSitterLanguage%2BHelpers.swift "TreeSitterLanguage+Helpers.swift") | [Revert "Updates Runestone"](https://github.com/simonbs/TreeSitterLanguages/commit/7d90bba8c1c70f0527a9fd0c822961b9bd020262 "Revert "Updates Runestone"

This reverts commit 5d4221b1d3f4abe3b07a8cf7d2c172bb020b761e.") | Feb 19, 2022  
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


I see! The TreeSitterJSONRunestone folder only contains helper Swift files, not the highlights.scm. The query files are in a separate module called `TreeSitterJSONQueries`. Let me check that:

>>>TOOL web_fetch
{"url": "https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries", "use_crawl4ai": true}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🕷️ Crawl4AI: https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries

[INIT].... → Crawl4AI 0.8.0 
[FETCH]... ↓ 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQ
ueries               | ✓ | ⏱: 1.28s 
[SCRAPE].. ◆ 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQ
ueries               | ✓ | ⏱: 0.06s 
[COMPLETE] ● 
https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQ
ueries               | ✓ | ⏱: 1.34s 
[Skip to content](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries#start-of-content)
## Navigation Menu
Toggle navigation
[ ](https://github.com/)
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Ftree%2Fmain%2FSources%2FTreeSitterJSONQueries)
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
[ Sign in ](https://github.com/login?return_to=https%3A%2F%2Fgithub.com%2Fsimonbs%2FTreeSitterLanguages%2Ftree%2Fmain%2FSources%2FTreeSitterJSONQueries)
[ Sign up ](https://github.com/signup?ref_cta=Sign+up&ref_loc=header+logged+out&ref_page=%2F%3Cuser-name%3E%2F%3Crepo-name%3E%2Ffiles%2Fdisambiguate&source=header-repo&source_repo=simonbs%2FTreeSitterLanguages)
Appearance settings
Resetting focus
You signed in with another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries) to refresh your session. You signed out in another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries) to refresh your session. You switched accounts on another tab or window. [Reload](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources/TreeSitterJSONQueries) to refresh your session. Dismiss alert
{{ message }}
[ simonbs ](https://github.com/simonbs) / **[TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages) ** Public
  * [ ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages) You must be signed in to change notification settings
  * [ 27 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)
  * [ Star  67 ](https://github.com/login?return_to=%2Fsimonbs%2FTreeSitterLanguages)


  * [ Code ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests 3 ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security 0 ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights ](https://github.com/simonbs/TreeSitterLanguages/pulse)


Additional navigation options
  * [ Code  ](https://github.com/simonbs/TreeSitterLanguages)
  * [ Pull requests  ](https://github.com/simonbs/TreeSitterLanguages/pulls)
  * [ Actions  ](https://github.com/simonbs/TreeSitterLanguages/actions)
  * [ Security  ](https://github.com/simonbs/TreeSitterLanguages/security)
  * [ Insights  ](https://github.com/simonbs/TreeSitterLanguages/pulse)


## Collapse file tree
## Files
main
Search this repository
  * .github
  * Sources
    * TreeSitterAstro
    * TreeSitterAstroQueries
    * TreeSitterAstroRunestone
    * TreeSitterBash
    * TreeSitterBashQueries
    * TreeSitterBashRunestone
    * TreeSitterC
    * TreeSitterCPP
    * TreeSitterCPPQueries
    * TreeSitterCPPRunestone
    * TreeSitterCQueries
    * TreeSitterCRunestone
    * TreeSitterCSS
    * TreeSitterCSSQueries
    * TreeSitterCSSRunestone
    * TreeSitterCSharp
    * TreeSitterCSharpQueries
    * TreeSitterCSharpRunestone
    * TreeSitterComment
    * TreeSitterCommentQueries
    * TreeSitterCommentRunestone
    * TreeSitterElixir
    * TreeSitterElixirQueries
    * TreeSitterElixirRunestone
    * TreeSitterElm
    * TreeSitterElmQueries
    * TreeSitterElmRunestone
    * TreeSitterGo
    * TreeSitterGoQueries
    * TreeSitterGoRunestone
    * TreeSitterHTML
    * TreeSitterHTMLQueries
    * TreeSitterHTMLRunestone
    * TreeSitterHaskell
    * TreeSitterHaskellQueries
    * TreeSitterHaskellRunestone
    * TreeSitterJSDoc
    * TreeSitterJSDocQueries
    * TreeSitterJSDocRunestone
    * TreeSitterJSON
    * TreeSitterJSON5
    * TreeSitterJSON5Queries
    * TreeSitterJSON5Runestone
    * TreeSitterJSONQueries
      * Query.swift
      * highlights.scm
    * TreeSitterJSONRunestone
    * TreeSitterJava
    * TreeSitterJavaQueries
    * TreeSitterJavaRunestone
    * TreeSitterJavaScript
    * TreeSitterJavaScriptQueries
    * TreeSitterJavaScriptRunestone
    * TreeSitterJulia
    * TreeSitterJuliaQueries
    * TreeSitterJuliaRunestone
    * TreeSitterLaTeX
    * TreeSitterLaTeXQueries
    * TreeSitterLaTeXRunestone
    * TreeSitterLanguagesCommon
    * TreeSitterLua
    * TreeSitterLuaQueries
    * TreeSitterLuaRunestone
    * TreeSitterMarkdown
    * TreeSitterMarkdownInline
    * TreeSitterMarkdownInlineQueries
    * TreeSitterMarkdownInlineRunestone
    * TreeSitterMarkdownQueries
    * TreeSitterMarkdownRunestone
    * TreeSitterOCaml
    * TreeSitterOCamlQueries
    * TreeSitterOCamlRunestone
    * TreeSitterPHP
    * TreeSitterPHPQueries
    * TreeSitterPHPRunestone
    * TreeSitterPerl
    * TreeSitterPerlQueries
    * TreeSitterPerlRunestone
    * TreeSitterPython
    * TreeSitterPythonQueries
    * TreeSitterPythonRunestone
    * TreeSitterR
    * TreeSitterRQueries
    * TreeSitterRRunestone
    * TreeSitterRegex
    * TreeSitterRegexQueries
    * TreeSitterRegexRunestone
    * TreeSitterRuby
    * TreeSitterRubyQueries
    * TreeSitterRubyRunestone
    * TreeSitterRust
    * TreeSitterRustQueries
    * TreeSitterRustRunestone
    * TreeSitterSCSS
    * TreeSitterSCSSQueries
    * TreeSitterSCSSRunestone
    * TreeSitterSQL
    * TreeSitterSQLQueries
    * TreeSitterSQLRunestone
    * TreeSitterSvelte
    * TreeSitterSvelteQueries
    * TreeSitterSvelteRunestone
    * TreeSitterSwift
    * TreeSitterSwiftQueries
    * TreeSitterSwiftRunestone
    * TreeSitterTOML
    * TreeSitterTOMLQueries
    * TreeSitterTOMLRunestone
    * TreeSitterTSX
    * TreeSitterTSXQueries
    * TreeSitterTSXRunestone
    * TreeSitterTypeScript
    * TreeSitterTypeScriptQueries
    * TreeSitterTypeScriptRunestone
    * TreeSitterYAML
    * TreeSitterYAMLQueries
    * TreeSitterYAMLRunestone
  * .gitignore
  * LICENSE
  * Package.resolved
  * Package.swift
  * README.md


## Breadcrumbs
  1. [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages/tree/main)
  2. /[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)


/
# TreeSitterJSONQueries
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
[History](https://github.com/simonbs/TreeSitterLanguages/commits/main/Sources/TreeSitterJSONQueries)
[](https://github.com/simonbs/TreeSitterLanguages/commits/main/Sources/TreeSitterJSONQueries)History
## Breadcrumbs
  1. [TreeSitterLanguages](https://github.com/simonbs/TreeSitterLanguages/tree/main)
  2. /[Sources](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)


/
# TreeSitterJSONQueries
/
Top
## Folders and files
Name | Name | Last commit message | Last commit date  
---|---|---|---  
### parent directory
[](https://github.com/simonbs/TreeSitterLanguages/tree/main/Sources)  
[Query.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONQueries/Query.swift "Query.swift") | [Query.swift](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONQueries/Query.swift "Query.swift") |  |   
[highlights.scm](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONQueries/highlights.scm "highlights.scm") | [highlights.scm](https://github.com/simonbs/TreeSitterLanguages/blob/main/Sources/TreeSitterJSONQueries/highlights.scm "highlights.scm") |  |   
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
{"url": "https://raw.githubusercontent.com/simonbs/TreeSitterLanguages/main/Sources/TreeSitterJSONQueries/highlights.scm", "use_crawl4ai": false}
>>>END

---

## 🔧 TOOL RESULTS

[web_fetch]
🌐 https://raw.githubusercontent.com/simonbs/TreeSitterLanguages/main/Sources/TreeSitterJSONQueries/highlights.scm

(pair
  key: (_) @string.special.key)

(string) @string

(number) @number

[
  (null)
  (true)
  (false)
] @constant.builtin

(escape_sequence) @escape

(comment) @comment


I found the key information. The JSON highlights.scm file shows:
- Keys: `(pair key: (_) @string.special.key)` → emits `string.special.key`
- String values: `(string) @string` → emits `string`

The `textColor(for:)` method at line 603 checks `highlightName.hasPrefix("string.special")` BEFORE the general `string` check at line 611 - this should be correct.

Let me check the Theme colors to see if the issue is the actual color definitions:

>>>TOOL search
{"query": "string.*color.*CE9178", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "string.*color.*CE9178"


>>>TOOL search
{"query": "stringColor", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "stringColor"


>>>TOOL search
{"query": "var string:", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "var string:"


Let me search for the Theme structure that defines the colors:

>>>TOOL search
{"query": "struct Theme", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "struct Theme"


>>>TOOL search
{"query": "struct Theme", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "struct Theme"


>>>TOOL search
{"query": "var string:", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "var string:"


>>>TOOL search
{"query": "editorForeground", "glob": "*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "editorForeground"


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift (lines 1-887 of 887)
────────────────────────────────────────
1: import SwiftUI
2: 
3: struct Theme: Identifiable, Equatable, Hashable {
4:     let id: String
5:     let name: String
6:     let isDark: Bool
7:     
8:     // Editor Colors
9:     let editorBackground: Color
10:     let editorForeground: Color
11:     let selection: Color
12:     let cursor: Color
13:     let lineNumber: Color
14:     let lineNumberActive: Color
15:     let currentLineHighlight: Color
16:     let bracketPair1: Color
17:     let bracketPair2: Color
18:     let bracketPair3: Color
19:     let bracketPair4: Color
20:     let bracketPair5: Color
21:     let bracketPair6: Color
22:     let indentGuide: Color
23:     let indentGuideActive: Color
24:     
25:     // UI Colors
26:     let sidebarBackground: Color
27:     let sidebarForeground: Color
28:     let sidebarSectionHeader: Color
29:     let sidebarSelection: Color
30:     let activityBarBackground: Color
31:     let activityBarForeground: Color
32:     let activityBarSelection: Color
33:     let tabBarBackground: Color
34:     let tabActiveBackground: Color
35:     let tabInactiveBackground: Color
36:     let tabActiveForeground: Color
37:     let tabInactiveForeground: Color
38:     let statusBarBackground: Color
39:     let statusBarForeground: Color
40:     
41:     // Syntax Colors
42:     let keyword: Color
43:     let string: Color
44:     let number: Color
45:     let comment: Color
46:     let function: Color
47:     let type: Color
48:     let variable: Color
49:     
50:     // Helper for Hex Colors
51:     static func hex(_ hex: String) -> Color {
52:         var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
53:         hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
54:         
55:         var rgb: UInt64 = 0
56:         Scanner(string: hexSanitized).scanHexInt64(&rgb)
57:         
58:         let r = Double((rgb & 0xFF0000) >> 16) / 255.0
59:         let g = Double((rgb & 0x00FF00) >> 8) / 255.0
60:         let b = Double(rgb & 0x0000FF) / 255.0
61:         
62:         return Color(red: r, green: g, blue: b)
63:     }
64:     
65:     // MARK: - VS Code Default Themes
66:     
67:     static let darkPlus = Theme(
68:         id: "dark_plus",
69:         name: "Dark+ (Default Dark)",
70:         isDark: true,
71:         editorBackground: hex("#1E1E1E"),
72:         editorForeground: hex("#D4D4D4"),
73:         selection: hex("#264F78"),
74:         cursor: hex("#AEAFAD"),
75:         lineNumber: hex("#858585"),
76:         lineNumberActive: hex("#C6C6C6"),
77:         currentLineHighlight: hex("#FFFFFF").opacity(0.1),
78:         bracketPair1: hex("#FFD700"),
79:         bracketPair2: hex("#DA70D6"),
80:         bracketPair3: hex("#179FFF"),
81:         bracketPair4: hex("#FFD700"),
82:         bracketPair5: hex("#DA70D6"),
83:         bracketPair6: hex("#179FFF"),
84:         indentGuide: hex("#404040"),
85:         indentGuideActive: hex("#707070"),
86:         sidebarBackground: hex("#252526"),
87:         sidebarForeground: hex("#CCCCCC"),
88:         sidebarSectionHeader: hex("#383838"),
89:         sidebarSelection: hex("#37373D"),
90:         activityBarBackground: hex("#333333"),
91:         activityBarForeground: hex("#FFFFFF"),
92:         activityBarSelection: hex("#FFFFFF"),
93:         tabBarBackground: hex("#252526"),
94:         tabActiveBackground: hex("#1E1E1E"),
95:         tabInactiveBackground: hex("#2D2D2D"),
96:         tabActiveForeground: hex("#FFFFFF"),
97:         tabInactiveForeground: hex("#969696"),
98:         statusBarBackground: hex("#007ACC"),
99:         statusBarForeground: hex("#FFFFFF"),
100:         keyword: hex("#569CD6"),
101:         string: hex("#CE9178"),
102:         number: hex("#B5CEA8"),
103:         comment: hex("#6A9955"),
104:         function: hex("#DCDCAA"),
105:         type: hex("#4EC9B0"),
106:         variable: hex("#9CDCFE")
107:     )
108:     
109:     static let lightPlus = Theme(
110:         id: "light_plus",
111:         name: "Light+ (Default Light)",
112:         isDark: false,
113:         editorBackground: hex("#FFFFFF"),
114:         editorForeground: hex("#000000"),
115:         selection: hex("#ADD6FF"),
116:         cursor: hex("#000000"),
117:         lineNumber: hex("#237893"),
118:         lineNumberActive: hex("#0B216F"),
119:         currentLineHighlight: hex("#000000").opacity(0.07),
120:         bracketPair1: hex("#0431FA"),
121:         bracketPair2: hex("#319331"),
122:         bracketPair3: hex("#7B3814"),
123:         bracketPair4: hex("#0431FA"),
124:         bracketPair5: hex("#319331"),
125:         bracketPair6: hex("#7B3814"),
126:         indentGuide: hex("#D3D3D3"),
127:         indentGuideActive: hex("#939393"),
128:         sidebarBackground: hex("#F3F3F3"),
129:         sidebarForeground: hex("#616161"),
130:         sidebarSectionHeader: hex("#E7E7E7"),
131:         sidebarSelection: hex("#E4E6F1"),
132:         activityBarBackground: hex("#2C2C2C"),
133:         activityBarForeground: hex("#FFFFFF"),
134:         activityBarSelection: hex("#FFFFFF"),
135:         tabBarBackground: hex("#F3F3F3"),
136:         tabActiveBackground: hex("#FFFFFF"),
137:         tabInactiveBackground: hex("#ECECEC"),
138:         tabActiveForeground: hex("#333333"),
139:         tabInactiveForeground: hex("#8E8E8E"),
140:         statusBarBackground: hex("#007ACC"),
141:         statusBarForeground: hex("#FFFFFF"),
142:         keyword: hex("#AF00DB"),
143:         string: hex("#A31515"),
144:         number: hex("#098658"),
145:         comment: hex("#008000"),
146:         function: hex("#795E26"),
147:         type: hex("#267F99"),
148:         variable: hex("#001080")
149:     )
150:     
151:     static let monokai = Theme(
152:         id: "monokai",
153:         name: "Monokai",
154:         isDark: true,
155:         editorBackground: hex("#272822"),
156:         editorForeground: hex("#F8F8F2"),
157:         selection: hex("#49483E"),
158:         cursor: hex("#F8F8F0"),
159:         lineNumber: hex("#90908A"),
160:         lineNumberActive: hex("#F8F8F2"),
161:         currentLineHighlight: hex("#3E3D32"),
162:         bracketPair1: hex("#F8F8F2"),
163:         bracketPair2: hex("#F92672"),
164:         bracketPair3: hex("#A6E22E"),
165:         bracketPair4: hex("#F8F8F2"),
166:         bracketPair5: hex("#F92672"),
167:         bracketPair6: hex("#A6E22E"),
168:         indentGuide: hex("#464741"),
169:         indentGuideActive: hex("#75715E"),
170:         sidebarBackground: hex("#272822"),
171:         sidebarForeground: hex("#F8F8F2"),
172:         sidebarSectionHeader: hex("#1E1F1C"),
173:         sidebarSelection: hex("#49483E"),
174:         activityBarBackground: hex("#1E1F1C"),
175:         activityBarForeground: hex("#F8F8F2"),
176:         activityBarSelection: hex("#F8F8F2"),
177:         tabBarBackground: hex("#1E1F1C"),
178:         tabActiveBackground: hex("#272822"),
179:         tabInactiveBackground: hex("#34352F"),
180:         tabActiveForeground: hex("#F8F8F2"),
181:         tabInactiveForeground: hex("#88846F"),
182:         statusBarBackground: hex("#75715E"),
183:         statusBarForeground: hex("#F8F8F2"),
184:         keyword: hex("#F92672"),
185:         string: hex("#E6DB74"),
186:         number: hex("#AE81FF"),
187:         comment: hex("#75715E"),
188:         function: hex("#A6E22E"),
189:         type: hex("#66D9EF"),
190:         variable: hex("#FD971F")
191:     )
192:     
193:     static let solarizedDark = Theme(
194:         id: "solarized_dark",
195:         name: "Solarized Dark",
196:         isDark: true,
197:         editorBackground: hex("#002B36"),
198:         editorForeground: hex("#839496"),
199:         selection: hex("#274642"),
200:         cursor: hex("#D30102"),
201:         lineNumber: hex("#586E75"),
202:         lineNumberActive: hex("#93A1A1"),
203:         currentLineHighlight: hex("#0A2933"),
204:         bracketPair1: hex("#859900"),
205:         bracketPair2: hex("#2AA198"),
206:         bracketPair3: hex("#268BD2"),
207:         bracketPair4: hex("#859900"),
208:         bracketPair5: hex("#2AA198"),
209:         bracketPair6: hex("#268BD2"),
210:         indentGuide: hex("#073642"),
211:         indentGuideActive: hex("#586E75"),
212:         sidebarBackground: hex("#00252E"),
213:         sidebarForeground: hex("#93A1A1"),
214:         sidebarSectionHeader: hex("#001F27"),
215:         sidebarSelection: hex("#073642"),
216:         activityBarBackground: hex("#002B36"),
217:         activityBarForeground: hex("#93A1A1"),
218:         activityBarSelection: hex("#FDF6E3"),
219:         tabBarBackground: hex("#002B36"),
220:         tabActiveBackground: hex("#002B36"),
221:         tabInactiveBackground: hex("#00212B"),
222:         tabActiveForeground: hex("#93A1A1"),
223:         tabInactiveForeground: hex("#586E75"),
224:         statusBarBackground: hex("#00212B"),
225:         statusBarForeground: hex("#93A1A1"),
226:         keyword: hex("#859900"),
227:         string: hex("#2AA198"),
228:         number: hex("#D33682"),
229:         comment: hex("#586E75"),
230:         function: hex("#268BD2"),
231:         type: hex("#CB4B16"),
232:         variable: hex("#B58900")
233:     )
234:     
235:     static let solarizedLight = Theme(
236:         id: "solarized_light",
237:         name: "Solarized Light",
238:         isDark: false,
239:         editorBackground: hex("#FDF6E3"),
240:         editorForeground: hex("#657B83"),
241:         selection: hex("#EEE8D5"),
242:         cursor: hex("#D30102"),
243:         lineNumber: hex("#93A1A1"),
244:         lineNumberActive: hex("#586E75"),
245:         currentLineHighlight: hex("#EEE8D5"),
246:         bracketPair1: hex("#859900"),
247:         bracketPair2: hex("#2AA198"),
248:         bracketPair3: hex("#268BD2"),
249:         bracketPair4: hex("#859900"),
250:         bracketPair5: hex("#2AA198"),
251:         bracketPair6: hex("#268BD2"),
252:         indentGuide: hex("#EEE8D5"),
253:         indentGuideActive: hex("#93A1A1"),
254:         sidebarBackground: hex("#EEE8D5"),
255:         sidebarForeground: hex("#586E75"),
256:         sidebarSectionHeader: hex("#DDD6C1"),
257:         sidebarSelection: hex("#D3CBB8"),
258:         activityBarBackground: hex("#DDD6C1"),
259:         activityBarForeground: hex("#586E75"),
260:         activityBarSelection: hex("#073642"),
261:         tabBarBackground: hex("#EEE8D5"),
262:         tabActiveBackground: hex("#FDF6E3"),
263:         tabInactiveBackground: hex("#EEE8D5"),
264:         tabActiveForeground: hex("#073642"),
265:         tabInactiveForeground: hex("#93A1A1"),
266:         statusBarBackground: hex("#EEE8D5"),
267:         statusBarForeground: hex("#586E75"),
268:         keyword: hex("#859900"),
269:         string: hex("#2AA198"),
270:         number: hex("#D33682"),
271:         comment: hex("#93A1A1"),
272:         function: hex("#268BD2"),
273:         type: hex("#CB4B16"),
274:         variable: hex("#B58900")
275:     )
276:     
277:     static let dracula = Theme(
278:         id: "dracula",
279:         name: "Dracula",
280:         isDark: true,
281:         editorBackground: hex("#282A36"),
282:         editorForeground: hex("#F8F8F2"),
283:         selection: hex("#44475A"),
284:         cursor: hex("#F8F8F2"),
285:         lineNumber: hex("#6272A4"),
286:         lineNumberActive: hex("#F8F8F2"),
287:         currentLineHighlight: hex("#44475A"),
288:         bracketPair1: hex("#F8F8F2"),
289:         bracketPair2: hex("#FF79C6"),
290:         bracketPair3: hex("#8BE9FD"),
291:         bracketPair4: hex("#F8F8F2"),
292:         bracketPair5: hex("#FF79C6"),
293:         bracketPair6: hex("#8BE9FD"),
294:         indentGuide: hex("#424450"),
295:         indentGuideActive: hex("#6272A4"),
296:         sidebarBackground: hex("#21222C"),
297:         sidebarForeground: hex("#F8F8F2"),
298:         sidebarSectionHeader: hex("#191A21"),
299:         sidebarSelection: hex("#44475A"),
300:         activityBarBackground: hex("#343746"),
301:         activityBarForeground: hex("#F8F8F2"),
302:         activityBarSelection: hex("#F8F8F2"),
303:         tabBarBackground: hex("#191A21"),
304:         tabActiveBackground: hex("#282A36"),
305:         tabInactiveBackground: hex("#21222C"),
306:         tabActiveForeground: hex("#F8F8F2"),
307:         tabInactiveForeground: hex("#6272A4"),
308:         statusBarBackground: hex("#BD93F9"),
309:         statusBarForeground: hex("#282A36"),
310:         keyword: hex("#FF79C6"),
311:         string: hex("#F1FA8C"),
312:         number: hex("#BD93F9"),
313:         comment: hex("#6272A4"),
314:         function: hex("#50FA7B"),
315:         type: hex("#8BE9FD"),
316:         variable: hex("#FFB86C")
317:     )
318:     
319:     static let oneDarkPro = Theme(
320:         id: "one_dark_pro",
321:         name: "One Dark Pro",
322:         isDark: true,
323:         editorBackground: hex("#282C34"),
324:         editorForeground: hex("#ABB2BF"),
325:         selection: hex("#3E4451"),
326:         cursor: hex("#528BFF"),
327:         lineNumber: hex("#4B5263"),
328:         lineNumberActive: hex("#ABB2BF"),
329:         currentLineHighlight: hex("#2C313C"),
330:         bracketPair1: hex("#C678DD"),
331:         bracketPair2: hex("#61AFEF"),
332:         bracketPair3: hex("#E5C07B"),
333:         bracketPair4: hex("#C678DD"),
334:         bracketPair5: hex("#61AFEF"),
335:         bracketPair6: hex("#E5C07B"),
336:         indentGuide: hex("#3B4048"),
337:         indentGuideActive: hex("#5C6370"),
338:         sidebarBackground: hex("#21252B"),
339:         sidebarForeground: hex("#ABB2BF"),
340:         sidebarSectionHeader: hex("#282C34"),
341:         sidebarSelection: hex("#2C313A"),
342:         activityBarBackground: hex("#282C34"),
343:         activityBarForeground: hex("#ABB2BF"),
344:         activityBarSelection: hex("#D7DAE0"),
345:         tabBarBackground: hex("#21252B"),
346:         tabActiveBackground: hex("#282C34"),
347:         tabInactiveBackground: hex("#21252B"),
348:         tabActiveForeground: hex("#D7DAE0"),
349:         tabInactiveForeground: hex("#5C6370"),
350:         statusBarBackground: hex("#21252B"),
351:         statusBarForeground: hex("#9DA5B4"),
352:         keyword: hex("#C678DD"),
353:         string: hex("#98C379"),
354:         number: hex("#D19A66"),
355:         comment: hex("#5C6370"),
356:         function: hex("#61AFEF"),
357:         type: hex("#E5C07B"),
358:         variable: hex("#E06C75")
359:     )
360:     
361:     static let nord = Theme(
362:         id: "nord",
363:         name: "Nord",
364:         isDark: true,
365:         editorBackground: hex("#2E3440"),
366:         editorForeground: hex("#D8DEE9"),
367:         selection: hex("#434C5E"),
368:         cursor: hex("#D8DEE9"),
369:         lineNumber: hex("#4C566A"),
370:         lineNumberActive: hex("#D8DEE9"),
371:         currentLineHighlight: hex("#3B4252"),
372:         bracketPair1: hex("#EBCB8B"),
373:         bracketPair2: hex("#A3BE8C"),
374:         bracketPair3: hex("#81A1C1"),
375:         bracketPair4: hex("#EBCB8B"),
376:         bracketPair5: hex("#A3BE8C"),
377:         bracketPair6: hex("#81A1C1"),
378:         indentGuide: hex("#434C5E"),
379:         indentGuideActive: hex("#4C566A"),
380:         sidebarBackground: hex("#2E3440"),
381:         sidebarForeground: hex("#D8DEE9"),
382:         sidebarSectionHeader: hex("#3B4252"),
383:         sidebarSelection: hex("#3B4252"),
384:         activityBarBackground: hex("#2E3440"),
385:         activityBarForeground: hex("#D8DEE9"),
386:         activityBarSelection: hex("#88C0D0"),
387:         tabBarBackground: hex("#2E3440"),
388:         tabActiveBackground: hex("#3B4252"),
389:         tabInactiveBackground: hex("#2E3440"),
390:         tabActiveForeground: hex("#D8DEE9"),
391:         tabInactiveForeground: hex("#4C566A"),
392:         statusBarBackground: hex("#3B4252"),
393:         statusBarForeground: hex("#D8DEE9"),
394:         keyword: hex("#81A1C1"),
395:         string: hex("#A3BE8C"),
396:         number: hex("#B48EAD"),
397:         comment: hex("#616E88"),
398:         function: hex("#88C0D0"),
399:         type: hex("#8FBCBB"),
400:         variable: hex("#D8DEE9")
401:     )
402:     
403:     static let githubDark = Theme(
404:         id: "github_dark",
405:         name: "GitHub Dark",
406:         isDark: true,
407:         editorBackground: hex("#0D1117"),
408:         editorForeground: hex("#C9D1D9"),
409:         selection: hex("#163356"),
410:         cursor: hex("#58A6FF"),
411:         lineNumber: hex("#484F58"),
412:         lineNumberActive: hex("#C9D1D9"),
413:         currentLineHighlight: hex("#161B22"),
414:         bracketPair1: hex("#79C0FF"),
415:         bracketPair2: hex("#D2A8FF"),
416:         bracketPair3: hex("#FFA657"),
417:         bracketPair4: hex("#79C0FF"),
418:         bracketPair5: hex("#D2A8FF"),
419:         bracketPair6: hex("#FFA657"),
420:         indentGuide: hex("#21262D"),
421:         indentGuideActive: hex("#30363D"),
422:         sidebarBackground: hex("#010409"),
423:         sidebarForeground: hex("#C9D1D9"),
424:         sidebarSectionHeader: hex("#161B22"),
425:         sidebarSelection: hex("#1F2428"),
426:         activityBarBackground: hex("#0D1117"),
427:         activityBarForeground: hex("#C9D1D9"),
428:         activityBarSelection: hex("#C9D1D9"),
429:         tabBarBackground: hex("#010409"),
430:         tabActiveBackground: hex("#0D1117"),
431:         tabInactiveBackground: hex("#010409"),
432:         tabActiveForeground: hex("#C9D1D9"),
433:         tabInactiveForeground: hex("#8B949E"),
434:         statusBarBackground: hex("#0D1117"),
435:         statusBarForeground: hex("#58A6FF"),
436:         keyword: hex("#FF7B72"),
437:         string: hex("#A5D6FF"),
438:         number: hex("#79C0FF"),
439:         comment: hex("#8B949E"),
440:         function: hex("#D2A8FF"),
441:         type: hex("#79C0FF"),
442:         variable: hex("#FFA657")
443:     )
444:     
445:     static let githubLight = Theme(
446:         id: "github_light",
447:         name: "GitHub Light",
448:         isDark: false,
449:         editorBackground: hex("#FFFFFF"),
450:         editorForeground: hex("#24292F"),
451:         selection: hex("#B6E3FF"),
452:         cursor: hex("#0969DA"),
453:         lineNumber: hex("#8C959F"),
454:         lineNumberActive: hex("#24292F"),
455:         currentLineHighlight: hex("#F6F8FA"),
456:         bracketPair1: hex("#0550AE"),
457:         bracketPair2: hex("#8250DF"),
458:         bracketPair3: hex("#953800"),
459:         bracketPair4: hex("#0550AE"),
460:         bracketPair5: hex("#8250DF"),
461:         bracketPair6: hex("#953800"),
462:         indentGuide: hex("#D0D7DE"),
463:         indentGuideActive: hex("#8C959F"),
464:         sidebarBackground: hex("#F6F8FA"),
465:         sidebarForeground: hex("#24292F"),
466:         sidebarSectionHeader: hex("#EAEEF2"),
467:         sidebarSelection: hex("#DDFBE6"),
468:         activityBarBackground: hex("#F6F8FA"),
469:         activityBarForeground: hex("#24292F"),
470:         activityBarSelection: hex("#24292F"),
471:         tabBarBackground: hex("#F6F8FA"),
472:         tabActiveBackground: hex("#FFFFFF"),
473:         tabInactiveBackground: hex("#F6F8FA"),
474:         tabActiveForeground: hex("#24292F"),
475:         tabInactiveForeground: hex("#57606A"),
476:         statusBarBackground: hex("#F6F8FA"),
477:         statusBarForeground: hex("#0969DA"),
478:         keyword: hex("#CF222E"),
479:         string: hex("#0A3069"),
480:         number: hex("#0550AE"),
481:         comment: hex("#6E7781"),
482:         function: hex("#8250DF"),
483:         type: hex("#0550AE"),
484:         variable: hex("#953800")
485:     )
486:     
487:     static let cobalt2 = Theme(
488:         id: "cobalt2",
489:         name: "Cobalt2",
490:         isDark: true,
491:         editorBackground: hex("#193549"),
492:         editorForeground: hex("#FFFFFF"),
493:         selection: hex("#0D3A58"),
494:         cursor: hex("#FEFB00"),
495:         lineNumber: hex("#3D5F7D"),
496:         lineNumberActive: hex("#FFFFFF"),
497:         currentLineHighlight: hex("#1F4662"),
498:         bracketPair1: hex("#FFC600"),
499:         bracketPair2: hex("#FF628C"),
500:         bracketPair3: hex("#80FFBB"),
501:         bracketPair4: hex("#FFC600"),
502:         bracketPair5: hex("#FF628C"),
503:         bracketPair6: hex("#80FFBB"),
504:         indentGuide: hex("#294B5C"),
505:         indentGuideActive: hex("#3D5F7D"),
506:         sidebarBackground: hex("#15232D"),
507:         sidebarForeground: hex("#FFFFFF"),
508:         sidebarSectionHeader: hex("#0D1A23"),
509:         sidebarSelection: hex("#0D3A58"),
510:         activityBarBackground: hex("#193549"),
511:         activityBarForeground: hex("#FFFFFF"),
512:         activityBarSelection: hex("#FFC600"),
513:         tabBarBackground: hex("#15232D"),
514:         tabActiveBackground: hex("#193549"),
515:         tabInactiveBackground: hex("#15232D"),
516:         tabActiveForeground: hex("#FFFFFF"),
517:         tabInactiveForeground: hex("#3D5F7D"),
518:         statusBarBackground: hex("#15232D"),
519:         statusBarForeground: hex("#FFFFFF"),
520:         keyword: hex("#FF9D00"),
521:         string: hex("#A5FF90"),
522:         number: hex("#FF628C"),
523:         comment: hex("#0088FF"),
524:         function: hex("#FFC600"),
525:         type: hex("#80FFBB"),
526:         variable: hex("#9EFFFF")
527:     )
528:     
529:     static let ayuDark = Theme(
530:         id: "ayu_dark",
531:         name: "Ayu Dark",
532:         isDark: true,
533:         editorBackground: hex("#0A0E14"),
534:         editorForeground: hex("#B3B1AD"),
535:         selection: hex("#273747"),
536:         cursor: hex("#E6B450"),
537:         lineNumber: hex("#3D424D"),
538:         lineNumberActive: hex("#E6B450"),
539:         currentLineHighlight: hex("#0D1016"),
540:         bracketPair1: hex("#FFB454"),
541:         bracketPair2: hex("#59C2FF"),
542:         bracketPair3: hex("#AAD94C"),
543:         bracketPair4: hex("#FFB454"),
544:         bracketPair5: hex("#59C2FF"),
545:         bracketPair6: hex("#AAD94C"),
546:         indentGuide: hex("#1C212B"),
547:         indentGuideActive: hex("#3D424D"),
548:         sidebarBackground: hex("#0D1016"),
549:         sidebarForeground: hex("#B3B1AD"),
550:         sidebarSectionHeader: hex("#0A0E14"),
551:         sidebarSelection: hex("#273747"),
552:         activityBarBackground: hex("#0A0E14"),
553:         activityBarForeground: hex("#B3B1AD"),
554:         activityBarSelection: hex("#E6B450"),
555:         tabBarBackground: hex("#0D1016"),
556:         tabActiveBackground: hex("#0A0E14"),
557:         tabInactiveBackground: hex("#0D1016"),
558:         tabActiveForeground: hex("#B3B1AD"),
559:         tabInactiveForeground: hex("#3D424D"),
560:         statusBarBackground: hex("#0D1016"),
561:         statusBarForeground: hex("#B3B1AD"),
562:         keyword: hex("#FF8F40"),
563:         string: hex("#AAD94C"),
564:         number: hex("#DFBFFF"),
565:         comment: hex("#626A73"),
566:         function: hex("#FFB454"),
567:         type: hex("#59C2FF"),
568:         variable: hex("#B3B1AD")
569:     )
570:     
571:     static let ayuLight = Theme(
572:         id: "ayu_light",
573:         name: "Ayu Light",
574:         isDark: false,
575:         editorBackground: hex("#FAFAFA"),
576:         editorForeground: hex("#5C6166"),
577:         selection: hex("#D1E4F4"),
578:         cursor: hex("#FF9940"),
579:         lineNumber: hex("#9DA2A6"),
580:         lineNumberActive: hex("#FF9940"),
581:         currentLineHighlight: hex("#EFF0F1"),
582:         bracketPair1: hex("#F2AE49"),
583:         bracketPair2: hex("#399EE6"),
584:         bracketPair3: hex("#86B300"),
585:         bracketPair4: hex("#F2AE49"),
586:         bracketPair5: hex("#399EE6"),
587:         bracketPair6: hex("#86B300"),
588:         indentGuide: hex("#E7E8E9"),
589:         indentGuideActive: hex("#9DA2A6"),
590:         sidebarBackground: hex("#F0F0F0"),
591:         sidebarForeground: hex("#5C6166"),
592:         sidebarSectionHeader: hex("#E7E7E7"),
593:         sidebarSelection: hex("#D1E4F4"),
594:         activityBarBackground: hex("#F0F0F0"),
595:         activityBarForeground: hex("#5C6166"),
596:         activityBarSelection: hex("#FF9940"),
597:         tabBarBackground: hex("#F0F0F0"),
598:         tabActiveBackground: hex("#FAFAFA"),
599:         tabInactiveBackground: hex("#F0F0F0"),
600:         tabActiveForeground: hex("#5C6166"),
601:         tabInactiveForeground: hex("#9DA2A6"),
602:         statusBarBackground: hex("#F0F0F0"),
603:         statusBarForeground: hex("#5C6166"),
604:         keyword: hex("#FA8D3E"),
605:         string: hex("#86B300"),
606:         number: hex("#A37ACC"),
607:         comment: hex("#ABB0B6"),
608:         function: hex("#F2AE49"),
609:         type: hex("#399EE6"),
610:         variable: hex("#5C6166")
611:     )
612:     
613:     static let ayuMirage = Theme(
614:         id: "ayu_mirage",
615:         name: "Ayu Mirage",
616:         isDark: true,
617:         editorBackground: hex("#1F2430"),
618:         editorForeground: hex("#CBCCC6"),
619:         selection: hex("#33415E"),
620:         cursor: hex("#FFCC66"),
621:         lineNumber: hex("#707A8C"),
622:         lineNumberActive: hex("#FFCC66"),
623:         currentLineHighlight: hex("#232834"),
624:         bracketPair1: hex("#FFD580"),
625:         bracketPair2: hex("#73D0FF"),
626:         bracketPair3: hex("#BAE67E"),
627:         bracketPair4: hex("#FFD580"),
628:         bracketPair5: hex("#73D0FF"),
629:         bracketPair6: hex("#BAE67E"),
630:         indentGuide: hex("#2D3640"),
631:         indentGuideActive: hex("#707A8C"),
632:         sidebarBackground: hex("#232834"),
633:         sidebarForeground: hex("#CBCCC6"),
634:         sidebarSectionHeader: hex("#1F2430"),
635:         sidebarSelection: hex("#33415E"),
636:         activityBarBackground: hex("#1F2430"),
637:         activityBarForeground: hex("#CBCCC6"),
638:         activityBarSelection: hex("#FFCC66"),
639:         tabBarBackground: hex("#232834"),
640:         tabActiveBackground: hex("#1F2430"),
641:         tabInactiveBackground: hex("#232834"),
642:         tabActiveForeground: hex("#CBCCC6"),
643:         tabInactiveForeground: hex("#707A8C"),
644:         statusBarBackground: hex("#232834"),
645:         statusBarForeground: hex("#CBCCC6"),
646:         keyword: hex("#FFA759"),
647:         string: hex("#BAE67E"),
648:         number: hex("#D4BFFF"),
649:         comment: hex("#5C6773"),
650:         function: hex("#FFD580"),
651:         type: hex("#73D0FF"),
652:         variable: hex("#CBCCC6")
653:     )
654:     
655:     static let quietLight = Theme(
656:         id: "quiet_light",
657:         name: "Quiet Light",
658:         isDark: false,
659:         editorBackground: hex("#F5F5F5"),
660:         editorForeground: hex("#333333"),
661:         selection: hex("#C9D0D9"),
662:         cursor: hex("#54494B"),
663:         lineNumber: hex("#AAAAAA"),
664:         lineNumberActive: hex("#333333"),
665:         currentLineHighlight: hex("#E4F6D4"),
666:         bracketPair1: hex("#7A3E9D"),
667:         bracketPair2: hex("#448C27"),
668:         bracketPair3: hex("#4B83CD"),
669:         bracketPair4: hex("#7A3E9D"),
670:         bracketPair5: hex("#448C27"),
671:         bracketPair6: hex("#4B83CD"),
672:         indentGuide: hex("#E0E0E0"),
673:         indentGuideActive: hex("#AAAAAA"),
674:         sidebarBackground: hex("#E7E7E7"),
675:         sidebarForeground: hex("#333333"),
676:         sidebarSectionHeader: hex("#DDDDDD"),
677:         sidebarSelection: hex("#C9D0D9"),
678:         activityBarBackground: hex("#E7E7E7"),
679:         activityBarForeground: hex("#333333"),
680:         activityBarSelection: hex("#333333"),
681:         tabBarBackground: hex("#E7E7E7"),
682:         tabActiveBackground: hex("#F5F5F5"),
683:         tabInactiveBackground: hex("#E7E7E7"),
684:         tabActiveForeground: hex("#333333"),
685:         tabInactiveForeground: hex("#AAAAAA"),
686:         statusBarBackground: hex("#E7E7E7"),
687:         statusBarForeground: hex("#333333"),
688:         keyword: hex("#4B83CD"),
689:         string: hex("#448C27"),
690:         number: hex("#AB6526"),
691:         comment: hex("#AAAAAA"),
692:         function: hex("#7A3E9D"),
693:         type: hex("#7A3E9D"),
694:         variable: hex("#333333")
695:     )
696:     
697:     static let red = Theme(
698:         id: "red",
699:         name: "Red",
700:         isDark: true,
701:         editorBackground: hex("#390000"),
702:         editorForeground: hex("#F8F8F8"),
703:         selection: hex("#750000"),
704:         cursor: hex("#FF0000"),
705:         lineNumber: hex("#FF6666"),
706:         lineNumberActive: hex("#FFFFFF"),
707:         currentLineHighlight: hex("#500000"),
708:         bracketPair1: hex("#FFFF66"),
709:         bracketPair2: hex("#AAFFAA"),
710:         bracketPair3: hex("#AADDFF"),
711:         bracketPair4: hex("#FFFF66"),
712:         bracketPair5: hex("#AAFFAA"),
713:         bracketPair6: hex("#AADDFF"),
714:         indentGuide: hex("#550000"),
715:         indentGuideActive: hex("#CC6666"),
716:         sidebarBackground: hex("#300000"),
717:         sidebarForeground: hex("#F8F8F8"),
718:         sidebarSectionHeader: hex("#500000"),
719:         sidebarSelection: hex("#750000"),
720:         activityBarBackground: hex("#390000"),
721:         activityBarForeground: hex("#F8F8F8"),
722:         activityBarSelection: hex("#FF0000"),
723:         tabBarBackground: hex("#300000"),
724:         tabActiveBackground: hex("#390000"),
725:         tabInactiveBackground: hex("#300000"),
726:         tabActiveForeground: hex("#FFFFFF"),
727:         tabInactiveForeground: hex("#CC6666"),
728:         statusBarBackground: hex("#FF0000"),
729:         statusBarForeground: hex("#FFFFFF"),
730:         keyword: hex("#FF6666"),
731:         string: hex("#FFA0A0"),
732:         number: hex("#FFD0D0"),
733:         comment: hex("#CC6666"),
734:         function: hex("#FFFF66"),
735:         type: hex("#AAFFAA"),
736:         variable: hex("#AADDFF")
737:     )
738:     
739:     static let tomorrowNight = Theme(
740:         id: "tomorrow_night",
741:         name: "Tomorrow Night",
742:         isDark: true,
743:         editorBackground: hex("#1D1F21"),
744:         editorForeground: hex("#C5C8C6"),
745:         selection: hex("#373B41"),
746:         cursor: hex("#AEAFAD"),
747:         lineNumber: hex("#969896"),
748:         lineNumberActive: hex("#C5C8C6"),
749:         currentLineHighlight: hex("#282A2E"),
750:         bracketPair1: hex("#F0C674"),
751:         bracketPair2: hex("#B5BD68"),
752:         bracketPair3: hex("#81A2BE"),
753:         bracketPair4: hex("#F0C674"),
754:         bracketPair5: hex("#B5BD68"),
755:         bracketPair6: hex("#81A2BE"),
756:         indentGuide: hex("#373B41"),
757:         indentGuideActive: hex("#969896"),
758:         sidebarBackground: hex("#1D1F21"),
759:         sidebarForeground: hex("#C5C8C6"),
760:         sidebarSectionHeader: hex("#282A2E"),
761:         sidebarSelection: hex("#373B41"),
762:         activityBarBackground: hex("#1D1F21"),
763:         activityBarForeground: hex("#C5C8C6"),
764:         activityBarSelection: hex("#81A2BE"),
765:         tabBarBackground: hex("#1D1F21"),
766:         tabActiveBackground: hex("#282A2E"),
767:         tabInactiveBackground: hex("#1D1F21"),
768:         tabActiveForeground: hex("#C5C8C6"),
769:         tabInactiveForeground: hex("#969896"),
770:         statusBarBackground: hex("#282A2E"),
771:         statusBarForeground: hex("#C5C8C6"),
772:         keyword: hex("#B294BB"),
773:         string: hex("#B5BD68"),
774:         number: hex("#DE935F"),
775:         comment: hex("#969896"),
776:         function: hex("#81A2BE"),
777:         type: hex("#F0C674"),
778:         variable: hex("#CC6666")
779:     )
780:     
781:     static let tomorrowNightBlue = Theme(
782:         id: "tomorrow_night_blue",
783:         name: "Tomorrow Night Blue",
784:         isDark: true,
785:         editorBackground: hex("#002451"),
786:         editorForeground: hex("#FFFFFF"),
787:         selection: hex("#003F8E"),
788:         cursor: hex("#FFFFFF"),
789:         lineNumber: hex("#7285B7"),
790:         lineNumberActive: hex("#FFFFFF"),
791:         currentLineHighlight: hex("#00346E"),
792:         bracketPair1: hex("#FFEEAD"),
793:         bracketPair2: hex("#D1F1A9"),
794:         bracketPair3: hex("#BBDAFF"),
795:         bracketPair4: hex("#FFEEAD"),
796:         bracketPair5: hex("#D1F1A9"),
797:         bracketPair6: hex("#BBDAFF"),
798:         indentGuide: hex("#003875"),
799:         indentGuideActive: hex("#7285B7"),
800:         sidebarBackground: hex("#001E40"),
801:         sidebarForeground: hex("#FFFFFF"),
802:         sidebarSectionHeader: hex("#003875"),
803:         sidebarSelection: hex("#003F8E"),
804:         activityBarBackground: hex("#002451"),
805:         activityBarForeground: hex("#FFFFFF"),
806:         activityBarSelection: hex("#BBDAFF"),
807:         tabBarBackground: hex("#001E40"),
808:         tabActiveBackground: hex("#002451"),
809:         tabInactiveBackground: hex("#001E40"),
810:         tabActiveForeground: hex("#FFFFFF"),
811:         tabInactiveForeground: hex("#7285B7"),
812:         statusBarBackground: hex("#003875"),
813:         statusBarForeground: hex("#FFFFFF"),
814:         keyword: hex("#EBBBFF"),
815:         string: hex("#D1F1A9"),
816:         number: hex("#FFC58F"),
817:         comment: hex("#7285B7"),
818:         function: hex("#BBDAFF"),
819:         type: hex("#FFEEAD"),
820:         variable: hex("#FF9DA4")
821:     )
822:     
823:     static let highContrast = Theme(
824:         id: "high_contrast",
825:         name: "High Contrast",
826:         isDark: true,
827:         editorBackground: hex("#000000"),
828:         editorForeground: hex("#FFFFFF"),
829:         selection: hex("#FFFFFF").opacity(0.3),
830:         cursor: hex("#FFFFFF"),
831:         lineNumber: hex("#FFFFFF"),
832:         lineNumberActive: hex("#FFFFFF"),
833:         currentLineHighlight: hex("#FFFFFF").opacity(0.1),
834:         bracketPair1: hex("#FFD700"),
835:         bracketPair2: hex("#00FF00"),
836:         bracketPair3: hex("#00BFFF"),
837:         bracketPair4: hex("#FFD700"),
838:         bracketPair5: hex("#00FF00"),
839:         bracketPair6: hex("#00BFFF"),
840:         indentGuide: hex("#FFFFFF").opacity(0.2),
841:         indentGuideActive: hex("#FFFFFF").opacity(0.5),
842:         sidebarBackground: hex("#000000"),
843:         sidebarForeground: hex("#FFFFFF"),
844:         sidebarSectionHeader: hex("#000000"),
845:         sidebarSelection: hex("#FFFFFF").opacity(0.15),
846:         activityBarBackground: hex("#000000"),
847:         activityBarForeground: hex("#FFFFFF"),
848:         activityBarSelection: hex("#FFFFFF"),
849:         tabBarBackground: hex("#000000"),
850:         tabActiveBackground: hex("#000000"),
851:         tabInactiveBackground: hex("#000000"),
852:         tabActiveForeground: hex("#FFFFFF"),
853:         tabInactiveForeground: hex("#FFFFFF").opacity(0.6),
854:         statusBarBackground: hex("#0000AA"),
855:         statusBarForeground: hex("#FFFFFF"),
856:         keyword: hex("#569CD6"),
857:         string: hex("#CE9178"),
858:         number: hex("#B5CEA8"),
859:         comment: hex("#7CA668"),
860:         function: hex("#DCDCAA"),
861:         type: hex("#4EC9B0"),
862:         variable: hex("#9CDCFE")
863:     )
864:     
865:     // MARK: - All Themes
866:     static let allThemes: [Theme] = [
867:         .darkPlus,
868:         .lightPlus,
869:         .monokai,
870:         .solarizedDark,
871:         .solarizedLight,
872:         .dracula,
873:         .oneDarkPro,
874:         .nord,
875:         .githubDark,
876:         .githubLight,
877:         .cobalt2,
878:         .ayuDark,
879:         .ayuLight,
880:         .ayuMirage,
881:         .quietLight,
882:         .red,
883:         .tomorrowNight,
884:         .tomorrowNightBlue,
885:         .highContrast
886:     ]
887: }


Now I have all the information. Let me look at the RunestoneEditorView.swift more carefully to understand the issue. The key insight from the JSON highlights.scm shows:

```scm
(pair
  key: (_) @string.special.key)

(string) @string
```

The problem is that in JSON, a key IS a `string` node. So BOTH rules can match the same node:
- Rule 1: Captures the key (which is a string) as `@string.special.key`
- Rule 2: Captures ALL string nodes as `@string`

When both rules match the same node, tree-sitter can emit multiple highlights. Let me verify the `textColor(for:)` logic one more time:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift", "start_line": 586, "end_line": 620}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift (lines 587-620 of 735)
────────────────────────────────────────
587:         // Map TreeSitter highlight names to colors
588:         // See: https://tree-sitter.github.io/tree-sitter/syntax-highlighting#highlights
589:         let highlightName = rawHighlightName.lowercased()
590:         
591:         // Debug: Log highlight names to understand TreeSitter output
592:         #if DEBUG
593:         print("🎨 Highlight: \(rawHighlightName)")
594:         #endif
595:         
596:         // Keywords
597:         if highlightName.contains("keyword") {
598:             return _keywordColor
599:         }
600:         
601:         // JSON/Object keys - check BEFORE general string check
602:         // TreeSitter JSON uses "string.special" for keys in some grammars
603:         if highlightName.hasPrefix("string.special") ||
604:            highlightName.contains("label") ||
605:            highlightName.contains("property.definition") ||
606:            (highlightName.contains("property") && !highlightName.contains("variable")) {
607:             return _variableColor  // Light blue #9CDCFE for keys
608:         }
609:         
610:         // Strings (values, not keys)
611:         if highlightName.contains("string") {
612:             return _stringColor  // Orange #CE9178 for string values
613:         }
614:         
615:         // Numbers and constants
616:         if highlightName.contains("number") || highlightName == "constant.numeric" {
617:             return _numberColor
618:         }
619:         
620:         // Comments


Now I have all the information needed to diagnose the issue. Let me write a report.

>>>REPORT
## JSON Syntax Highlighting Issue - Investigation Results

### Problem
JSON files show ALL RED (orange) text instead of proper syntax highlighting where keys should be light blue and values should be orange.

### Findings

**1. TreeSitterJSONRunestone is properly imported and configured:**
- Line 15: `import TreeSitterJSONRunestone` ✓
- Lines 251-252, 281-282: JSON extension properly maps to `TreeSitterLanguage.json` ✓
- project.pbxproj line 845-848: Package dependency correctly linked ✓

**2. The highlights.scm query file (from simonbs/TreeSitterLanguages) uses:**
```scm
(pair
  key: (_) @string.special.key)    ; Keys emit "string.special.key"

(string) @string                   ; All strings emit "string"
```

**3. The `textColor(for:)` method at lines 603-612 DOES check for `string.special` BEFORE `string`:**
```swift
// JSON/Object keys - check BEFORE general string check
if highlightName.hasPrefix("string.special") ||
   highlightName.contains("label") ||
   highlightName.contains("property.definition") ||
   (highlightName.contains("property") && !highlightName.contains("variable")) {
    return _variableColor  // Light blue #9CDCFE for keys
}

// Strings (values, not keys)
if highlightName.contains("string") {
    return _stringColor  // Orange #CE9178 for string values
}
```

### Root Cause

The issue is **NOT** in the `textColor(for:)` method ordering - that logic is correct. The likely causes are:

1. **Query capture overlap**: In JSON, a key IS a string node. Tree-sitter may emit BOTH `string.special.key` AND `string` captures for the same token. If Runestone processes these sequentially and the LAST one wins, the `string` capture overwrites the more-specific `string.special.key` capture.

2. **Highlight query not loaded**: The `TreeSitterJSONRunestone` module may not be properly bundling the highlights.scm from `TreeSitterJSONQueries`. Check if the debug statement `print("🎨 Highlight: \(rawHighlightName)")` (line 593) shows "string.special.key" or just "string" for JSON keys.

### Recommended Fixes

**Option A - Debug first (recommended):**
Run the app in DEBUG mode with a JSON file and check Xcode console output. If you see:
- `🎨 Highlight: string.special.key` → Query is working, issue is in capture priority
- `🎨 Highlight: string` only → Query file not loaded or not matching

**Option B - If captures show only "string":**
The TreeSitterJSONRunestone package queries may not be properly loaded. Verify the package version or check if a custom query needs to be bundled.

**Option C - If BOTH captures appear (overlapping):**
Modify `textColor(for:)` to cache the first/most-specific result per token range, or investigate Runestone's capture priority system.

### Files Examined
- `VSCodeiPadOS/VSCodeiPadOS/Views/Editor/RunestoneEditorView.swift` (lines 1-735)
- `VSCodeiPadOS/VSCodeiPadOS/Models/Theme.swift` (lines 1-887)
- `VSCodeiPadOS/VSCodeiPadOS.xcodeproj/project.pbxproj` (SPM dependencies, lines 805-870)
- GitHub: simonbs/TreeSitterLanguages/Sources/TreeSitterJSONQueries/highlights.scm
>>>END
