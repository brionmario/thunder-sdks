// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ThunderID",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "ThunderID", targets: ["ThunderID"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ThunderID",
            dependencies: [],
            path: "Sources/ThunderID"
        ),
        .testTarget(
            name: "ThunderIDTests",
            dependencies: ["ThunderID"],
            path: "Tests/ThunderIDTests"
        )
    ]
)
