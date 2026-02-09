import SwiftUI

struct SettingsView: View {
    @AppStorage("fontSize") private var fontSize: Double = 14
    @AppStorage("theme") private var theme: String = "dark"
    @AppStorage("showLineNumbers") private var showLineNumbers: Bool = true
    @AppStorage("wordWrap") private var wordWrap: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Editor") {
                    HStack {
                        Text("Font Size")
                        Slider(value: $fontSize, in: 10...24, step: 1)
                        Text("\(Int(fontSize))")
                            .monospacedDigit()
                            .frame(width: 30)
                    }
                    
                    Picker("Theme", selection: $theme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                    }
                    
                    Toggle("Show Line Numbers", isOn: $showLineNumbers)
                    Toggle("Word Wrap", isOn: $wordWrap)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
