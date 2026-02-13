// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FastClock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "FastClock", targets: ["FastClock"])
    ],
    targets: [
        .executableTarget(
            name: "FastClock",
            path: "Sources"
        )
    ]
)
