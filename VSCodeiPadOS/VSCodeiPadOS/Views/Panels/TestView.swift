import SwiftUI

struct TestView: View {
    @State private var testSuites: [TestSuite] = [
        TestSuite(name: "CalculatorTests", tests: [
            TestCase(name: "testAddition", status: .success),
            TestCase(name: "testSubtraction", status: .failure),
            TestCase(name: "testMultiplication", status: .none),
            TestCase(name: "testDivision", status: .none)
        ]),
        TestSuite(name: "StringTests", tests: [
            TestCase(name: "testConcatenation", status: .success),
            TestCase(name: "testSplit", status: .none),
            TestCase(name: "testEmpty", status: .none)
        ]),
        TestSuite(name: "NetworkTests", tests: [
            TestCase(name: "testFetchData", status: .none),
            TestCase(name: "testUploadData", status: .none)
        ])
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TESTING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { runAllTests() }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                        .padding(4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
                .help("Run All Tests")
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { refreshTests() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .help("Refresh Tests")
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach($testSuites) { $suite in
                        TestSuiteRow(suite: $suite)
                    }
                }
                .padding(.top, 4)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    func runAllTests() {
        for i in 0..<testSuites.count {
            for j in 0..<testSuites[i].tests.count {
                testSuites[i].tests[j].status = .running
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            for i in 0..<testSuites.count {
                for j in 0..<testSuites[i].tests.count {
                    testSuites[i].tests[j].status = Bool.random() ? .success : .failure
                }
            }
        }
    }
    
    func refreshTests() {
        // Mock refresh animation
        // In a real app this would rescan files
    }
}

struct TestSuiteRow: View {
    @Binding var suite: TestSuite
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                
                Image(systemName: "testtube.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(suite.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { runSuite() }) {
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            
            if isExpanded {
                ForEach($suite.tests) { $test in
                    TestCaseRow(test: $test)
                        .padding(.leading, 24)
                }
            }
        }
    }
    
    func runSuite() {
        for i in 0..<suite.tests.count {
            suite.tests[i].status = .running
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for i in 0..<suite.tests.count {
                suite.tests[i].status = Bool.random() ? .success : .failure
            }
        }
    }
}

struct TestCaseRow: View {
    @Binding var test: TestCase
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            StatusIcon(status: test.status)
            
            Text(test.name)
                .font(.system(size: 12))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: { runTest() }) {
                Image(systemName: "play.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 2)
        .padding(.trailing, 8)
    }
    
    func runTest() {
        test.status = .running
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            test.status = Bool.random() ? .success : .failure
        }
    }
}

struct StatusIcon: View {
    let status: TestStatus
    
    var body: some View {
        ZStack {
            switch status {
            case .none:
                Circle()
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                    .frame(width: 10, height: 10)
            case .running:
                ProgressView()
                    .scaleEffect(0.4)
                    .frame(width: 10, height: 10)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 10))
            case .failure:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 10))
            }
        }
        .frame(width: 16, height: 16)
    }
}

struct TestSuite: Identifiable {
    let id = UUID()
    let name: String
    var tests: [TestCase]
}

struct TestCase: Identifiable {
    let id = UUID()
    let name: String
    var status: TestStatus
}

enum TestStatus {
    case none
    case running
    case success
    case failure
}
