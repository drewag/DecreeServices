// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DecreeServices",
    platforms: [
        .macOS(.v10_12), .iOS(.v9), .tvOS(.v9), .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DecreeServices",
            targets: ["DecreeServices"]),
    ],
    dependencies: [
        .package(url: "https://github.com/drewag/Decree.git", from: "4.4.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DecreeServices",
            dependencies: ["Decree","CryptoSwift"]),
        .testTarget(
            name: "DecreeServicesTests",
            dependencies: ["DecreeServices"]),
    ],
    swiftLanguageVersions: [.v5]
)
