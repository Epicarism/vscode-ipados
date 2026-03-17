import os
import SwiftUI
import Combine

/// Represents the data to be displayed in the hover popup
struct HoverInfo: Equatable, Identifiable {
    let id = UUID()
    let signature: String
    let typeInfo: String?
    let documentation: String
    let range: NSRange?
    let language: String
}

/// Manages the state and data fetching for hover documentation
@MainActor
final class HoverInfoManager: ObservableObject {
    @Published var currentInfo: HoverInfo? = nil
    @Published var isVisible: Bool = false
    @Published var position: CGPoint = .zero
    
    static let shared = HoverInfoManager()
    
    private init() {}
    
    /// Show hover info for a given word at a specific location
    func showHover(for word: String, at point: CGPoint, language: String = "swift") {
        // In a real app, this would be an async call to an LSP or language service
        if let info = fetchMockDocumentation(for: word, language: language) {
            DispatchQueue.main.async {
                self.currentInfo = info
                self.position = point
                self.isVisible = true
            }
        }
    }
    
    /// Hide the hover popup
    func hideHover() {
        DispatchQueue.main.async {
            self.isVisible = false
            self.currentInfo = nil
        }
    }
    
    /// Toggle visibility manually (e.g. via keyboard shortcut)
    func toggleHover() {
        if isVisible {
            hideHover()
        }
    }
    
    // MARK: - Mock Data Service
    
    private func fetchMockDocumentation(for word: String, language: String) -> HoverInfo? {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWord.isEmpty else { return nil }
        
        // Mock dictionary for demonstration
        let swiftDocs: [String: HoverInfo] = [
            // MARK: - Built-in Functions
            "print": HoverInfo(
                signature: "func print(_ items: Any..., separator: String = \" \", terminator: String = \"\\n\")",
                typeInfo: "Standard Library",
                documentation: "Writes the textual representations of the given items into the standard output. Each item is separated by the given separator (default: space), and the output is terminated by the given terminator (default: newline).",
                range: nil,
                language: "swift"
            ),

            // MARK: - Core Types
            "String": HoverInfo(
                signature: "struct String",
                typeInfo: "Swift.String",
                documentation: "A Unicode string value that is a collection of characters. Strings are value types with copy-on-write semantics, and provide methods for searching, manipulating, and comparing text.",
                range: nil,
                language: "swift"
            ),
            "Int": HoverInfo(
                signature: "struct Int : FixedWidthInteger, SignedInteger",
                typeInfo: "Swift.Int",
                documentation: "A signed integer type with platform-dependent bit width. On 64-bit platforms, Int is a 64-bit integer. Use Int for general-purpose integer arithmetic unless you need a specific width.",
                range: nil,
                language: "swift"
            ),
            "Double": HoverInfo(
                signature: "struct Double : FloatingPoint, BinaryFloatingPoint",
                typeInfo: "Swift.Double",
                documentation: "A double-precision, floating-point value type. Double has approximately 15–16 decimal digits of precision and a range of approximately ±1.8×10³⁰⁸. Preferred for most floating-point computations.",
                range: nil,
                language: "swift"
            ),
            "Float": HoverInfo(
                signature: "struct Float : FloatingPoint, BinaryFloatingPoint",
                typeInfo: "Swift.Float",
                documentation: "A single-precision, floating-point value type. Float has approximately 6–9 decimal digits of precision and a range of approximately ±3.4×10³⁸. Use when memory conservation is important.",
                range: nil,
                language: "swift"
            ),
            "Bool": HoverInfo(
                signature: "struct Bool",
                typeInfo: "Swift.Bool",
                documentation: "A type that represents a Boolean value — either true or false. Swift provides several logical operators for Bool values including &&, ||, and !.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Collection Types
            "Array": HoverInfo(
                signature: "struct Array<Element> : RandomAccessCollection, MutableCollection",
                typeInfo: "Swift.Array",
                documentation: "An ordered, random-access collection. Arrays store values of the same type in an ordered list. Supports O(1) index-based access and provides amortized O(1) append operations.",
                range: nil,
                language: "swift"
            ),
            "Dictionary": HoverInfo(
                signature: "struct Dictionary<Key, Value> : Collection where Key : Hashable",
                typeInfo: "Swift.Dictionary",
                documentation: "A collection whose elements are key-value pairs. Dictionaries provide O(1) average lookup, insertion, and removal. Keys must conform to Hashable and each key must be unique.",
                range: nil,
                language: "swift"
            ),
            "Set": HoverInfo(
                signature: "struct Set<Element> : SetAlgebra, Collection where Element : Hashable",
                typeInfo: "Swift.Set",
                documentation: "An unordered collection of unique elements. Sets enforce uniqueness and provide O(1) average membership testing, insertion, and removal. Elements must conform to Hashable.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Enumerations & Protocols
            "Optional": HoverInfo(
                signature: "enum Optional<Wrapped>",
                typeInfo: "Swift.Optional",
                documentation: "A type that represents either a wrapped value or nil, the absence of a value. Use optional chaining (?), optional binding (if let), nil-coalescing (??), or guard let to safely work with optionals.",
                range: nil,
                language: "swift"
            ),
            "Result": HoverInfo(
                signature: "enum Result<Success, Failure> where Failure : Error",
                typeInfo: "Swift.Result",
                documentation: "A value that represents either a success or a failure, including an associated value in each case. Use Result to centralize error handling with a get-or-throw pattern instead of throwing functions.",
                range: nil,
                language: "swift"
            ),
            "Error": HoverInfo(
                signature: "protocol Error",
                typeInfo: "Swift.Error",
                documentation: "An error type that can be thrown. Any type conforming to Error can be used with Swift's error-handling mechanisms: do-catch, try, throws, and defer.",
                range: nil,
                language: "swift"
            ),
            "Codable": HoverInfo(
                signature: "protocol Codable : Encodable, Decodable",
                typeInfo: "Swift.Codable",
                documentation: "A type that can convert itself into and out of an external representation such as JSON or property list. A typealias for Encodable & Decodable, enabling serialization and deserialization.",
                range: nil,
                language: "swift"
            ),
            "Equatable": HoverInfo(
                signature: "protocol Equatable",
                typeInfo: "Swift.Equatable",
                documentation: "A type that can be compared for value equality using the == operator. Conforming types can be used in sets as dictionary keys (if also Hashable) and tested with contains(_:) on collections.",
                range: nil,
                language: "swift"
            ),
            "Hashable": HoverInfo(
                signature: "protocol Hashable : Equatable",
                typeInfo: "Swift.Hashable",
                documentation: "A type that provides a hash value for use in hash-based collections. Conforming types can be used as dictionary keys and stored in sets. Inherits from Equatable.",
                range: nil,
                language: "swift"
            ),
            "Identifiable": HoverInfo(
                signature: "protocol Identifiable",
                typeInfo: "Swift.Identifiable",
                documentation: "A class of types whose instances hold the canonical value for their identity. Conform by providing a stable 'id' property, enabling SwiftUI views and collections to uniquely identify instances.",
                range: nil,
                language: "swift"
            ),

            // MARK: - SwiftUI & Combine
            "View": HoverInfo(
                signature: "protocol View",
                typeInfo: "SwiftUI.View",
                documentation: "A type that represents part of your app's user interface and provides modifiers that you use to configure views. Conform to this protocol to declare your own custom views.",
                range: nil,
                language: "swift"
            ),
            "ObservableObject": HoverInfo(
                signature: "protocol ObservableObject : AnyObject",
                typeInfo: "Combine.ObservableObject",
                documentation: "A type with a publisher that emits before the object has changed. Conform classes (reference types) to ObservableObject and mark changing properties with @Published to drive SwiftUI view updates.",
                range: nil,
                language: "swift"
            ),
            "Published": HoverInfo(
                signature: "@propertyWrapper struct Published<Value>",
                typeInfo: "Combine.Published",
                documentation: "A property wrapper that adds a publisher to a property of an ObservableObject. When the wrapped value changes, the publisher emits the new value to all subscribers, triggering SwiftUI view updates.",
                range: nil,
                language: "swift"
            ),
            "State": HoverInfo(
                signature: "@propertyWrapper struct State<Value> : DynamicProperty",
                typeInfo: "SwiftUI.State",
                documentation: "A property wrapper type that can read and write a value managed by the view. Use @State to create a single source of truth for value types within a view. Changes automatically invalidate the view body.",
                range: nil,
                language: "swift"
            ),
            "Binding": HoverInfo(
                signature: "@propertyWrapper struct Binding<Value>",
                typeInfo: "SwiftUI.Binding",
                documentation: "A property wrapper that provides two-way binding to a value. Use the $-prefix to create bindings from @State or pass data down to child views for read-write access without ownership.",
                range: nil,
                language: "swift"
            ),
            "EnvironmentObject": HoverInfo(
                signature: "@propertyWrapper struct EnvironmentObject<ObjectType> : DynamicProperty where ObjectType : ObservableObject",
                typeInfo: "SwiftUI.EnvironmentObject",
                documentation: "A property wrapper that injects an ObservableObject from the environment. Parent views must provide the object via .environmentObject(), and all child views can access it through this wrapper.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Concurrency
            "Task": HoverInfo(
                signature: "struct Task",
                typeInfo: "Swift.Task",
                documentation: "A unit of asynchronous work. Creates a new top-level asynchronous context. Supports cancellation via Task.cancel(), structured concurrency with TaskGroup, and priority-based scheduling. Prefer async/await over completion handlers.",
                range: nil,
                language: "swift"
            ),
            "async": HoverInfo(
                signature: "async",
                typeInfo: "Concurrency Keyword",
                documentation: "Marks a function or closure as asynchronous, allowing it to suspend and resume execution. Async functions can call other async functions using await and handle errors with do-catch or throws.",
                range: nil,
                language: "swift"
            ),
            "await": HoverInfo(
                signature: "await",
                typeInfo: "Concurrency Keyword",
                documentation: "Yields execution while waiting for an asynchronous operation to complete. Can only be used inside an async context. The current task is suspended (not blocked) until the awaited expression returns.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Error Handling Keywords
            "throws": HoverInfo(
                signature: "throws",
                typeInfo: "Error Handling Keyword",
                documentation: "Indicates that a function can throw an error. Callers must handle errors using do-catch, try?, try!, or propagate them by also marking the calling function with throws.",
                range: nil,
                language: "swift"
            ),
            "try": HoverInfo(
                signature: "try",
                typeInfo: "Error Handling Keyword",
                documentation: "Attempts to call a throwing function. Use 'try' inside a do-catch block, 'try?' to return nil on failure, or 'try!' to force-unwrap (crashes on error). Required before every throwing call.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Control Flow Keywords
            "guard": HoverInfo(
                signature: "guard condition else { ... }",
                typeInfo: "Control Flow Keyword",
                documentation: "Requires a condition to be true for execution to continue past the guard statement. If the condition is false, the else block must exit the current scope (return, throw, break, continue, or fatalError). Promotes early-exit patterns and unwrapping of optionals.",
                range: nil,
                language: "swift"
            ),
            "defer": HoverInfo(
                signature: "defer { ... }",
                typeInfo: "Control Flow Keyword",
                documentation: "Defers execution of a block of code until the current scope exits. Multiple defers execute in reverse order of declaration (LIFO). Commonly used for cleanup, closing resources, and ensuring unlock/commit code runs.",
                range: nil,
                language: "swift"
            ),

            // MARK: - Higher-Order Functions
            "map": HoverInfo(
                signature: "func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]",
                typeInfo: "Collection Method",
                documentation: "Returns an array containing the results of mapping the given closure over the sequence's elements. Transforms each element without mutating the original collection. O(n) time complexity.",
                range: nil,
                language: "swift"
            ),
            "filter": HoverInfo(
                signature: "func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element]",
                typeInfo: "Collection Method",
                documentation: "Returns an array containing the elements of the sequence that satisfy the given predicate. Only elements where the closure returns true are included in the result.",
                range: nil,
                language: "swift"
            ),
            "reduce": HoverInfo(
                signature: "func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result",
                typeInfo: "Collection Method",
                documentation: "Returns the result of combining the elements of the sequence using the given closure. Processes elements left to right, accumulating a single result value. Common for sums, concatenations, and aggregations.",
                range: nil,
                language: "swift"
            ),
            "forEach": HoverInfo(
                signature: "func forEach(_ body: (Element) throws -> Void) rethrows",
                typeInfo: "Collection Method",
                documentation: "Calls the given closure on each element in the sequence in the same order as a for-in loop. Unlike map, forEach cannot be used to transform or return values — use it only for side effects.",
                range: nil,
                language: "swift"
            ),
            "compactMap": HoverInfo(
                signature: "func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult]",
                typeInfo: "Collection Method",
                documentation: "Returns an array containing the non-nil results of calling the given transformation with each element of the sequence. Combines map and filter in one pass, removing nil values from the result.",
                range: nil,
                language: "swift"
            ),
            "flatMap": HoverInfo(
                signature: "func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence",
                typeInfo: "Collection Method",
                documentation: "Returns an array containing the concatenated results of calling the given transformation with each element of the sequence. Flattens one level of nesting. Also used to filter out nil when the transform returns an Optional.",
                range: nil,
                language: "swift"
            )
        ]
        
        return swiftDocs[cleanWord]
    }
}
