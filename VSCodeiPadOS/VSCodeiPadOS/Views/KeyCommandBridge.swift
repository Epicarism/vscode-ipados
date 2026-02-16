import UIKit
import SwiftUI

class KeyCommandController: UIViewController {
    
    override var canBecomeFirstResponder: Bool { true }
    
    override var keyCommands: [UIKeyCommand]? {
        let defs: [(String, String, UIKeyModifierFlags, Selector)] = [
            ("Command Palette", "p", [.command, .shift], #selector(cmdPalette)),
            ("AI Assistant", "a", [.command, .shift], #selector(cmdAIAssistant)),
            ("Toggle Terminal", "j", [.command], #selector(cmdToggleTerminal)),
            ("Toggle Sidebar", "b", [.command], #selector(cmdToggleSidebar)),
            ("Quick Open", "p", [.command], #selector(cmdQuickOpen)),
            ("New File", "n", [.command], #selector(cmdNewFile)),
            ("Save", "s", [.command], #selector(cmdSave)),
            ("Close Tab", "w", [.command], #selector(cmdCloseTab)),
            ("Find", "f", [.command], #selector(cmdFind)),
            ("Go to Line", "g", [.control], #selector(cmdGoToLine)),
            ("Zoom In", "=", [.command], #selector(cmdZoomIn)),
            ("Zoom Out", "-", [.command], #selector(cmdZoomOut)),
        ]
        return defs.map { (title, input, mods, action) in
            let cmd = UIKeyCommand(title: title, action: action, input: input, modifierFlags: mods)
            cmd.wantsPriorityOverSystemBehavior = true
            return cmd
        }
    }
    
    @objc func cmdPalette() {
        NotificationCenter.default.post(name: .init("ShowCommandPalette"), object: nil)
    }
    @objc func cmdAIAssistant() {
        NotificationCenter.default.post(name: .init("ShowAIAssistant"), object: nil)
    }
    @objc func cmdToggleTerminal() {
        NotificationCenter.default.post(name: .init("ToggleTerminal"), object: nil)
    }
    @objc func cmdToggleSidebar() {
        NotificationCenter.default.post(name: .init("ToggleSidebar"), object: nil)
    }
    @objc func cmdQuickOpen() {
        NotificationCenter.default.post(name: .init("ShowQuickOpen"), object: nil)
    }
    @objc func cmdNewFile() {
        NotificationCenter.default.post(name: .init("NewFile"), object: nil)
    }
    @objc func cmdSave() {
        NotificationCenter.default.post(name: .init("SaveFile"), object: nil)
    }
    @objc func cmdCloseTab() {
        NotificationCenter.default.post(name: .init("CloseTab"), object: nil)
    }
    @objc func cmdFind() {
        NotificationCenter.default.post(name: .init("ShowFind"), object: nil)
    }
    @objc func cmdGoToLine() {
        NotificationCenter.default.post(name: .init("ShowGoToLine"), object: nil)
    }
    @objc func cmdZoomIn() {
        NotificationCenter.default.post(name: .init("ZoomIn"), object: nil)
    }
    @objc func cmdZoomOut() {
        NotificationCenter.default.post(name: .init("ZoomOut"), object: nil)
    }
}

struct KeyCommandBridge<Content: View>: UIViewControllerRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> KeyCommandController {
        let controller = KeyCommandController()
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        controller.addChild(host)
        controller.view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
        ])
        host.didMove(toParent: controller)
        return controller
    }
    
    func updateUIViewController(_ vc: KeyCommandController, context: Context) {
        if let host = vc.children.first as? UIHostingController<Content> {
            host.rootView = content
        }
    }
}
