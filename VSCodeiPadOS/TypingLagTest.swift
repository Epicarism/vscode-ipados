// Typing Lag Test File
// This file has many lines to test editor performance

import Foundation
import SwiftUI

// MARK: - Test Functions

func performanceTest1() {
    var sum = 0
    for i in 0..<100 {
        sum += i
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest2() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 2
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest3() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 3
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest4() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 4
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest5() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 5
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest6() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 6
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest7() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 7
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest8() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 8
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest9() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 9
        print("Iteration \(i): sum = \(sum)")
    }
}

func performanceTest10() {
    var sum = 0
    for i in 0..<100 {
        sum += i * 10
        print("Iteration \(i): sum = \(sum)")
    }
}

// MARK: - Additional Tests

struct TestStruct1 {
    var value1: Int
    var value2: String
    var value3: Double
    
    func calculate() -> Int {
        return value1 * 2
    }
}

struct TestStruct2 {
    var value1: Int
    var value2: String
    var value3: Double
    
    func calculate() -> Int {
        return value1 * 3
    }
}

struct TestStruct3 {
    var value1: Int
    var value2: String
    var value3: Double
    
    func calculate() -> Int {
        return value1 * 4
    }
}

struct TestStruct4 {
    var value1: Int
    var value2: String
    var value3: Double
    
    func calculate() -> Int {
        return value1 * 5
    }
}

struct TestStruct5 {
    var value1: Int
    var value2: String
    var value3: Double
    
    func calculate() -> Int {
        return value1 * 6
    }
}

// MARK: - More Functions

func loopTest1() {
    for i in 0..<50 {
        for j in 0..<50 {
            let result = i * j
            print("\(i) * \(j) = \(result)")
        }
    }
}

func loopTest2() {
    for i in 0..<50 {
        for j in 0..<50 {
            let result = i + j
            print("\(i) + \(j) = \(result)")
        }
    }
}

func loopTest3() {
    for i in 0..<50 {
        for j in 0..<50 {
            let result = i - j
            print("\(i) - \(j) = \(result)")
        }
    }
}

func loopTest4() {
    for i in 0..<50 {
        for j in 0..<50 {
            let result = i / max(j, 1)
            print("\(i) / \(j) = \(result)")
        }
    }
}

func loopTest5() {
    for i in 0..<50 {
        for j in 0..<50 {
            let result = i % max(j, 1)
            print("\(i) % \(j) = \(result)")
        }
    }
}

// Line 200
// More content below...

func additionalTest1() -> Int {
    var result = 0
    for i in 1...100 {
        result += i
    }
    return result
}

func additionalTest2() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 2
    }
    return result
}

func additionalTest3() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 3
    }
    return result
}

func additionalTest4() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 4
    }
    return result
}

func additionalTest5() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 5
    }
    return result
}

func additionalTest6() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 6
    }
    return result
}

func additionalTest7() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 7
    }
    return result
}

func additionalTest8() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 8
    }
    return result
}

func additionalTest9() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 9
    }
    return result
}

func additionalTest10() -> Int {
    var result = 0
    for i in 1...100 {
        result += i * 10
    }
    return result
}

// MARK: - Classes

class TestClass1 {
    var property1: Int = 0
    var property2: String = ""
    var property3: Double = 0.0
    
    func method1() { print("method1") }
    func method2() { print("method2") }
    func method3() { print("method3") }
}

class TestClass2 {
    var property1: Int = 0
    var property2: String = ""
    var property3: Double = 0.0
    
    func method1() { print("method1") }
    func method2() { print("method2") }
    func method3() { print("method3") }
}

class TestClass3 {
    var property1: Int = 0
    var property2: String = ""
    var property3: Double = 0.0
    
    func method1() { print("method1") }
    func method2() { print("method2") }
    func method3() { print("method3") }
}

class TestClass4 {
    var property1: Int = 0
    var property2: String = ""
    var property3: Double = 0.0
    
    func method1() { print("method1") }
    func method2() { print("method2") }
    func method3() { print("method3") }
}

class TestClass5 {
    var property1: Int = 0
    var property2: String = ""
    var property3: Double = 0.0
    
    func method1() { print("method1") }
    func method2() { print("method2") }
    func method3() { print("method3") }
}

// MARK: - Enums

enum TestEnum1 {
    case case1, case2, case3, case4, case5
    case case6, case7, case8, case9, case10
}

enum TestEnum2 {
    case alpha, beta, gamma, delta, epsilon
    case zeta, eta, theta, iota, kappa
}

enum TestEnum3: Int {
    case one = 1, two, three, four, five
    case six, seven, eight, nine, ten
}

// MARK: - Protocols

protocol TestProtocol1 {
    func doSomething()
    var someValue: Int { get }
}

protocol TestProtocol2 {
    func doSomethingElse()
    var anotherValue: String { get }
}

protocol TestProtocol3 {
    func performAction()
    var actionResult: Bool { get }
}

// MARK: - Extensions

extension Int {
    func doubled() -> Int { self * 2 }
    func tripled() -> Int { self * 3 }
    func quadrupled() -> Int { self * 4 }
}

extension String {
    func shouted() -> String { self.uppercased() + "!" }
    func whispered() -> String { self.lowercased() + "..." }
}

extension Array {
    func secondElement() -> Element? {
        count > 1 ? self[1] : nil
    }
}

// Line 400 - Testing larger files

func finalTest1() {
    let numbers = [1, 2, 3, 4, 5]
    let doubled = numbers.map { $0 * 2 }
    print(doubled)
}

func finalTest2() {
    let numbers = [1, 2, 3, 4, 5]
    let filtered = numbers.filter { $0 > 2 }
    print(filtered)
}

func finalTest3() {
    let numbers = [1, 2, 3, 4, 5]
    let sum = numbers.reduce(0, +)
    print(sum)
}

func finalTest4() {
    let words = ["hello", "world"]
    let joined = words.joined(separator: " ")
    print(joined)
}

func finalTest5() {
    let dict = ["a": 1, "b": 2, "c": 3]
    for (key, value) in dict {
        print("\(key): \(value)")
    }
}

// More lines to reach 500+
func extra1() { print("1") }
func extra2() { print("2") }
func extra3() { print("3") }
func extra4() { print("4") }
func extra5() { print("5") }
func extra6() { print("6") }
func extra7() { print("7") }
func extra8() { print("8") }
func extra9() { print("9") }
func extra10() { print("10") }
func extra11() { print("11") }
func extra12() { print("12") }
func extra13() { print("13") }
func extra14() { print("14") }
func extra15() { print("15") }
func extra16() { print("16") }
func extra17() { print("17") }
func extra18() { print("18") }
func extra19() { print("19") }
func extra20() { print("20") }
func extra21() { print("21") }
func extra22() { print("22") }
func extra23() { print("23") }
func extra24() { print("24") }
func extra25() { print("25") }
func extra26() { print("26") }
func extra27() { print("27") }
func extra28() { print("28") }
func extra29() { print("29") }
func extra30() { print("30") }
func extra31() { print("31") }
func extra32() { print("32") }
func extra33() { print("33") }
func extra34() { print("34") }
func extra35() { print("35") }
func extra36() { print("36") }
func extra37() { print("37") }
func extra38() { print("38") }
func extra39() { print("39") }
func extra40() { print("40") }
func extra41() { print("41") }
func extra42() { print("42") }
func extra43() { print("43") }
func extra44() { print("44") }
func extra45() { print("45") }
func extra46() { print("46") }
func extra47() { print("47") }
func extra48() { print("48") }
func extra49() { print("49") }
func extra50() { print("50") }

// END OF FILE - Approximately 500 lines
