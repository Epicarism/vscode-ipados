import SwiftUI

struct GoToLineView: View {
    @Binding var isPresented: Bool
    @State private var lineNumberText = ""
    let onGoToLine: (Int) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Go to Line")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                TextField("Line number", text: $lineNumberText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .accessibilityLabel("Line number")
                    .accessibilityHint("Enter the line number to navigate to")
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismiss go to line dialog")
                    
                    Button("Go") {
                        if let lineNumber = Int(lineNumberText), lineNumber > 0 {
                            onGoToLine(lineNumber)
                            isPresented = false
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(Int(lineNumberText) == nil || Int(lineNumberText) ?? 0 <= 0)
                    .accessibilityLabel("Go to line")
                    .accessibilityHint("Navigate to the entered line number")
                }
                .padding()
                
                Spacer()
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
    }
}
