// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Device",
    platforms: [
        .iOS("15.2"),
        .macOS("11.0"),
        .tvOS("14.0"),
        .watchOS("6.0"),
        .visionOS("1.0")
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Device Library", // has to be named different from the iOSApplication or Swift Playgrounds won't open correctly
            targets: ["Device"]
        ),
        .iOSApplication(
            name: "Device", // needs to match package name to open properly in Swift Playgrounds
            targets: ["DeviceTestAppModule"],
            teamIdentifier: "3QPV894C33",
            displayVersion: "2.1.3",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .outgoingNetworkConnections()
            ],
            appCategory: .developerTools
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.

        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Device",
            path: "Sources",
            resources: [
	            .process("Resources"),
            ]
        ),
        .executableTarget(
            name: "DeviceTestAppModule",
            dependencies: [
                "Device"
            ],
            path: "Development",
//			exclude: ["Device.xcodeproj/*"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "DeviceTests",
            dependencies: [
                "Device"
            ],
            path: "Tests"
        ),
    ]
)
