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
            revision: "781c09de3af483ed56f531adba97617c0cae153f"
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
