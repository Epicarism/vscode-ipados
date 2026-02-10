// StressTest.swift - Large file for editor performance testing
// Generated with 60+ functions to stress test scrolling and typing

import Foundation
import SwiftUI

// MARK: - Utility Functions (1-10)

func processData1(input: String) -> String {
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    let uppercased = trimmed.uppercased()
    let result = "Processed: \(uppercased)"
    print("Function 1 completed")
    return result
}

func processData2(input: String) -> String {
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    let lowercased = trimmed.lowercased()
    let result = "Processed: \(lowercased)"
    print("Function 2 completed")
    return result
}

func processData3(input: [Int]) -> Int {
    let sum = input.reduce(0, +)
    let average = input.isEmpty ? 0 : sum / input.count
    print("Function 3: Sum=\(sum), Avg=\(average)")
    return sum
}

func processData4(input: [Int]) -> [Int] {
    let sorted = input.sorted()
    let filtered = sorted.filter { $0 > 0 }
    print("Function 4: Filtered \(filtered.count) items")
    return filtered
}

func processData5(input: Double) -> Double {
    let squared = input * input
    let cubed = squared * input
    let result = sqrt(squared + cubed)
    print("Function 5: Result=\(result)")
    return result
}

func processData6(input: String) -> [String] {
    let words = input.components(separatedBy: " ")
    let filtered = words.filter { !$0.isEmpty }
    print("Function 6: Found \(filtered.count) words")
    return filtered
}

func processData7(input: [String]) -> String {
    let joined = input.joined(separator: ", ")
    let result = "[\(joined)]"
    print("Function 7: Joined string")
    return result
}

func processData8(input: Int) -> Bool {
    let isEven = input % 2 == 0
    let isPositive = input > 0
    let result = isEven && isPositive
    print("Function 8: isEven=\(isEven), isPositive=\(isPositive)")
    return result
}

func processData9(input: [Double]) -> Double {
    guard !input.isEmpty else { return 0 }
    let sum = input.reduce(0, +)
    let mean = sum / Double(input.count)
    print("Function 9: Mean=\(mean)")
    return mean
}

func processData10(input: String) -> Int {
    let count = input.count
    let vowels = input.filter { "aeiouAEIOU".contains($0) }.count
    print("Function 10: Length=\(count), Vowels=\(vowels)")
    return count
}

// MARK: - Data Transformation Functions (11-20)

func transformData11(input: [Int]) -> [Int] {
    return input.map { $0 * 2 }
}

func transformData12(input: [Int]) -> [Int] {
    return input.map { $0 + 10 }
}

func transformData13(input: [String]) -> [String] {
    return input.map { $0.uppercased() }
}

func transformData14(input: [String]) -> [Int] {
    return input.map { $0.count }
}

func transformData15(input: [Double]) -> [Double] {
    return input.map { $0 * 1.5 }
}

func transformData16(input: [[Int]]) -> [Int] {
    return input.flatMap { $0 }
}

func transformData17(input: [Int]) -> [String] {
    return input.map { String($0) }
}

func transformData18(input: [String]) -> [String] {
    return input.filter { $0.count > 3 }
}

func transformData19(input: [Int]) -> Int? {
    return input.max()
}

func transformData20(input: [Int]) -> Int? {
    return input.min()
}

// MARK: - Validation Functions (21-30)

func validateInput21(value: String) -> Bool {
    return !value.isEmpty
}

func validateInput22(value: Int) -> Bool {
    return value >= 0 && value <= 100
}

func validateInput23(email: String) -> Bool {
    return email.contains("@") && email.contains(".")
}

func validateInput24(password: String) -> Bool {
    return password.count >= 8
}

func validateInput25(array: [Int]) -> Bool {
    return !array.isEmpty && array.count <= 1000
}

func validateInput26(url: String) -> Bool {
    return url.hasPrefix("http://") || url.hasPrefix("https://")
}

func validateInput27(phone: String) -> Bool {
    let digits = phone.filter { $0.isNumber }
    return digits.count >= 10
}

func validateInput28(date: Date) -> Bool {
    return date <= Date()
}

func validateInput29(amount: Double) -> Bool {
    return amount > 0 && amount < 1000000
}

func validateInput30(name: String) -> Bool {
    let trimmed = name.trimmingCharacters(in: .whitespaces)
    return trimmed.count >= 2 && trimmed.count <= 50
}

// MARK: - Calculation Functions (31-40)

func calculate31(a: Int, b: Int) -> Int {
    return a + b
}

func calculate32(a: Int, b: Int) -> Int {
    return a - b
}

func calculate33(a: Int, b: Int) -> Int {
    return a * b
}

func calculate34(a: Double, b: Double) -> Double {
    guard b != 0 else { return 0 }
    return a / b
}

func calculate35(base: Double, exponent: Int) -> Double {
    return pow(base, Double(exponent))
}

func calculate36(radius: Double) -> Double {
    return Double.pi * radius * radius
}

func calculate37(length: Double, width: Double) -> Double {
    return length * width
}

func calculate38(principal: Double, rate: Double, time: Double) -> Double {
    return principal * (1 + rate * time)
}

func calculate39(values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    let sorted = values.sorted()
    let mid = sorted.count / 2
    if sorted.count % 2 == 0 {
        return (sorted[mid - 1] + sorted[mid]) / 2
    }
    return sorted[mid]
}

func calculate40(values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    let mean = values.reduce(0, +) / Double(values.count)
    let squaredDiffs = values.map { pow($0 - mean, 2) }
    let variance = squaredDiffs.reduce(0, +) / Double(values.count)
    return sqrt(variance)
}

// MARK: - String Manipulation Functions (41-50)

func manipulateString41(input: String) -> String {
    return String(input.reversed())
}

func manipulateString42(input: String) -> String {
    return input.replacingOccurrences(of: " ", with: "_")
}

func manipulateString43(input: String) -> String {
    return input.capitalized
}

func manipulateString44(input: String, prefix: String) -> String {
    return prefix + input
}

func manipulateString45(input: String, suffix: String) -> String {
    return input + suffix
}

func manipulateString46(input: String, old: String, new: String) -> String {
    return input.replacingOccurrences(of: old, with: new)
}

func manipulateString47(input: String) -> [Character] {
    return Array(input)
}

func manipulateString48(input: String, count: Int) -> String {
    return String(repeating: input, count: count)
}

func manipulateString49(input: String) -> String {
    return input.trimmingCharacters(in: .whitespacesAndNewlines)
}

func manipulateString50(input: String, maxLength: Int) -> String {
    if input.count <= maxLength {
        return input
    }
    return String(input.prefix(maxLength)) + "..."
}

// MARK: - Array Processing Functions (51-60)

func processArray51(input: [Int]) -> [Int] {
    return input.filter { $0 % 2 == 0 }
}

func processArray52(input: [Int]) -> [Int] {
    return input.filter { $0 % 2 != 0 }
}

func processArray53(input: [Int]) -> Set<Int> {
    return Set(input)
}

func processArray54(input: [Int]) -> [Int: Int] {
    var counts: [Int: Int] = [:]
    for item in input {
        counts[item, default: 0] += 1
    }
    return counts
}

func processArray55(input: [Int], target: Int) -> Int? {
    return input.firstIndex(of: target)
}

func processArray56(input: [Int]) -> (min: Int?, max: Int?) {
    return (input.min(), input.max())
}

func processArray57(input: [Int], n: Int) -> [Int] {
    return Array(input.prefix(n))
}

func processArray58(input: [Int], n: Int) -> [Int] {
    return Array(input.suffix(n))
}

func processArray59(input: [Int]) -> [Int] {
    return input.shuffled()
}

func processArray60(input: [Int], chunkSize: Int) -> [[Int]] {
    var chunks: [[Int]] = []
    var current: [Int] = []
    for item in input {
        current.append(item)
        if current.count == chunkSize {
            chunks.append(current)
            current = []
        }
    }
    if !current.isEmpty {
        chunks.append(current)
    }
    return chunks
}

// MARK: - SwiftUI View Components (61-70)

struct TestView61: View {
    var body: some View {
        Text("View 61")
            .font(.title)
            .foregroundColor(.blue)
    }
}

struct TestView62: View {
    @State private var counter = 0
    var body: some View {
        VStack {
            Text("Count: \(counter)")
            Button("Increment") { counter += 1 }
        }
    }
}

struct TestView63: View {
    @State private var text = ""
    var body: some View {
        TextField("Enter text", text: $text)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}

struct TestView64: View {
    let items = ["A", "B", "C", "D", "E"]
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}

struct TestView65: View {
    @State private var isOn = false
    var body: some View {
        Toggle("Enable Feature", isOn: $isOn)
            .padding()
    }
}

struct TestView66: View {
    @State private var sliderValue = 0.5
    var body: some View {
        Slider(value: $sliderValue)
            .padding()
    }
}

struct TestView67: View {
    @State private var selectedIndex = 0
    var body: some View {
        Picker("Select", selection: $selectedIndex) {
            Text("Option 1").tag(0)
            Text("Option 2").tag(1)
            Text("Option 3").tag(2)
        }
    }
}

struct TestView68: View {
    var body: some View {
        HStack(spacing: 20) {
            Circle().fill(.red).frame(width: 50)
            Circle().fill(.green).frame(width: 50)
            Circle().fill(.blue).frame(width: 50)
        }
    }
}

struct TestView69: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.gray)
            Text("Overlay")
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 100)
    }
}

struct TestView70: View {
    @State private var isPresented = false
    var body: some View {
        Button("Show Sheet") { isPresented = true }
            .sheet(isPresented: $isPresented) {
                Text("Sheet Content")
            }
    }
}

// MARK: - Additional Helper Functions (71-80)

func helper71(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

func helper72(json: Data) -> [String: Any]? {
    return try? JSONSerialization.jsonObject(with: json) as? [String: Any]
}

func helper73(dictionary: [String: Any]) -> Data? {
    return try? JSONSerialization.data(withJSONObject: dictionary)
}

func helper74(url: String) -> URL? {
    return URL(string: url)
}

func helper75(data: Data) -> String? {
    return String(data: data, encoding: .utf8)
}

func helper76(string: String) -> Data? {
    return string.data(using: .utf8)
}

func helper77(timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = (Int(timeInterval) % 3600) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

func helper78(bytes: Int) -> String {
    let kb = Double(bytes) / 1024
    let mb = kb / 1024
    let gb = mb / 1024
    if gb >= 1 { return String(format: "%.2f GB", gb) }
    if mb >= 1 { return String(format: "%.2f MB", mb) }
    if kb >= 1 { return String(format: "%.2f KB", kb) }
    return "\(bytes) bytes"
}

func helper79(color: Color) -> some View {
    return Rectangle()
        .fill(color)
        .frame(width: 100, height: 100)
        .cornerRadius(10)
}

func helper80(text: String, fontSize: CGFloat) -> some View {
    return Text(text)
        .font(.system(size: fontSize))
        .fontWeight(.bold)
}

// MARK: - Final Stress Test Section
// This section adds more code to increase file size

class StressTestManager {
    static let shared = StressTestManager()
    
    private var cache: [String: Any] = [:]
    private var queue: [String] = []
    private let maxQueueSize = 100
    
    func addToCache(key: String, value: Any) {
        cache[key] = value
        queue.append(key)
        if queue.count > maxQueueSize {
            let oldKey = queue.removeFirst()
            cache.removeValue(forKey: oldKey)
        }
    }
    
    func getFromCache(key: String) -> Any? {
        return cache[key]
    }
    
    func clearCache() {
        cache.removeAll()
        queue.removeAll()
    }
    
    func processLargeDataset(_ data: [Int]) -> [Int] {
        return data
            .filter { $0 > 0 }
            .map { $0 * 2 }
            .sorted()
    }
    
    func generateTestData(count: Int) -> [Int] {
        return (0..<count).map { _ in Int.random(in: 1...1000) }
    }
}

// End of StressTest.swift
// Total: 80+ functions and multiple SwiftUI views
// This file should be sufficient for stress testing the editor
