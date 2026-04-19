// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThunderIOSB2C",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(path: "../../../tools/sdks/swiftui"),
    ],
    targets: [
        .executableTarget(
            name: "ThunderIOSB2C",
            dependencies: [
                .product(name: "ThunderSwiftUI", package: "swiftui"),
            ],
            path: "Sources"
        ),
    ]
)
