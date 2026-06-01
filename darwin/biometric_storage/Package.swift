// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "biometric_storage",
    platforms: [
        .iOS("13.0"),
        .macOS("10.14"),
    ],
    products: [
        .library(name: "biometric-storage", targets: ["biometric_storage"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "biometric_storage",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            path: "Sources/biometric_storage"
        ),
    ]
)
