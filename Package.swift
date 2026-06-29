// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GameConsoleSymbols",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "GameConsoleSymbols", targets: ["GameConsoleSymbols"]),
    ],
    targets: [
        .target(
            name: "GameConsoleSymbols",
            resources: [
                .process("Resources/Symbols.xcassets"),
            ]
        ),
    ]
)
