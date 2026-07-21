// swift-tools-version:6.0
// This Package.swift is for SourceKit-LSP support only.
// Build and run using Xcode/xcodebuild with Sniffify.xcodeproj

import PackageDescription

let package = Package(
	name: "Sniffify",
	platforms: [
		.iOS(.v18),  // SPM doesn't support iOS 26 yet, but this is only for LSP
		.macOS(.v14),  // Required for SPM to build/index on Mac
	],
	products: [
		.library(name: "Sniffify", targets: ["Sniffify"])
	],
	dependencies: [
		// Add your SPM dependencies here (must also add to Xcode project separately)
	],
	targets: [
		.target(
			name: "Sniffify",
			dependencies: [],
			path: "Sniffify",
			exclude: ["Assets.xcassets"],
			swiftSettings: [
				.swiftLanguageMode(.v5)
			]
		)
	]
)
