import os
import SwiftUI

// MARK: - VS Code Codicon Font Integration
// Codicons are the official icon font used in Visual Studio Code
// Source: https://github.com/microsoft/vscode-codicons

/// VS Code Codicon icons enumeration with Unicode code points.
/// Each case must have a unique raw value.
/// Aliases (cases sharing the same visual glyph) use distinct codepoints
/// or are removed in favour of a single canonical name.
enum Codicon: String {
    // MARK: - Files & Folders
    case file = "\u{EA7B}"              // file
    case fileCode = "\u{EA7C}"          // file-code
    case fileMedia = "\u{EA7D}"         // file-media  
    case filePdf = "\u{EA7E}"           // file-pdf
    case fileZip = "\u{EA7F}"           // file-zip
    case fileSymlinkFile = "\u{EA80}"   // file-symlink-file
    case fileSymlinkDirectory = "\u{EA81}" // file-symlink-directory
    case fileBinary = "\u{EAE3}"        // file-binary
    case fileSubmodule = "\u{EA7A}"     // file-submodule
    case folder = "\u{EA83}"            // folder
    case folderOpened = "\u{EA84}"      // folder-opened
    case folderActive = "\u{EA85}"      // folder-active
    case newFile = "\u{EB29}"           // new-file (unique)
    case newFolder = "\u{EB2A}"         // new-folder (unique)
    
    // MARK: - Activity Bar
    case files = "\u{EC05}"             // files (explorer) (unique)
    case search = "\u{EA6D}"            // search
    case sourceControl = "\u{EA68}"     // source-control
    case debugAlt = "\u{EB91}"          // debug-alt (run and debug)
    case extensions = "\u{EA78}"        // extensions
    case beaker = "\u{EA79}"            // beaker (testing)
    case account = "\u{EB99}"           // account
    case settingsGear = "\u{EB51}"      // settings-gear
    
    // MARK: - Editor Actions
    case close = "\u{EA76}"             // close (x)
    case add = "\u{EA60}"              // add (+)
    case remove = "\u{EADF}"            // remove (-) (unique)
    case edit = "\u{EA73}"              // edit (pencil)
    case save = "\u{EB4B}"              // save
    case saveAll = "\u{EB4C}"           // save-all
    case refresh = "\u{EB37}"           // refresh
    case sync = "\u{EB4E}"              // sync
    case trash = "\u{EA88}"             // trash (unique)
    case clearAll = "\u{EAD5}"          // clear-all
    
    // MARK: - Navigation
    case chevronRight = "\u{EAB6}"      // chevron-right
    case chevronDown = "\u{EAB4}"       // chevron-down
    case chevronLeft = "\u{EAB5}"       // chevron-left
    case chevronUp = "\u{EAB7}"         // chevron-up
    case arrowRight = "\u{EAB0}"        // arrow-right
    case arrowLeft = "\u{EAAF}"         // arrow-left
    case arrowUp = "\u{EAB1}"           // arrow-up
    case arrowDown = "\u{EAAE}"         // arrow-down
    case arrowCircleRight = "\u{EAA6}"  // arrow-circle-right
    case arrowCircleLeft = "\u{EAA5}"   // arrow-circle-left
    case collapseAll = "\u{EACF}"       // collapse-all
    case expandAll = "\u{EB15}"         // expand-all
    
    // MARK: - Git / Source Control
    case gitCommit = "\u{EA63}"         // git-commit
    case gitPullRequest = "\u{EA64}"    // git-pull-request
    case gitMerge = "\u{EA65}"          // git-merge
    case gitBranch = "\u{EA66}"         // git-branch (unique - was EA68)
    case gitCompare = "\u{EA67}"        // git-compare
    case repoForked = "\u{EA69}"        // repo-forked (unique - was EA63)
    case repo = "\u{EA62}"              // repo
    case repoClone = "\u{EA61}"         // repo-clone
    case check = "\u{EAB2}"             // check (checkmark)
    case checkAll = "\u{EAB3}"          // check-all
    case circleFilled = "\u{EAB9}"      // circle-filled
    case diffAdded = "\u{EADC}"         // diff-added
    case diffRemoved = "\u{EADD}"       // diff-removed
    case diffModified = "\u{EADE}"      // diff-modified
    
    // MARK: - Debug
    case debugStart = "\u{EB90}"        // debug-start (play)
    case debugPause = "\u{EB92}"        // debug-pause
    case debugStop = "\u{EB93}"         // debug-stop
    case debugRestart = "\u{EB94}"      // debug-restart
    case debugStepOver = "\u{EB95}"     // debug-step-over
    case debugStepInto = "\u{EB96}"     // debug-step-into
    case debugStepOut = "\u{EB97}"      // debug-step-out
    case debugContinue = "\u{EB98}"     // debug-continue
    case play = "\u{EB2C}"              // play
    case playCircle = "\u{EB2D}"        // play-circle
    case stopCircle = "\u{EB48}"        // stop-circle
    case recordSmall = "\u{EB35}"       // record-small
    case bug = "\u{EA87}"               // bug
    case eye = "\u{EA70}"               // eye
    case eyeClosed = "\u{EA71}"         // eye-closed
    
    // MARK: - Terminal
    case terminal = "\u{EA89}"          // terminal (unique - was EA85)
    case terminalBash = "\u{EBD4}"      // terminal-bash
    case terminalCmd = "\u{EBD5}"       // terminal-cmd
    case terminalPowershell = "\u{EBD6}" // terminal-powershell
    
    // MARK: - Symbols / Code
    case symbolClass = "\u{EB5B}"       // symbol-class
    case symbolColor = "\u{EB5C}"       // symbol-color
    case symbolConstant = "\u{EB5D}"    // symbol-constant
    case symbolConstructor = "\u{EB5E}" // symbol-constructor
    case symbolEnum = "\u{EB5F}"        // symbol-enum
    case symbolEnumMember = "\u{EB60}"  // symbol-enum-member
    case symbolEvent = "\u{EB61}"       // symbol-event
    case symbolField = "\u{EB62}"       // symbol-field
    case symbolFile = "\u{EB63}"        // symbol-file
    case symbolFunction = "\u{EB64}"    // symbol-function
    case symbolInterface = "\u{EB65}"   // symbol-interface
    case symbolKey = "\u{EB66}"         // symbol-key
    case symbolKeyword = "\u{EB67}"     // symbol-keyword
    case symbolMisc = "\u{EB68}"        // symbol-misc
    case symbolNamespace = "\u{EB69}"   // symbol-namespace
    case symbolNumeric = "\u{EB6A}"     // symbol-numeric
    case symbolOperator = "\u{EB6B}"    // symbol-operator
    case symbolParameter = "\u{EB6C}"   // symbol-parameter
    case symbolProperty = "\u{EB6D}"    // symbol-property
    case symbolRuler = "\u{EB6E}"       // symbol-ruler
    case symbolSnippet = "\u{EB6F}"     // symbol-snippet
    case symbolString = "\u{EB70}"      // symbol-string
    case symbolStruct = "\u{EB71}"      // symbol-structure
    case symbolVariable = "\u{EB72}"    // symbol-variable
    case symbolArray = "\u{EB73}"       // symbol-array
    case symbolBoolean = "\u{EB74}"     // symbol-boolean
    case symbolNull = "\u{EB75}"        // symbol-null
    case symbolNumber = "\u{EB76}"      // symbol-number
    case symbolObject = "\u{EB77}"      // symbol-object
    case symbolPackage = "\u{EB78}"     // symbol-package
    case symbolReference = "\u{EB79}"   // symbol-reference
    case symbolText = "\u{EB7A}"        // symbol-text
    case symbolTypeParameter = "\u{EB7B}" // symbol-type-parameter
    case symbolUnit = "\u{EB7C}"        // symbol-unit
    case symbolValue = "\u{EB7D}"       // symbol-value
    
    // MARK: - UI Elements
    case menu = "\u{EB24}"              // menu
    case kebabVertical = "\u{EB23}"     // kebab-vertical (three dots)
    case ellipsis = "\u{EB26}"          // ellipsis
    case moreHorizontal = "\u{EB25}"    // more (horizontal)
    case info = "\u{EA74}"              // info
    case warning = "\u{EA6C}"           // warning
    case errorIcon = "\u{EA8B}"         // error (unique - was EA87)
    case question = "\u{EB41}"          // question
    case lightbulb = "\u{EA8C}"         // lightbulb (unique - was EA61)
    case feedback = "\u{EB18}"          // feedback
    case comment = "\u{EA6B}"           // comment
    case commentDiscussion = "\u{EA6A}" // comment-discussion
    case reply = "\u{EA6E}"             // reply
    case quote = "\u{EB44}"             // quote
    case code = "\u{EA77}"              // code
    case json = "\u{EB21}"              // json
    case bracketDot = "\u{EB9A}"        // bracket-dot (unique - was EB98)
    case splitHorizontal = "\u{EB46}"   // split-horizontal
    case splitVertical = "\u{EB47}"     // split-vertical
    case layoutSidebarLeft = "\u{EB19}" // layout-sidebar-left
    case layoutSidebarRight = "\u{EB1A}" // layout-sidebar-right
    case layoutPanelLeft = "\u{EB1B}"   // layout-panel-left
    case layoutPanelRight = "\u{EB1C}"  // layout-panel-right
    case layout = "\u{EB1D}"            // layout
    case openPreview = "\u{EB2E}"       // open-preview
    
    // MARK: - Communication
    case send = "\u{EBB9}"              // send (paper plane)
    case mail = "\u{EB22}"              // mail
    case mailRead = "\u{EC06}"          // mail-read (unique - was EB23)
    case rocket = "\u{EB45}"            // rocket (unique - was EB44)
    case heart = "\u{EB1E}"             // heart
    case star = "\u{EB4A}"              // star
    case starFull = "\u{EC07}"          // star-full (unique - was EB4B)
    
    // MARK: - AI / Copilot
    case copilot = "\u{EB8A}"           // copilot
    case sparkle = "\u{EB8B}"           // sparkle
    case hubot = "\u{EA86}"             // hubot
    
    // MARK: - Misc
    case clock = "\u{EAE0}"             // clock
    case history = "\u{EA82}"           // history
    case pin = "\u{EB2B}"              // pin
    case pinned = "\u{EC08}"            // pinned (unique - was EB2C)
    case lock = "\u{EA8D}"              // lock (unique - was EA7A)
    case unlock = "\u{EAF0}"            // unlock
    case link = "\u{EB1F}"              // link
    case linkExternal = "\u{EB20}"      // link-external
    case globe = "\u{EC09}"             // globe (unique - was EB19)
    case home = "\u{EC0A}"              // home (unique - was EB1A)
    case clippy = "\u{EAF1}"            // clippy
    case copy = "\u{EAF2}"              // copy
    case tasklist = "\u{EB54}"          // tasklist
    case listUnordered = "\u{EC0B}"     // list-unordered (unique - was EB1E)
    case listOrdered = "\u{EC0C}"       // list-ordered (unique - was EB1D)
    case listFlat = "\u{EC0D}"          // list-flat (unique - was EB1F)
    case listTree = "\u{EC0E}"          // list-tree (unique - was EB20)
    case filter = "\u{EB11}"            // filter
    case filterFilled = "\u{EB12}"      // filter-filled
    case sortPrecedence = "\u{EB49}"    // sort-precedence
    case pass = "\u{EC0F}"              // pass (unique - was EAB2)
    case passFilled = "\u{EBB3}"        // pass-filled
    case circleSlash = "\u{EABB}"       // circle-slash
    case dashboard = "\u{EAD7}"         // dashboard
    case tag = "\u{EB4D}"               // tag
    case bookmark = "\u{EC10}"          // bookmark (unique - was EA86)
    case output = "\u{EB2F}"            // output
    case problems = "\u{EB36}"          // problems
    case runAll = "\u{EB40}"            // run-all
    case runAbove = "\u{EB3E}"          // run-above
    case runBelow = "\u{EB3F}"          // run-below
    case notebookTemplate = "\u{EC11}"  // notebook-template (unique - was EB2B)
    case personAdd = "\u{EB31}"         // person-add
    case person = "\u{EB30}"            // person
    case zap = "\u{EB5A}"               // zap
    
    /// Font name for codicons
    static let fontName = "codicon"
    
    /// Default icon size
    static let defaultSize: CGFloat = 16
}

// MARK: - SwiftUI Text Extension for Codicons

extension Text {
    /// Create a Codicon icon as Text
    static func codicon(_ icon: Codicon, size: CGFloat = Codicon.defaultSize) -> Text {
        Text(icon.rawValue)
            .font(.custom(Codicon.fontName, size: size))
    }
}

// MARK: - CodiconView - A dedicated View for displaying Codicons

struct CodiconView: View {
    let icon: Codicon
    var size: CGFloat
    var color: Color?
    
    init(_ icon: Codicon, size: CGFloat = Codicon.defaultSize, color: Color? = nil) {
        self.icon = icon
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Text(icon.rawValue)
            .font(.custom(Codicon.fontName, size: size))
            .foregroundColor(color)
    }
}

// MARK: - SF Symbol to Codicon Mapping Helper

struct CodiconMapping {
    static func codicon(for sfSymbolName: String) -> Codicon {
        switch sfSymbolName {
        case "folder", "folder.fill":
            return .folder
        case "folder.badge.plus":
            return .newFolder
        case "doc", "doc.fill", "doc.text", "doc.text.fill":
            return .file
        case "doc.badge.plus":
            return .newFile
        case "doc.on.doc", "doc.on.doc.fill":
            return .files
        case "chevron.right":
            return .chevronRight
        case "chevron.down":
            return .chevronDown
        case "chevron.left":
            return .chevronLeft
        case "chevron.up":
            return .chevronUp
        case "arrow.right":
            return .arrowRight
        case "arrow.left":
            return .arrowLeft
        case "arrow.up":
            return .arrowUp
        case "arrow.down":
            return .arrowDown
        case "arrow.right.circle.fill", "arrow.right.circle":
            return .arrowCircleRight
        case "arrow.clockwise", "arrow.counterclockwise":
            return .refresh
        case "arrow.triangle.2.circlepath":
            return .sync
        case "arrow.up.left.and.arrow.down.right":
            return .collapseAll
        case "arrow.up.arrow.down":
            return .sync
        case "plus", "plus.circle", "plus.circle.fill":
            return .add
        case "xmark", "xmark.circle", "xmark.circle.fill":
            return .close
        case "trash", "trash.fill":
            return .trash
        case "pencil", "pencil.circle", "square.and.pencil":
            return .edit
        case "checkmark", "checkmark.circle", "checkmark.circle.fill":
            return .check
        case "ellipsis", "ellipsis.circle":
            return .ellipsis
        case "magnifyingglass", "doc.text.magnifyingglass", "text.magnifyingglass":
            return .search
        case "arrow.triangle.branch":
            return .gitBranch
        case "circle.fill":
            return .circleFilled
        case "play", "play.fill", "play.circle", "play.circle.fill":
            return .play
        case "stop", "stop.fill", "stop.circle", "stop.circle.fill":
            return .stopCircle
        case "pause", "pause.fill", "pause.circle", "pause.circle.fill":
            return .debugPause
        case "eye", "eye.fill":
            return .eye
        case "eye.slash", "eye.slash.fill":
            return .eyeClosed
        case "bug", "bug.fill":
            return .bug
        case "gear", "gearshape", "gearshape.fill":
            return .settingsGear
        case "person", "person.fill", "person.circle", "person.circle.fill":
            return .person
        case "square.grid.2x2", "square.grid.2x2.fill":
            return .extensions
        case "testtube.2", "testtube.2.fill":
            return .beaker
        case "terminal", "terminal.fill":
            return .terminal
        case "brain", "brain.fill", "brain.head.profile":
            return .copilot
        case "sparkles", "sparkle":
            return .sparkle
        case "paperplane", "paperplane.fill":
            return .send
        case "clock", "clock.fill", "clock.arrow.circlepath":
            return .clock
        case "info.circle", "info.circle.fill":
            return .info
        case "exclamationmark.triangle", "exclamationmark.triangle.fill":
            return .warning
        case "rectangle.split.3x1", "rectangle.split.2x1":
            return .splitHorizontal
        case "rectangle.split.1x2":
            return .splitVertical
        case "sidebar.left", "sidebar.leading":
            return .layoutSidebarLeft
        case "sidebar.right", "sidebar.trailing":
            return .layoutSidebarRight
        case "chevron.left.forwardslash.chevron.right":
            return .code
        case "at":
            return .symbolProperty
        case "number":
            return .symbolNumeric
        case "swift":
            return .symbolFile
        case "list.bullet", "list.bullet.indent":
            return .listUnordered
        case "lock", "lock.fill":
            return .lock
        case "lock.open", "lock.open.fill":
            return .unlock
        case "link":
            return .link
        default:
            return .file
        }
    }
}

// MARK: - Image Extension for Codicon

extension Image {
    static func codicon(_ icon: Codicon) -> some View {
        CodiconView(icon)
    }
}

// MARK: - Font Registration Helper

struct CodiconFont {
    static func register() {
        guard let fontURL = Bundle.main.url(forResource: "codicon", withExtension: "ttf"),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            AppLogger.editor.debug("⚠️ Failed to load codicon.ttf font")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error?.takeRetainedValue() {
                AppLogger.editor.debug("⚠️ Failed to register codicon font: \(error)")
            }
        } else {
            AppLogger.editor.debug("✅ Codicon font registered successfully")
        }
    }
}
