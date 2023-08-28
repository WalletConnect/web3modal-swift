// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-web3modal",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Web3Modal",
            targets: ["Web3Modal"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/WalletConnect/WalletConnectSwiftV2", branch: "remove-wcm"
        )
    ],
    targets: [
        .target(
            name: "Web3Modal",
            dependencies: [
                .product(
                    name: "WalletConnect",
                    package: "WalletConnectSwiftV2"
                )
            ]
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "Web3ModalTests",
            dependencies: ["Web3Modal"]
        )
    ]
)
