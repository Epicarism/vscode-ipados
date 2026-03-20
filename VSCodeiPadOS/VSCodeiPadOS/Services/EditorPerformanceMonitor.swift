//
//  EditorPerformanceMonitor.swift
//  VSCodeiPadOS
//
//  Tracks editor performance metrics (FPS, parse time, layout time, memory)
//  and auto-degrades features when performance drops below thresholds.
//

import Foundation
import Combine
import QuartzCore
import os

// MARK: - Performance Metrics

struct EditorPerformanceSnapshot {
    let timestamp: Date
    let fps: Double
    let syntaxHighlightTimeMs: Double
    let textLayoutTimeMs: Double
    let memoryUsageMB: Double
    let lineCount: Int
    let isScrolling: Bool
}

// MARK: - Performance Monitor

@MainActor
final class EditorPerformanceMonitor: ObservableObject {
    static let shared = EditorPerformanceMonitor()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "EditorPerformance")
    
    // Published metrics
    @Published var currentFPS: Double = 60.0
    @Published var avgSyntaxHighlightMs: Double = 0
    @Published var avgTextLayoutMs: Double = 0
    @Published var memoryUsageMB: Double = 0
    @Published var shouldDegradeFeatures: Bool = false
    @Published var performanceWarning: String?
    
    // Thresholds
    private let targetFPS: Double = 60.0
    private let degradeThresholdFPS: Double = 30.0
    private let warningThresholdFPS: Double = 45.0
    private let maxSyntaxHighlightMs: Double = 16.0  // 1 frame at 60fps
    private let slowOperationThresholdMs: Double = 16.67
    
    // Tracking state
    nonisolated(unsafe) private var displayLink: CADisplayLink?
    private var frameTimestamps: [CFTimeInterval] = []
    private var syntaxHighlightTimes: [Double] = []
    private var textLayoutTimes: [Double] = []
    private var isMonitoring = false
    nonisolated(unsafe) private var degradeTimer: Timer?
    
    // Rolling window sizes
    private let fpsWindowSize = 60      // ~1 second of frames
    private let timingWindowSize = 20   // Last 20 measurements
    
    private init() {}

    deinit {
        displayLink?.invalidate()
        degradeTimer?.invalidate()
    }
    
    // MARK: - Start/Stop Monitoring
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        // CADisplayLink for FPS tracking
        let link = CADisplayLink(target: DisplayLinkTarget { [weak self] timestamp in
            Task { @MainActor in
                self?.recordFrame(timestamp: timestamp)
            }
        }, selector: #selector(DisplayLinkTarget.handleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
        
        // Periodic memory check
        degradeTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkMemoryUsage()
                self?.evaluatePerformance()
            }
        }
        
        Self.logger.info("Performance monitoring started")
    }
    
    func stopMonitoring() {
        isMonitoring = false
        displayLink?.invalidate()
        displayLink = nil
        degradeTimer?.invalidate()
        degradeTimer = nil
        frameTimestamps.removeAll()
        Self.logger.info("Performance monitoring stopped")
    }
    
    // MARK: - Record Metrics
    
    /// Record a frame timestamp for FPS calculation
    private func recordFrame(timestamp: CFTimeInterval) {
        frameTimestamps.append(timestamp)
        if frameTimestamps.count > fpsWindowSize {
            frameTimestamps.removeFirst(frameTimestamps.count - fpsWindowSize)
        }
        
        // Calculate FPS from frame deltas
        if frameTimestamps.count >= 2 {
            let totalTime = frameTimestamps.last! - frameTimestamps.first!
            if totalTime > 0 {
                currentFPS = Double(frameTimestamps.count - 1) / totalTime
            }
        }
    }
    
    /// Record syntax highlighting duration
    func recordSyntaxHighlightTime(_ milliseconds: Double) {
        syntaxHighlightTimes.append(milliseconds)
        if syntaxHighlightTimes.count > timingWindowSize {
            syntaxHighlightTimes.removeFirst()
        }
        avgSyntaxHighlightMs = syntaxHighlightTimes.reduce(0, +) / Double(syntaxHighlightTimes.count)
        
        if milliseconds > slowOperationThresholdMs {
            Self.logger.warning("Slow syntax highlight: \(String(format: "%.1f", milliseconds))ms")
        }
    }
    
    /// Record text layout duration
    func recordTextLayoutTime(_ milliseconds: Double) {
        textLayoutTimes.append(milliseconds)
        if textLayoutTimes.count > timingWindowSize {
            textLayoutTimes.removeFirst()
        }
        avgTextLayoutMs = textLayoutTimes.reduce(0, +) / Double(textLayoutTimes.count)
        
        if milliseconds > slowOperationThresholdMs {
            Self.logger.warning("Slow text layout: \(String(format: "%.1f", milliseconds))ms")
        }
    }
    
    /// Measure and record the duration of a block
    func measure<T>(_ label: String, block: () -> T) -> T {
        let start = CACurrentMediaTime()
        let result = block()
        let elapsed = (CACurrentMediaTime() - start) * 1000.0
        
        if elapsed > slowOperationThresholdMs {
            Self.logger.warning("Slow operation '\(label)': \(String(format: "%.1f", elapsed))ms")
        }
        
        return result
    }
    
    /// Async measure
    func measureAsync<T>(_ label: String, block: () async -> T) async -> T {
        let start = CACurrentMediaTime()
        let result = await block()
        let elapsed = (CACurrentMediaTime() - start) * 1000.0
        
        if elapsed > slowOperationThresholdMs {
            Self.logger.warning("Slow async operation '\(label)': \(String(format: "%.1f", elapsed))ms")
        }
        
        return result
    }
    
    // MARK: - Memory Tracking
    
    private func checkMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            memoryUsageMB = Double(info.resident_size) / (1024 * 1024)
        }
    }
    
    // MARK: - Performance Evaluation
    
    private func evaluatePerformance() {
        let prevDegrade = shouldDegradeFeatures
        
        if currentFPS < degradeThresholdFPS {
            shouldDegradeFeatures = true
            performanceWarning = "Low frame rate (\(Int(currentFPS)) FPS). Some features disabled for better performance."
        } else if currentFPS < warningThresholdFPS {
            performanceWarning = "Reduced frame rate (\(Int(currentFPS)) FPS)."
            // Don't auto-degrade yet, just warn
        } else if avgSyntaxHighlightMs > maxSyntaxHighlightMs * 2 {
            shouldDegradeFeatures = true
            performanceWarning = "Syntax highlighting is slow. Reducing highlight range."
        } else {
            shouldDegradeFeatures = false
            performanceWarning = nil
        }
        
        if shouldDegradeFeatures != prevDegrade {
            if shouldDegradeFeatures {
                Self.logger.warning("Performance degradation active: FPS=\(String(format: "%.0f", self.currentFPS)), syntaxMs=\(String(format: "%.1f", self.avgSyntaxHighlightMs))")
            } else {
                Self.logger.info("Performance restored to normal")
            }
        }
    }
    
    // MARK: - Snapshot
    
    func takeSnapshot(lineCount: Int, isScrolling: Bool) -> EditorPerformanceSnapshot {
        EditorPerformanceSnapshot(
            timestamp: Date(),
            fps: currentFPS,
            syntaxHighlightTimeMs: avgSyntaxHighlightMs,
            textLayoutTimeMs: avgTextLayoutMs,
            memoryUsageMB: memoryUsageMB,
            lineCount: lineCount,
            isScrolling: isScrolling
        )
    }
}

// MARK: - CADisplayLink Target (avoid retain cycle)

private class DisplayLinkTarget {
    let handler: (CFTimeInterval) -> Void
    
    init(handler: @escaping (CFTimeInterval) -> Void) {
        self.handler = handler
    }
    
    @objc func handleDisplayLink(_ displayLink: CADisplayLink) {
        handler(displayLink.timestamp)
    }
}
