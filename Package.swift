// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "GlobPattern",
	products: [
		.library(name: "GlobPattern", targets: ["GlobPattern"]),
	],
	dependencies: [
	],
	targets: [
		.target(name: "GlobPattern", dependencies: []),
		.testTarget(name: "GlobPatternTests", dependencies: ["GlobPattern"]),
	]
)
