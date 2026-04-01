// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "NetworkLib", targets: ["NetworkLib"]),
        .library(name: "PersistenceLib", targets: ["PersistenceLib"]),
        .library(name: "CommonUIComponents", targets: ["CommonUIComponents"]),
        .library(name: "MainListInterface", targets: ["MainListInterface"]),
        .library(name: "MainListImpl", targets: ["MainListImpl"]),
        .library(name: "DetailInterface", targets: ["DetailInterface"]),
        .library(name: "DetailImpl", targets: ["DetailImpl"]),
        .library(name: "CentralRouter", targets: ["CentralRouter"]),
    ],
    targets: [
        // MARK: - Core Libs
        .target(
            name: "NetworkLib",
            path: "NetworkLib"
        ),
        .target(
            name: "PersistenceLib",
            path: "PersistenceLib"
        ),
        .target(
            name: "CommonUIComponents",
            path: "CommonUIComponents"
        ),

        // MARK: - Feature Interfaces
        .target(
            name: "MainListInterface",
            path: "MainList/MainListInterface"
        ),
        .target(
            name: "DetailInterface",
            dependencies: ["MainListInterface"],
            path: "Detail/DetailInterface"
        ),

        // MARK: - Feature Implementations
        .target(
            name: "MainListImpl",
            dependencies: [
                "MainListInterface",
                "NetworkLib",
                "PersistenceLib",
                "CommonUIComponents",
            ],
            path: "MainList/MainListImpl"
        ),
        .target(
            name: "DetailImpl",
            dependencies: [
                "DetailInterface",
                "MainListInterface",
                "CommonUIComponents",
            ],
            path: "Detail/DetailImpl"
        ),

        // MARK: - Navigation
        .target(
            name: "CentralRouter",
            dependencies: [
                "MainListInterface",
                "DetailInterface",
            ],
            path: "CentralRouter"
        ),

        // MARK: - Tests
        .testTarget(
            name: "NetworkLibTests",
            dependencies: ["NetworkLib"],
            path: "Tests/NetworkLibTests"
        ),
        .testTarget(
            name: "PersistenceLibTests",
            dependencies: ["PersistenceLib"],
            path: "Tests/PersistenceLibTests"
        ),
        .testTarget(
            name: "MainListInterfaceTests",
            dependencies: ["MainListInterface"],
            path: "Tests/MainListInterfaceTests"
        ),
        .testTarget(
            name: "MainListImplTests",
            dependencies: [
                "MainListImpl",
                "MainListInterface",
                "NetworkLib",
                "PersistenceLib",
                "CommonUIComponents",
            ],
            path: "Tests/MainListImplTests"
        ),
        .testTarget(
            name: "DetailImplTests",
            dependencies: [
                "DetailImpl",
                "DetailInterface",
                "MainListInterface",
                "CommonUIComponents",
            ],
            path: "Tests/DetailImplTests"
        ),
    ]
)
