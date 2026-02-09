import SwiftUI

struct HoverInfoView: View {
    @ObservedObject var manager = HoverInfoManager.shared
    
    var body: some View {
        Group {
            if manager.isVisible, let info = manager.currentInfo {
                VStack(alignment: .leading, spacing: 8) {
                    // Header: Signature and Type
                    HStack(alignment: .top) {
                        Text(info.signature)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        if let typeInfo = info.typeInfo {
                            Text(typeInfo)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.3))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Documentation Body (Markdown)
                    ScrollView {
                        Text(.init(info.documentation))
                            .font(.callout)
                            .foregroundColor(Color(white: 0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(12)
                .frame(width: 320)
                .background(Color(UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0)))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                // Position the popup
                .position(x: manager.position.x, y: manager.position.y)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .onTapGesture {
                    // Prevent tap from passing through
                }
                .onAppear {
                    // Setup keyboard handling if needed, though usually handled by parent
                }
            }
        }
    }
}

// MARK: - Preview
struct HoverInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            HoverInfoView()
                .onAppear {
                    HoverInfoManager.shared.showHover(
                        for: "print",
                        at: CGPoint(x: 200, y: 300)
                    )
                }
        }
    }
}
