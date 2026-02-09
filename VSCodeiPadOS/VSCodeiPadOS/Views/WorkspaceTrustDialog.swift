import SwiftUI

struct WorkspaceTrustDialog: View {
    let workspaceURL: URL
    let onTrust: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkerboard")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Do you trust the authors of the files in this folder?")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(workspaceURL.lastPathComponent)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            
            Text("Code in this folder may be executed by tasks, debugging, or extensions. Trusting this folder allows full access to all features.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Don't Trust")
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: onTrust) {
                    Text("Trust Folder")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 20)
        .frame(maxWidth: 400)
    }
}
