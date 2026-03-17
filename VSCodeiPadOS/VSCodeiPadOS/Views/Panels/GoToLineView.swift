import SwiftUI

struct GoToLineView: View {
    @Binding var isPresented: Bool
    @State private var lineNumberText = ""
    let onGoToLine: (Int) -> Void
    var maxLine: Int = .max

    private var isValidLine: Bool {
        guard let lineNumber = Int(lineNumberText) else { return false }
        return lineNumber > 0 && lineNumber <= maxLine
    }

    private var parsedLineNumber: Int? {
        let parsed = Int(lineNumberText)
        guard let line = parsed, line > 0 else { return nil }
        return min(line, maxLine)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Go to Line")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                TextField("Line number (1–\(maxLine))", text: $lineNumberText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .accessibilityLabel("Line number")
                    .accessibilityHint("Enter a line number between 1 and \(maxLine)")

                if !lineNumberText.isEmpty && !isValidLine {
                    let parsed = Int(lineNumberText)
                    if parsed == nil || parsed! <= 0 {
                        Text("Please enter a valid positive number")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("Line number must be between 1 and \(maxLine)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Dismiss go to line dialog")

                    Button("Go") {
                        if let lineNumber = parsedLineNumber {
                            onGoToLine(lineNumber)
                            isPresented = false
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(!isValidLine)
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
