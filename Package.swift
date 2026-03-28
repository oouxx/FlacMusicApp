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
        .executableTarget(
            name: "FlacMusicApp-macOS",
            dependencies: ["FlacMusicApp"],
            path: "Sources/FlacMusicApp",
            sources: ["FlacMusicApp_macOS.swift"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "FlacMusicApp-iOS",
            dependencies: ["FlacMusicApp"],
            path: "Sources/FlacMusicApp",
            sources: ["FlacMusicApp_iOS.swift"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "FlacMusicApp",
            dependencies: [],
            path: "Sources/FlacMusicApp",
            exclude: [
                "FlacMusicApp_macOS.swift",
                "FlacMusicApp_iOS.swift"
            ],
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
