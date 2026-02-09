import SwiftUI

public enum MergeConflictAction {
    case acceptCurrent
    case acceptIncoming
    case acceptBoth
}

public struct MergeConflictView: View {
    let currentChange: String
    let incomingChange: String
    let onAction: (MergeConflictAction) -> Void
    
    public init(currentChange: String, incomingChange: String, onAction: @escaping (MergeConflictAction) -> Void) {
        self.currentChange = currentChange
        self.incomingChange = incomingChange
        self.onAction = onAction
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Action Header
            HStack {
                Text("Merge Conflict")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    actionButton(title: "Accept Current", action: .acceptCurrent)
                    actionButton(title: "Accept Incoming", action: .acceptIncoming)
                    actionButton(title: "Accept Both", action: .acceptBoth)
                }
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            
            // Conflict Body
            VStack(spacing: 0) {
                // Current Change
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("<<<<<<< Current")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.15))
                    
                    Text(currentChange)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.blue.opacity(0.05))
                }
                
                // Divider Marker
                HStack {
                    Text("=======")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(UIColor.tertiarySystemBackground))
                
                // Incoming Change
                VStack(alignment: .leading, spacing: 0) {
                    Text(incomingChange)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.green.opacity(0.05))
                    
                    HStack {
                        Text(">>>>>>> Incoming")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                }
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func actionButton(title: String, action: MergeConflictAction) -> some View {
        Button(action: { onAction(action) }) {
            Text(title)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
    }
}