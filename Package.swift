// swift-tools-version:5.2
// Managed by ice

import PackageDescription

let package = Package(
    name: "swiftup",
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.2"),
    ],
    targets: [
        .target(name: "swiftup", dependencies: ["SwiftCLI"]),
        .testTarget(name: "swiftupTests", dependencies: ["swiftup"]),
    ]
)
