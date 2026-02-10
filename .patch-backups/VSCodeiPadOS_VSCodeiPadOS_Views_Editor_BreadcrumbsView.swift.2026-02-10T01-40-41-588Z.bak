import SwiftUI

struct BreadcrumbsView: View {
    @ObservedObject var editorCore: EditorCore
    let tab: Tab
    
    var pathComponents: [String] {
        if let url = tab.url {
            // Use standard components
            return url.pathComponents.filter { $0 != "/" }
        }
        return ["VSCodeiPadOS", "Views", tab.fileName]
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                    let isLast = index == pathComponents.count - 1
                    
                    // Breadcrumb item
                    HStack(spacing: 4) {
                        if index == 0 {
                            Image(systemName: "folder")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        } else if isLast {
                            Image(systemName: fileIcon(for: component))
                                .font(.caption2)
                                .foregroundColor(fileColor(for: component))
                        }
                        
                        Text(component)
                            .font(.system(size: 11))
                            .foregroundColor(isLast ? .primary : .secondary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle navigation
                    }
                    
                    // Separator
                    if !isLast {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 2)
                    }
                }
                
                // Current symbol
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.horizontal, 2)
                    
                HStack(spacing: 2) {
                    Image(systemName: "f.curlybraces")
                        .font(.caption2)
                        .foregroundColor(.purple)
                    Text("ContentView")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 26)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
        .overlay(Divider(), alignment: .bottom)
    }
}
