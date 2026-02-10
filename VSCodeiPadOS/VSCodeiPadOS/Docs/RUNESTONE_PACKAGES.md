# Runestone and Tree-sitter Packages Integration Guide

## Overview

This document provides instructions for integrating Runestone (a performant text editor for iOS) and Tree-sitter language packages into VSCodeiPadOS.

## Required Packages

### 1. Runestone Framework

**Description:** Performant plain text editor for iOS with syntax highlighting, code editing features, and Tree-sitter integration.

- **Repository:** https://github.com/simonbs/Runestone.git
- **Latest Version:** 0.5.1 (as of June 2024)
- **SPM Package URL:** `https://github.com/simonbs/Runestone.git`
- **Minimum iOS:** iOS 14.0+
- **Platforms:** iOS, iPadOS, visionOS (as of 0.4.0)

### 2. TreeSitterLanguages Package

**Description:** Tree-sitter language parsers wrapped in Swift packages for use with Runestone.

- **Repository:** https://github.com/simonbs/TreeSitterLanguages.git
- **Latest Version:** 0.1.10 (as of February 2024)
- **SPM Package URL:** `https://github.com/simonbs/TreeSitterLanguages.git`

## Language Packages to Add

The TreeSitterLanguages package contains multiple libraries. For each language, there are three packages:

1. `TreeSitter{Language}` - C code for the parser
2. `TreeSitter{Language}Queries` - Queries for syntax highlighting
3. `TreeSitter{Language}Runestone` - Ready-to-use integration with Runestone (USE THIS ONE)

### Required Languages for VSCodeiPadOS

| Language | Package Library Name | Import Statement |
|----------|---------------------|------------------|
| Swift | `TreeSitterSwiftRunestone` | `import TreeSitterSwiftRunestone` |
| JavaScript | `TreeSitterJavaScriptRunestone` | `import TreeSitterJavaScriptRunestone` |
| TypeScript | `TreeSitterTypeScriptRunestone` | `import TreeSitterTypeScriptRunestone` |
| Python | `TreeSitterPythonRunestone` | `import TreeSitterPythonRunestone` |
| JSON | `TreeSitterJsonRunestone` | `import TreeSitterJsonRunestone` |
| HTML | `TreeSitterHtmlRunestone` | `import TreeSitterHtmlRunestone` |
| CSS | `TreeSitterCssRunestone` | `import TreeSitterCssRunestone` |
| Markdown | `TreeSitterMarkdownRunestone` | `import TreeSitterMarkdownRunestone` |
| Rust | `TreeSitterRustRunestone` | `import TreeSitterRustRunestone` |
| Go | `TreeSitterGoRunestone` | `import TreeSitterGoRunestone` |
| Ruby | `TreeSitterRubyRunestone` | `import TreeSitterRubyRunestone` |

### Additional Available Languages (TreeSitterLanguages v0.1.10)

| Language | Package Library Name |
|----------|---------------------|
| Astro | `TreeSitterAstroRunestone` |
| Bash | `TreeSitterBashRunestone` |
| C | `TreeSitterCLanguageRunestone` |
| C++ | `TreeSitterCppRunestone` |
| C# | `TreeSitterCSharpRunestone` |
| Comment | `TreeSitterCommentRunestone` |
| Elixir | `TreeSitterElixirRunestone` |
| Elm | `TreeSitterElmRunestone` |
| Haskell | `TreeSitterHaskellRunestone` |
| Java | `TreeSitterJavaRunestone` |
| JSDoc | `TreeSitterJsdocRunestone` |
| JSON5 | `TreeSitterJson5Runestone` |
| Julia | `TreeSitterJuliaRunestone` |
| LaTeX | `TreeSitterLatexRunestone` |
| Lua | `TreeSitterLuaRunestone` |
| OCaml | `TreeSitterOcamlRunestone` |
| Perl | `TreeSitterPerlRunestone` |
| PHP | `TreeSitterPhpRunestone` |
| R | `TreeSitterRRunestone` |
| Regex | `TreeSitterRegexRunestone` |
| SCSS | `TreeSitterScssRunestone` |
| SQL | `TreeSitterSqlRunestone` |
| Svelte | `TreeSitterSvelteRunestone` |
| TOML | `TreeSitterTomlRunestone` |
| YAML | `TreeSitterYamlRunestone` |

**Note:** The TreeSitterLanguages package is a monorepo containing all these languages as separate library products. You only need to add the package once, then select which language libraries to link.

## Manual Xcode Package Addition Instructions

### Step 1: Add Runestone Package

1. Open `VSCodeiPadOS.xcodeproj` in Xcode
2. Select the project file in the Project Navigator (blue icon)
3. Select the `VSCodeiPadOS` **project** (not target)
4. Go to the **Package Dependencies** tab
5. Click the **+** button
6. Enter the package URL: `https://github.com/simonbs/Runestone.git`
7. For **Dependency Rule**, select:
   - **Up to Next Major Version:** `0.5.1`
8. Click **Add Package**
9. In the dialog that appears, ensure `Runestone` is checked
10. Click **Add Package**

### Step 2: Add TreeSitterLanguages Package

1. In the same **Package Dependencies** tab
2. Click the **+** button again
3. Enter the package URL: `https://github.com/simonbs/TreeSitterLanguages.git`
4. For **Dependency Rule**, select:
   - **Up to Next Minor Version:** `0.1.10`
5. Click **Add Package**
6. In the package products dialog, you'll see a list of all language libraries
7. **Select the `Runestone` variant for each required language** (see table above)
   - For minimum: `TreeSitterSwiftRunestone`, `TreeSitterJavaScriptRunestone`, `TreeSitterTypeScriptRunestone`, `TreeSitterPythonRunestone`, `TreeSitterJsonRunestone`, `TreeSitterHtmlRunestone`, `TreeSitterCssRunestone`, `TreeSitterMarkdownRunestone`
   - Optional: Add more languages as needed
8. Click **Add Package**

**Important:** Select ONLY the `Runestone` variants (e.g., `TreeSitterSwiftRunestone`), not the base `TreeSitter{Language}` or `TreeSitter{Language}Queries` packages. The Runestone variants include everything needed.

### Step 3: Link Libraries to Target

After adding the packages, ensure they're linked to your target:

1. Select the `VSCodeiPadOS` **target**
2. Go to **General** tab
3. Scroll to **Frameworks, Libraries, and Embedded Content**
4. Click **+** and add:
   - `Runestone`
   - All the `TreeSitter{Language}Runestone` packages you need

### Step 4: Verify Installation

After adding the packages:

1. Build the project (⌘+B)
2. Check that there are no import errors
3. Verify the packages appear in your project navigator under "Package Dependencies"

## Usage Example

Once packages are added, you can use them in your code:

```swift
import Runestone
import TreeSitterSwiftRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterTypeScriptRunestone
import TreeSitterPythonRunestone

class EditorManager {
    func createTextView(for language: String) -> TextView {
        let textView = TextView()
        
        switch language.lowercased() {
        case "swift":
            textView.setLanguageMode(TreeSitterLanguageMode(language: .swift))
        case "javascript", "js":
            textView.setLanguageMode(TreeSitterLanguageMode(language: .javaScript))
        case "typescript", "ts":
            textView.setLanguageMode(TreeSitterLanguageMode(language: .typeScript))
        case "python", "py":
            textView.setLanguageMode(TreeSitterLanguageMode(language: .python))
        default:
            break
        }
        
        return textView
    }
}
```

## File Extension to Language Mapping

```swift
func getLanguage(for fileExtension: String) -> TreeSitterLanguage? {
    switch fileExtension.lowercased() {
    case "swift":
        return .swift
    case "js", "jsx", "mjs":
        return .javaScript
    case "ts":
        return .typeScript
    case "tsx":
        return .tsx  // if available
    case "py", "pyw":
        return .python
    case "json":
        return .json
    case "html", "htm":
        return .html
    case "css":
        return .css
    case "md", "markdown":
        return .markdown
    case "rs":
        return .rust
    case "go":
        return .go
    case "rb":
        return .ruby
    case "c", "h":
        return .c
    case "cpp", "cc", "cxx", "hpp":
        return .cpp
    case "cs":
        return .cSharp
    case "java":
        return .java
    case "yaml", "yml":
        return .yaml
    case "sh", "bash", "zsh":
        return .bash
    case "sql":
        return .sql
    default:
        return nil
    }
}
```

## Troubleshooting

### Issue: Package resolution fails
- **Solution:** Check your network connection and ensure GitHub is accessible
- **Alternative:** Use Xcode's **File > Add Package Dependencies...** menu instead

### Issue: Language not available
- **Solution:** Check the TreeSitterLanguages repository for the full list of supported languages

### Issue: Build errors after adding packages
- **Solution:** Clean the build folder (⌘+Shift+K) and rebuild
- **Solution:** Ensure you're using Xcode 15.0 or later
- **Solution:** Reset package caches: **File > Packages > Reset Package Caches**

### Issue: Cannot find TreeSitterLanguage extension
- **Solution:** Make sure you imported both `Runestone` and the specific language package (e.g., `TreeSitterSwiftRunestone`)

### Issue: Xcode 16 build errors
- **Solution:** Use Runestone 0.5.1 or later (contains Xcode 16 fix)

### Issue: Long package resolution time
- **Solution:** TreeSitterLanguages is a large package. First resolution may take several minutes.
- **Alternative:** Consider the binary framework package (see below)

## Alternative: Binary Framework Package

For faster package resolution, consider using a pre-built binary framework:

- **Repository:** https://github.com/hjortura/TreesitterLanguages
- **Description:** Includes all tree-sitter languages in a single binary framework
- **Use case:** Better for CI/CD and slow network connections

## Resources

- [Runestone Documentation](https://docs.runestone.app)
- [Runestone GitHub](https://github.com/simonbs/Runestone)
- [TreeSitterLanguages GitHub](https://github.com/simonbs/TreeSitterLanguages)
- [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/)
- [Adding a Tree-sitter Language](https://docs.runestone.app/documentation/runestone/addingatreesitterlanguage/)

## Next Steps

After adding these packages:

1. Create `RunestoneEditorView.swift` wrapper for SwiftUI integration
2. Implement language detection based on file extensions
3. Configure themes for syntax highlighting (adapt from existing Theme model)
4. Create a language provider service
5. Test with various file types
6. Implement language-specific features (code folding, indentation, etc.)

## Version Compatibility

| Component | Minimum Version | Recommended |
|-----------|-----------------|-------------|
| iOS/iPadOS | 14.0 | 16.0+ |
| Xcode | 14.0 | 15.0+ |
| Swift | 5.0 | 5.9+ |
| Runestone | 0.5.0 | 0.5.1 |
| TreeSitterLanguages | 0.1.0 | 0.1.10 |

---

*Last Updated: 2025-01-19*
*Document Version: 2.0*
