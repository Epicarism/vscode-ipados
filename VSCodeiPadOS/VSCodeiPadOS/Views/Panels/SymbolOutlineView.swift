//
//  SymbolOutlineView.swift
//  VSCodeiPadOS
//
//  Document symbol outline panel with search, grouping, and tap-to-navigate.
//  Consumes symbols from TreeSitterSymbolProvider.
//

import SwiftUI

struct SymbolOutlineView: View {
    @ObservedObject var symbolProvider = TreeSitterSymbolProvider.shared
    @State private var searchText = ""
    @State private var groupByKind = true
    @State private var expandedKinds: Set<DocumentSymbolKind> = Set(DocumentSymbolKind.allCases)
    
    let onNavigateToLine: ((Int) -> Void)?
    
    init(onNavigateToLine: ((Int) -> Void)? = nil) {
        self.onNavigateToLine = onNavigateToLine
    }
    
    private var filteredSymbols: [DocumentSymbol] {
        if searchText.isEmpty {
            return symbolProvider.symbols
        }
        let query = searchText.lowercased()
        return symbolProvider.symbols.filter {
            $0.name.lowercased().contains(query)
        }
    }
    
    private var groupedSymbols: [(DocumentSymbolKind, [DocumentSymbol])] {
        let dict = Dictionary(grouping: filteredSymbols) { $0.kind }
        return dict.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "list.bullet.indent")
                    .foregroundColor(.secondary)
                Text("Outline")
                    .font(.headline)
                Spacer()
                Button {
                    groupByKind.toggle()
                } label: {
                    Image(systemName: groupByKind ? "list.bullet.below.rectangle" : "list.bullet")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                TextField("Filter symbols…", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(.caption, design: .monospaced))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            
            Divider()
            
            // Content
            if symbolProvider.isProcessing {
                VStack {
                    ProgressView()
                    Text("Analyzing…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredSymbols.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No symbols found" : "No matching symbols")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if groupByKind {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedSymbols, id: \.0) { kind, symbols in
                            symbolGroupSection(kind: kind, symbols: symbols)
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredSymbols) { symbol in
                            symbolRow(symbol)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func symbolGroupSection(kind: DocumentSymbolKind, symbols: [DocumentSymbol]) -> some View {
        Button {
            if expandedKinds.contains(kind) {
                expandedKinds.remove(kind)
            } else {
                expandedKinds.insert(kind)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: expandedKinds.contains(kind) ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 12)
                Image(systemName: kind.icon)
                    .font(.caption)
                    .foregroundColor(colorForKind(kind))
                    .frame(width: 16)
                Text(kindDisplayName(kind))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("(\(symbols.count))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6).opacity(0.5))
        }
        .buttonStyle(.plain)
        
        if expandedKinds.contains(kind) {
            ForEach(symbols) { symbol in
                symbolRow(symbol, indented: true)
            }
        }
    }
    
    private func symbolRow(_ symbol: DocumentSymbol, indented: Bool = false) -> some View {
        Button {
            navigateToSymbol(symbol)
        } label: {
            HStack(spacing: 6) {
                if indented {
                    Spacer().frame(width: 16)
                }
                Image(systemName: symbol.kind.icon)
                    .font(.caption)
                    .foregroundColor(colorForKind(symbol.kind))
                    .frame(width: 16)
                Text(symbol.name)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if let detail = symbol.detail {
                    Text(detail)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text("L\(symbol.line)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private func navigateToSymbol(_ symbol: DocumentSymbol) {
        if let navigate = onNavigateToLine {
            navigate(symbol.line)
        } else {
            NotificationCenter.default.post(
                name: .navigateToLine,
                object: nil,
                userInfo: ["line": symbol.line]
            )
        }
    }
    
    private func colorForKind(_ kind: DocumentSymbolKind) -> Color {
        switch kind {
        case .class, .struct:           return .blue
        case .enum:                     return .purple
        case .interface, .protocol:     return .teal
        case .function, .method:        return .yellow
        case .property, .variable:      return .cyan
        case .constant:                 return .orange
        case .constructor:              return .pink
        case .module:                   return .green
        case .type:                     return .mint
        }
    }
    
    private func kindDisplayName(_ kind: DocumentSymbolKind) -> String {
        switch kind {
        case .class:       return "Classes"
        case .struct:      return "Structs"
        case .enum:        return "Enums"
        case .interface:   return "Interfaces"
        case .protocol:    return "Protocols"
        case .function:    return "Functions"
        case .method:      return "Methods"
        case .property:    return "Properties"
        case .variable:    return "Variables"
        case .constant:    return "Constants"
        case .constructor: return "Constructors"
        case .module:      return "Modules"
        case .type:        return "Types"
        }
    }
}
