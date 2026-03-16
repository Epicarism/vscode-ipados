//
//  ToolCallParser.swift
//  VSCodeiPadOS
//
//  Universal tool call parser that handles multiple formats:
//  - XML: <tool_call>{"name": "...", "arguments": {...}}</tool_call>
//  - Bracket: [TOOL_CALL]{"tool": "...", "arguments": {...}}[/TOOL_CALL]
//  - Raw JSON blocks with tool/name keys
//

import Foundation
import os

// MARK: - Parsed Tool Call

struct ParsedToolCall {
    let toolName: String
    let arguments: [String: Any]
    let rawJSON: String
    
    var tool: AITool? {
        AITool(rawValue: toolName)
    }
    
    var stringArguments: [String: String] {
        arguments.mapValues { "\($0)" }
    }
}

// MARK: - Tool Call Parser

class ToolCallParser {
    
    /// Parse all tool calls from model response text
    /// Tries multiple formats and returns all found tool calls
    static func parse(_ text: String) -> [ParsedToolCall] {
        var results: [ParsedToolCall] = []
        
        // Try each format in order of specificity
        results.append(contentsOf: parseXMLFormat(text))       // <tool_call>...</tool_call>
        results.append(contentsOf: parseBracketFormat(text))   // [TOOL_CALL]...[/TOOL_CALL]
        
        // If no structured formats found, try raw JSON detection
        if results.isEmpty {
            results.append(contentsOf: parseRawJSON(text))
        }
        
        // Deduplicate based on tool name + arguments
        let unique = deduplicateToolCalls(results)
        
        if unique.isEmpty {
            AppLogger.editor.debug("[ToolCallParser] No tool calls found in response")
        } else {
            AppLogger.editor.debug("[ToolCallParser] Found \(unique.count) tool call(s)")
        }
        
        return unique
    }
    
    // MARK: - XML Format: <tool_call>...</tool_call>
    
    private static func parseXMLFormat(_ text: String) -> [ParsedToolCall] {
        var results: [ParsedToolCall] = []
        
        let patterns = [
            "<tool_call>",      // Standard
            "<tool_call >",     // With space
            "<toolcall>",       // No underscore
            "<function_call>",  // Alternative name
        ]
        
        let endPatterns = [
            "</tool_call>",
            "</tool_call >",
            "</toolcall>",
            "</function_call>",
        ]
        
        for (startTag, endTag) in zip(patterns, endPatterns) {
            results.append(contentsOf: extractBetweenTags(text, start: startTag, end: endTag))
        }
        
        return results
    }
    
    // MARK: - Bracket Format: [TOOL_CALL]...[/TOOL_CALL]
    
    private static func parseBracketFormat(_ text: String) -> [ParsedToolCall] {
        var results: [ParsedToolCall] = []
        
        let patterns = [
            ("[TOOL_CALL]", "[/TOOL_CALL]"),
            ("[tool_call]", "[/tool_call]"),
            ("[FUNCTION_CALL]", "[/FUNCTION_CALL]"),
        ]
        
        for (startTag, endTag) in patterns {
            results.append(contentsOf: extractBetweenTags(text, start: startTag, end: endTag))
        }
        
        return results
    }
    
    // MARK: - Raw JSON Detection
    
    private static func parseRawJSON(_ text: String) -> [ParsedToolCall] {
        var results: [ParsedToolCall] = []
        
        // Find all JSON objects in the text
        var searchStart = text.startIndex
        
        while let braceIndex = text[searchStart...].firstIndex(of: "{") {
            if let jsonStr = extractJSONObject(from: String(text[braceIndex...])) {
                if let parsed = parseJSONToolCall(jsonStr) {
                    results.append(parsed)
                }
                // Move past this JSON object
                if let endIndex = text.index(braceIndex, offsetBy: jsonStr.count, limitedBy: text.endIndex) {
                    searchStart = endIndex
                } else {
                    break
                }
            } else {
                // Move past this brace
                searchStart = text.index(after: braceIndex)
            }
        }
        
        return results
    }
    
    // MARK: - Helpers
    
    private static func extractBetweenTags(_ text: String, start: String, end: String) -> [ParsedToolCall] {
        var results: [ParsedToolCall] = []
        var searchStart = text.startIndex
        
        // Case-insensitive search
        let lowerText = text.lowercased()
        let lowerStart = start.lowercased()
        let lowerEnd = end.lowercased()
        
        while let startRange = lowerText.range(of: lowerStart, range: searchStart..<lowerText.endIndex) {
            let contentStart = startRange.upperBound
            
            guard let endRange = lowerText.range(of: lowerEnd, range: contentStart..<lowerText.endIndex) else {
                break
            }
            
            // Extract from original text (preserve case)
            let originalContentStart = text.index(text.startIndex, offsetBy: lowerText.distance(from: lowerText.startIndex, to: contentStart))
            let originalContentEnd = text.index(text.startIndex, offsetBy: lowerText.distance(from: lowerText.startIndex, to: endRange.lowerBound))
            
            let content = String(text[originalContentStart..<originalContentEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let jsonStr = extractJSONObject(from: content),
               let parsed = parseJSONToolCall(jsonStr) {
                results.append(parsed)
            }
            
            searchStart = endRange.upperBound
        }
        
        return results
    }
    
    /// Extract a complete JSON object handling nested braces
    private static func extractJSONObject(from text: String) -> String? {
        guard let openBrace = text.firstIndex(of: "{") else { return nil }
        
        var depth = 0
        var inString = false
        var escaped = false
        
        for i in text.indices[openBrace...] {
            let char = text[i]
            
            if escaped {
                escaped = false
                continue
            }
            
            if char == "\\" && inString {
                escaped = true
                continue
            }
            
            if char == "\"" {
                inString.toggle()
                continue
            }
            
            if !inString {
                if char == "{" {
                    depth += 1
                } else if char == "}" {
                    depth -= 1
                    if depth == 0 {
                        let endIndex = text.index(after: i)
                        return String(text[openBrace..<endIndex])
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Parse JSON and extract tool call info
    /// Handles both {"name": ...} and {"tool": ...} formats
    private static func parseJSONToolCall(_ jsonStr: String) -> ParsedToolCall? {
        guard let data = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        // Try "name" key first (Nanbeige native), then "tool" key (our format)
        guard let toolName = (json["name"] as? String) ?? (json["tool"] as? String) else {
            return nil
        }
        
        // Validate it's a known tool
        guard AITool(rawValue: toolName) != nil else {
            AppLogger.editor.warning("[ToolCallParser] Unknown tool: \(toolName)")
            return nil
        }
        
        let arguments = json["arguments"] as? [String: Any] ?? [:]
        
        AppLogger.editor.debug("[ToolCallParser] Parsed: \(toolName) with args: \(arguments)")
        
        return ParsedToolCall(toolName: toolName, arguments: arguments, rawJSON: jsonStr)
    }
    
    /// Remove duplicate tool calls (same tool + same arguments)
    private static func deduplicateToolCalls(_ calls: [ParsedToolCall]) -> [ParsedToolCall] {
        var seen = Set<String>()
        var unique: [ParsedToolCall] = []
        
        for call in calls {
            let key = "\(call.toolName):\(call.rawJSON)"
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(call)
            }
        }
        
        return unique
    }
}
