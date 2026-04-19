// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Thunder",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Thunder", targets: ["Thunder"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Thunder",
            dependencies: [],
            path: "Sources/Thunder"
        ),
        .testTarget(
            name: "ThunderTests",
            dependencies: ["Thunder"],
            path: "Tests/ThunderTests"
        )
    ]
)
