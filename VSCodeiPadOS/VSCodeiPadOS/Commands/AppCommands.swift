import Foundation

@objc protocol AppCommands {
    @objc func newFile()
    @objc func openFile()
    @objc func saveFile()
    @objc func toggleSidebar()
    @objc func switchToNextTab()  // Added for Cmd+Tab functionality
}
