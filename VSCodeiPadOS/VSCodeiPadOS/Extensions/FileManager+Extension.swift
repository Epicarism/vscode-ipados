import Foundation

extension FileManager {
    func documentsDirectory() -> URL {
        urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func createProjectStructure(at url: URL) throws {
        try createDirectory(at: url, withIntermediateDirectories: true)
        
        // Create src directory
        let srcDir = url.appendingPathComponent("src")
        try createDirectory(at: srcDir, withIntermediateDirectories: true)
        
        // Create index.html
        let indexHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>My Project</title>
            <link rel="stylesheet" href="src/style.css">
        </head>
        <body>
            <h1>Welcome to Your Project</h1>
            <script src="src/script.js"></script>
        </body>
        </html>
        """
        try indexHTML.write(to: url.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
        
        // Create style.css
        let styleCSS = """
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 40px;
            background-color: #f5f5f7;
        }
        
        h1 {
            color: #1d1d1f;
        }
        """
        try styleCSS.write(to: srcDir.appendingPathComponent("style.css"), atomically: true, encoding: .utf8)
        
        // Create script.js
        let scriptJS = """
        console.log('Project initialized!');
        
        // Your code here
        """
        try scriptJS.write(to: srcDir.appendingPathComponent("script.js"), atomically: true, encoding: .utf8)
    }
}
