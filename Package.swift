// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftColorGenLibrary",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftColorGenLibrary",
            targets: ["SwiftColorGenLibrary"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.2.2"),
        .package(url: "https://github.com/silt-lang/CommandLine", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftColorGenLibrary",
            dependencies: ["AEXML", "CommandLine"]),
        .testTarget(
            name: "SwiftColorGenLibraryTests",
            dependencies: ["SwiftColorGenLibrary"]),
    ]
)
