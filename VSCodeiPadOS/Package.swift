// swift-tools-version:5.9
// Package.swift for SwiftNIO SSH dependency
// Add this package to your Xcode project via:
// File -> Add Package Dependencies -> Enter URL:
// https://github.com/apple/swift-nio-ssh

import PackageDescription

let package = Package(
    name: "VSCodeiPadOS",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "VSCodeiPadOS",
            targets: ["VSCodeiPadOS"]
        ),
    ],
    dependencies: [
        // SwiftNIO SSH - Pure Swift SSH implementation
        .package(url: "https://github.com/apple/swift-nio-ssh", from: "0.8.0"),
        
        // SwiftNIO - Required by swift-nio-ssh
        .package(url: "https://github.com/apple/swift-nio", from: "2.50.0"),
    ],
    targets: [
        .target(
            name: "VSCodeiPadOS",
            dependencies: [
                .product(name: "NIOSSH", package: "swift-nio-ssh"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            path: "VSCodeiPadOS"
        ),
    ]
)
