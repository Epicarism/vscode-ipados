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
                
                TextField("Line number", text: $lineNumberText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    
                    Button("Go") {
                        if let lineNumber = Int(lineNumberText), lineNumber > 0 {
                            onGoToLine(lineNumber)
                            isPresented = false
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(Int(lineNumberText) == nil || Int(lineNumberText) ?? 0 <= 0)
                }
                .padding()
                
                Spacer()
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
    }
}
