//
//  Array+Safe.swift
//  VSCodeiPadOS
//
//  Safe array subscript extension
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
