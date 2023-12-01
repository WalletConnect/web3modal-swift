// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-web3modal",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Web3Modal",
            targets: ["Web3Modal"]
        ),
        .library(
            name: "Web3ModalUI",
            targets: ["Web3ModalUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/WalletConnect/WalletConnectSwiftV2",
            from: "1.9.8"
        ),
        .package(
            url: "https://github.com/WalletConnect/QRCode",
            from: "14.3.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.10.0"
        ),
        .package(name: "CoinbaseWalletSDK", url: "https://github.com/coinbase/wallet-mobile-sdk.git", from: "1.0.5"),
    ],
    targets: [
        .target(
            name: "Web3Modal",
            dependencies: [
                "QRCode",
                .product(
                    name: "WalletConnect",
                    package: "WalletConnectSwiftV2"
                ),
                "Web3ModalUI",
                "Web3ModalBackport",
                "CoinbaseWalletSDK"
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .copy("PackageConfig.json")
            ]
        ),
        .target(
            name: "Web3ModalUI",
            dependencies: [
                "Web3ModalBackport"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .target(
            name: "Web3ModalBackport"
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "Web3ModalTests",
            dependencies: [
                "Web3Modal",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "Web3ModalUITests",
            dependencies: [
                "Web3ModalUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
