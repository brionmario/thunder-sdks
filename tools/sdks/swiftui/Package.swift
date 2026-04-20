// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThunderIDSwiftUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "ThunderIDSwiftUI", targets: ["ThunderIDSwiftUI"]),
    ],
    dependencies: [
        .package(path: "../ios"),
    ],
    targets: [
        .target(
            name: "ThunderIDSwiftUI",
            dependencies: [
                .product(name: "ThunderID", package: "ios"),
            ],
            path: "Sources/ThunderIDSwiftUI"
        ),
        .testTarget(
            name: "ThunderIDSwiftUITests",
            dependencies: ["ThunderIDSwiftUI"],
            path: "Tests/ThunderIDSwiftUITests"
        ),
    ]
)
