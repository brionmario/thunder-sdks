// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThunderSwiftUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "ThunderSwiftUI", targets: ["ThunderSwiftUI"]),
    ],
    dependencies: [
        .package(path: "../ios"),
    ],
    targets: [
        .target(
            name: "ThunderSwiftUI",
            dependencies: [
                .product(name: "Thunder", package: "ios"),
            ],
            path: "Sources/ThunderSwiftUI"
        ),
        .testTarget(
            name: "ThunderSwiftUITests",
            dependencies: ["ThunderSwiftUI"],
            path: "Tests/ThunderSwiftUITests"
        ),
    ]
)
