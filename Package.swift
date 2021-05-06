// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ActiveLabel",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "ActiveLabel",
            targets: ["ActiveLabel"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ActiveLabel",
            path: "ActiveLabel",
            exclude: ["ActiveLabelDemo"]),
    ],
    swiftLanguageVersions: [.v5]
)
