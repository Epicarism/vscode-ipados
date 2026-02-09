import SwiftUI

struct DebugView: View {
    @State private var variables: [DebugVariable] = [
        DebugVariable(name: "local", value: "", children: [
            DebugVariable(name: "this", value: "Object"),
            DebugVariable(name: "index", value: "0"),
            DebugVariable(name: "items", value: "Array(5)", children: [
                DebugVariable(name: "[0]", value: "Item"),
                DebugVariable(name: "[1]", value: "Item"),
                DebugVariable(name: "length", value: "2")
            ])
        ]),
        DebugVariable(name: "global", value: "", children: [
            DebugVariable(name: "window", value: "Window")
        ])
    ]
    
    @State private var watchExpressions: [WatchExpression] = []
    @State private var newWatchExpression: String = ""
    @State private var isAddingWatch: Bool = false
    
    // Expanded states for sections
    @State private var isVariablesExpanded: Bool = true
    @State private var isWatchExpanded: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("RUN AND DEBUG")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                        .padding(4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            
            ScrollView {
                VStack(spacing: 0) {
                    // Variables Section
                    DisclosureGroup(isExpanded: $isVariablesExpanded) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(variables) { variable in
                                VariableRow(variable: variable)
                            }
                        }
                        .padding(.leading, 4)
                    } label: {
                        SectionHeader(title: "VARIABLES")
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Watch Section
                    DisclosureGroup(isExpanded: $isWatchExpanded) {
                        VStack(alignment: .leading, spacing: 0) {
                            if watchExpressions.isEmpty && !isAddingWatch {
                                Text("No watch expressions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 4)
                                    .padding(.leading, 12)
                            }
                            
                            ForEach(watchExpressions) { watch in
                                HStack {
                                    Image(systemName: "eye")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(watch.expression)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.primary)
                                    Text(":")
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(watch.value)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.leading, 12)
                            }
                            
                            if isAddingWatch {
                                HStack {
                                    Image(systemName: "eye")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    TextField("Expression...", text: $newWatchExpression, onCommit: {
                                        if !newWatchExpression.isEmpty {
                                            watchExpressions.append(WatchExpression(expression: newWatchExpression, value: "undefined"))
                                            newWatchExpression = ""
                                        }
                                        isAddingWatch = false
                                    })
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .font(.system(size: 12, design: .monospaced))
                                    .padding(4)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(4)
                                }
                                .padding(.vertical, 4)
                                .padding(.leading, 12)
                            }
                            
                            Button(action: { 
                                isAddingWatch = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Expression")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding(.vertical, 4)
                                .padding(.leading, 12)
                            }
                            .opacity(isAddingWatch ? 0 : 1)
                        }
                    } label: {
                        HStack {
                            SectionHeader(title: "WATCH")
                            Spacer()
                            Button(action: { isAddingWatch = true }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .opacity(isWatchExpanded ? 1 : 0)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
    }
}

struct VariableRow: View {
    let variable: DebugVariable
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                if let children = variable.children, !children.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                        }
                        .foregroundColor(.secondary)
                } else {
                    Spacer().frame(width: 16)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(variable.name)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.blue.opacity(0.8))
                    Text(":")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                    Text(variable.value)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.orange.opacity(0.8))
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.vertical, 2)
            
            if isExpanded, let children = variable.children {
                ForEach(children) { child in
                    VariableRow(variable: child)
                        .padding(.leading, 16)
                }
            }
        }
    }
}

struct DebugVariable: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    var children: [DebugVariable]?
}

struct WatchExpression: Identifiable {
    let id = UUID()
    let expression: String
    let value: String
}
