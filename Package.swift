// swift-tools-version:5.10
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2021 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

let strictConcurrencyDevelopment = false

let strictConcurrencySettings: [SwiftSetting] = {
    var initialSettings: [SwiftSetting] = []
    initialSettings.append(contentsOf: [
        .enableUpcomingFeature("StrictConcurrency"),
        .enableUpcomingFeature("InferSendableFromCaptures"),
    ])

    if strictConcurrencyDevelopment {
        // -warnings-as-errors here is a workaround so that IDE-based development can
        // get tripped up on -require-explicit-sendable.
        initialSettings.append(.unsafeFlags(["-require-explicit-sendable", "-warnings-as-errors"]))
    }

    return initialSettings
}()

let package = Package(
    name: "swift-nio-http2",
    products: [
        .library(name: "CandleNIOHTTP2", targets: ["CandleNIOHTTP2"])
    ],
    dependencies: [
        .package(name: "candle-swift-nio", url: "https://github.com/candlefinance/candle-swift-nio.git", branch: "fix-candle-2.82.1"),
        .package(name: "candle-swift-atomics", url: "https://github.com/candlefinance/candle-swift-atomics.git", branch: "fix-candle-1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "NIOHTTP2Server",
            dependencies: [
                "CandleNIOHTTP2",
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOPosix", package: "swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "swift-nio"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .executableTarget(
            name: "NIOHTTP2PerformanceTester",
            dependencies: [
                "CandleNIOHTTP2",
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOPosix", package: "swift-nio"),
                .product(name: "CandleNIOEmbedded", package: "swift-nio"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "CandleNIOHTTP2",
            dependencies: [
                "CandleNIOHPACK",
                .product(name: "CandleNIO", package: "swift-nio"),
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "swift-nio"),
                .product(name: "CandleNIOTLS", package: "swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "CandleAtomics", package: "swift-atomics"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .target(
            name: "CandleNIOHPACK",
            dependencies: [
                .product(name: "CandleNIO", package: "swift-nio"),
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "swift-nio"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "NIOHTTP2Tests",
            dependencies: [
                "CandleNIOHTTP2",
                .product(name: "CandleNIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOEmbedded", package: "swift-nio"),
                .product(name: "CandleNIOHTTP1", package: "swift-nio"),
                .product(name: "CandleNIOFoundationCompat", package: "swift-nio"),
                .product(name: "CandleAtomics", package: "swift-atomics"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
        .testTarget(
            name: "NIOHPACKTests",
            dependencies: [
                "CandleNIOHPACK",
                .product(name: "CandleNIOCore", package: "swift-nio"),
                .product(name: "CandleNIOFoundationCompat", package: "swift-nio"),
            ],
            resources: [
                .copy("Fixtures/large_complex_huffman_b64.txt"),
                .copy("Fixtures/large_huffman_b64.txt"),
            ],
            swiftSettings: strictConcurrencySettings
        ),
    ]
)

// ---    STANDARD CROSS-REPO SETTINGS DO NOT EDIT   --- //
for target in package.targets {
    switch target.type {
    case .regular, .test, .executable:
        var settings = target.swiftSettings ?? []
        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        target.swiftSettings = settings
    case .macro, .plugin, .system, .binary:
        ()  // not applicable
    @unknown default:
        ()  // we don't know what to do here, do nothing
    }
}
// --- END: STANDARD CROSS-REPO SETTINGS DO NOT EDIT --- //
