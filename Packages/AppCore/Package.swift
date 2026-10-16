// swift-tools-version: 6.2
/**
 The app's logic, tested by `swift test` on the Mac without a simulator (AGENTS.md Rules 1, 2, 21
 and 22; .claude/rules/ios/packages.md). Setup created this file once; it is yours now.

 Add a target together with its first source file and its test target, and list it under
 "layers" in scripts/check/package-graph.json:
   Domain     pure values and rules: imports Foundation only
   APIClient  AppProblem, the generated client (internal) and the `package` calls screens use,
              beside the backend's spec copy and the generator's settings
   Features   one @Observable screen model per screen: imports Observation, never SwiftUI
 Every remote package is pinned with `exact:` and Package.resolved is committed.
 */
import PackageDescription

let logic: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "AppCore",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "Features", targets: ["Features"]),
    ],
    dependencies: [
        /** Its CLI regenerates Sources/APIClient/GeneratedSources (scripts/ios/api-client.sh). */
        .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.14.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", exact: "1.13.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", exact: "1.3.2"),
    ],
    targets: [
        .target(name: "Domain", swiftSettings: logic),
        .testTarget(name: "DomainTests", dependencies: ["Domain"], swiftSettings: logic),
        .target(
            name: "APIClient",
            dependencies: [
                "Domain",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            swiftSettings: logic
        ),
        .testTarget(name: "APIClientTests", dependencies: ["APIClient", "Domain"], swiftSettings: logic),
        .target(name: "Features", dependencies: ["Domain", "APIClient"], swiftSettings: logic),
        .testTarget(
            name: "FeaturesTests", dependencies: ["Features", "Domain", "APIClient"], swiftSettings: logic),
    ],
    swiftLanguageModes: [.v6]
)
