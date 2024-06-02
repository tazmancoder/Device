// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription

var version = "2.1.14"
var packageLibraryName = "Device"

// Products define the executables and libraries a package produces, making them visible to other packages.
var products = [
	Product.library(
        name: "\(packageLibraryName) Library", // has to be named different from the iOSApplication or Swift Playgrounds won't open correctly
        targets: [packageLibraryName]
    ),
]

// Targets are the basic building blocks of a package, defining a module or a test suite.
// Targets can depend on other targets in this package and products from dependencies.
var targets = [
	Target.target(
		name: packageLibraryName,
//            dependencies: [
//                .product(name: "Device Library", package: "device")
//            ],
		path: "Sources",
		resources: [
			.process("Resources"),
		]
	),
]

var platforms: [SupportedPlatform] = [ // minimums for Date.now
	.iOS("15.2"),
	.macOS("11.0"),
	.tvOS("14.0"),
	.watchOS("6.0"),
]

#if os(visionOS)
platforms += [
    .visionOS("1.0"), // unavailable in Swift Playgrounds
]
#endif

#if canImport(AppleProductTypes) // swift package dump-package fails because of this
import AppleProductTypes

products += [
	.iOSApplication(
		name: packageLibraryName, // needs to match package name to open properly in Swift Playgrounds
		targets: ["\(packageLibraryName)TestAppModule"],
		teamIdentifier: "3QPV894C33",
		displayVersion: version,
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
		// is this necessary for Device?
//            capabilities: [
//                .outgoingNetworkConnections()
//            ],
		appCategory: .developerTools
	),
]

targets += [
	.executableTarget(
		name: "\(packageLibraryName)TestAppModule",
		dependencies: [
			.init(stringLiteral: packageLibraryName), // have to use init since normally would be assignable by string literal
		],
		path: "Development",
//			exclude: ["Device.xcodeproj/*"],
		resources: [
			.process("Resources")
//		],
//		swiftSettings: [
//			.enableUpcomingFeature("BareSlashRegexLiterals")
		]
	),
	.testTarget(
		name: "\(packageLibraryName)Tests",
		dependencies: [
			.init(stringLiteral: packageLibraryName), // have to use init since normally would be assignable by string literal
		],
		path: "Tests"
	),
]

#endif // for Swift Package compiling for https://swiftpackageindex.com/add-a-package

let package = Package(
    name: packageLibraryName,
    platforms: platforms,
    products: products,
    // include dependencies
//    dependencies: [
//        .package(url: "https://github.com/kudit/Device", "2.1.4"..<"3.0.0")
//    ],
    targets: targets
)
