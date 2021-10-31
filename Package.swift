// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Quickblox",
    products: [
        .library(
            name: "Quickblox",
            targets: ["Quickblox"]),
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "Quickblox",
            path: "Framework/Quickblox.xcframework"),
    ]
)
