// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StrataShowcase",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "StrataShowcase", targets: ["StrataShowcase"]),
        .executable(name: "StrataShowcaseApp", targets: ["StrataShowcaseApp"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/LeePepe/shared-design-system.git",
            revision: "f4ff0de68c4d962fe6e8fbc0a529917a65a79c39"
        )
    ],
    targets: [
        .target(
            name: "StrataShowcase",
            dependencies: [
                .product(name: "Strata", package: "shared-design-system"),
                .product(name: "DesignTokens", package: "shared-design-system")
            ]
        ),
        .executableTarget(
            name: "StrataShowcaseApp",
            dependencies: [
                "StrataShowcase",
                .product(name: "Strata", package: "shared-design-system"),
                .product(name: "DesignTokens", package: "shared-design-system")
            ]
        ),
        .testTarget(
            name: "StrataShowcaseTests",
            dependencies: [
                "StrataShowcase",
                .product(name: "Strata", package: "shared-design-system"),
                .product(name: "DesignTokens", package: "shared-design-system")
            ]
        )
    ]
)
