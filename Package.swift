// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "ActiveLabel",
    products: [
        .library(name: "ActiveLabel", targets: ["ActiveLabel"])
    ],
    targets: [
        .target(
            name: "ActiveLabel",
            path: "ActiveLabel"
        )
    ]
)
