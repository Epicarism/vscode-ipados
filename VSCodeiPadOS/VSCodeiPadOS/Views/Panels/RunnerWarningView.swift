import SwiftUI

struct RunnerWarningView: View {
    let languageId: String
    @Binding var isPresented: Bool
    @Binding var dontShowAgain: Bool
    let onConfigureSSH: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unsupported Local Runner")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Text("You are trying to run a \(languageId) file locally.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("Due to iOS system restrictions, only JavaScript code can be executed directly on-device. Other languages require a remote environment.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 8) {
                Text("Suggestion:")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                
                HStack {
                    Image(systemName: "server.rack")
                        .foregroundColor(.blue)
                    Text("Use SSH Remote Execution to run code on a remote server or container.")
                        .font(.caption)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Toggle("Don't show this again", isOn: $dontShowAgain)
                .font(.subheadline)
                .padding(.horizontal, 40)
            
            HStack(spacing: 16) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    isPresented = false
                    onConfigureSSH()
                }) {
                    HStack {
                        Image(systemName: "terminal.fill")
                        Text("Configure SSH")
                    }
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

// Preview for development
struct RunnerWarningView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.5).ignoresSafeArea()
            RunnerWarningView(
                languageId: "Python",
                isPresented: .constant(true),
                dontShowAgain: .constant(false),
                onConfigureSSH: {}
            )
        }
    }
}
