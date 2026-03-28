// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlacMusicApp",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FlacMusicApp",
            targets: ["FlacMusicApp"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlacMusicApp",
            dependencies: [],
            path: "Sources/FlacMusicApp",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "FlacMusicAppTests",
            dependencies: ["FlacMusicApp"]
        )
    ]
)
