// swift-tools-version:5
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
