import SwiftUI

struct JSONNode: Identifiable {
    let id = UUID()
    let key: String
    let value: Any?
    var children: [JSONNode]?
    var isArray: Bool
}

struct JSONTreeView: View {
    let data: Data
    @State private var rootNodes: [JSONNode] = []
    @State private var error: String? = nil

    init(data: Data) {
        self.data = data
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                if let error = error {
                    Text("Error parsing JSON: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ForEach(rootNodes) { node in
                        JSONNodeView(node: node)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(UIColor.systemBackground))
        .onAppear { parseJSON() }
        .onChange(of: data) { _ in parseJSON() }
    }

    private func parseJSON() {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            rootNodes = parseRoot(json: json)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func parseRoot(json: Any) -> [JSONNode] {
        if let dict = json as? [String: Any] {
            return dict.sorted(by: { $0.key < $1.key }).map { createNode(key: $0.key, value: $0.value) }
        } else if let array = json as? [Any] {
            return array.enumerated().map { createNode(key: "[\($0.offset)]", value: $0.element) }
        } else {
            return [createNode(key: "root", value: json)]
        }
    }
    
    private func createNode(key: String, value: Any) -> JSONNode {
        if let dict = value as? [String: Any] {
            let children = dict.sorted(by: { $0.key < $1.key }).map { createNode(key: $0.key, value: $0.value) }
            return JSONNode(key: key, value: nil, children: children, isArray: false)
        } else if let array = value as? [Any] {
            let children = array.enumerated().map { createNode(key: "[\($0.offset)]", value: $0.element) }
            return JSONNode(key: key, value: nil, children: children, isArray: true)
        } else {
            return JSONNode(key: key, value: value, children: nil, isArray: false)
        }
    }
}

struct JSONNodeView: View {
    let node: JSONNode
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 4) {
                if node.children != nil {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .frame(width: 12, height: 12)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer().frame(width: 12)
                }
                
                Text(node.key)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.blue)
                
                Text(":")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                if let value = node.value {
                    valueView(for: value)
                } else if let children = node.children {
                    if !isExpanded {
                        Text(node.isArray ? "[\(children.count)]" : "{...}")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = true
                                }
                            }
                    }
                }
            }
            
            if isExpanded, let children = node.children {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(children) { child in
                        JSONNodeView(node: child)
                    }
                }
                .padding(.leading, 16)
                .overlay(
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1)
                        .padding(.leading, 5),
                    alignment: .leading
                )
            }
        }
    }
    
    @ViewBuilder
    func valueView(for value: Any) -> some View {
        if let stringValue = value as? String {
            Text("\"\(stringValue)\"")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.orange)
                .lineLimit(1)
        } else if let boolValue = value as? Bool {
            Text(boolValue ? "true" : "false")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.purple)
        } else if let numberValue = value as? NSNumber {
            Text("\(numberValue)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.green)
        } else if value is NSNull {
            Text("null")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.red)
        } else {
            Text("\(String(describing: value))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}