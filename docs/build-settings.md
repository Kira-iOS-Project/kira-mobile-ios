# Build settings

The app project's build settings live in `Config/*.xcconfig` (AGENTS.md Rules 19, 20 and 28).
The project file keeps only target identity; a setting lives in these files, or in a target's own
xcconfig when only that target needs it. An xcconfig file accepts only `//` line comments, and the
repository writes no line comments (AGENTS.md Rule 34), so the files hold settings alone and this
page says why each one is there. `scripts/check/xcode-settings.sh` reads `Base.xcconfig` through
`Debug.xcconfig` and `Release.xcconfig`, which the project's configurations name as their base.

Never put a secret in an xcconfig: every value reaches the built app (Rule 28, check X5).

## `Config/Base.xcconfig`

Shared by every target of the app project, in Debug and Release.

### Swift language and warnings (Rule 19)

| Setting | Value | Why |
| --- | --- | --- |
| `SWIFT_VERSION` | `6.0` | Swift 6 language mode: data races are compile errors (check X3) |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` | Approachable concurrency (check X3) |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` | The app's code runs on the main actor unless it says otherwise; the logic package sets its own, nonisolated, default (check X3) |
| `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY` | `YES` | A file sees only the members of the modules it imports |
| `SWIFT_TREAT_WARNINGS_AS_ERRORS` | `YES` | A build ends with zero warnings (check X3) |
| `GCC_TREAT_WARNINGS_AS_ERRORS` | `YES` | The same for C and Objective-C sources |

### The logic package (Rule 1)

| Setting | Value | Why |
| --- | --- | --- |
| `SWIFT_PACKAGE_NAME` | `appcore` | The app's targets join `Packages/AppCore`'s package (SwiftPM names it after its folder, lowercased), so they call its `package` API and nothing in it has to be `public` (check X3) |

### Platform

| Setting | Value | Why |
| --- | --- | --- |
| `IPHONEOS_DEPLOYMENT_TARGET` | `17.0` | The oldest iOS the app supports, the setup answer `min-ios`: the floor of Observation and of the accessibility audit the UI tests run. Keep `.iOS(...)` in `Packages/AppCore/Package.swift` equal to it (check X3) |
| `SDKROOT` | `iphoneos` | An iOS app |
| `SUPPORTED_PLATFORMS` | `iphoneos iphonesimulator` | Devices and the simulator |
| `TARGETED_DEVICE_FAMILY` | `1` | iPhone only: every screen is designed for a phone, and iPads run the app in compatibility mode |

### Strings and assets (Rules 5 to 7)

| Setting | Value | Why |
| --- | --- | --- |
| `LOCALIZATION_PREFERS_STRING_CATALOGS` | `YES` | Text lives in String Catalogs |
| `SWIFT_EMIT_LOC_STRINGS` | `YES` | The compiler extracts the keys the code uses |
| `STRING_CATALOG_GENERATE_SYMBOLS` | `YES` | Manual keys get generated symbols |
| `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` | `YES` | Each colour token is a symbol: `.foregroundStyle(.inkMuted)` |
| `ASSETCATALOG_COMPILER_APPICON_NAME` | `AppIcon` | The app icon is the design system's 1024 px square; iOS applies the mask |
| `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME` | `AccentColor` | Pandan is the accent of system controls |

### Build hygiene

| Setting | Value | Why |
| --- | --- | --- |
| `ENABLE_USER_SCRIPT_SANDBOXING` | `YES` | Build scripts run sandboxed |
| `GENERATE_INFOPLIST_FILE` | `YES` | Xcode writes the Info.plist from build settings |
| `ALWAYS_SEARCH_USER_PATHS` | `NO` | Headers resolve only through explicit search paths |
| `INFOPLIST_KEY_NSCameraUsageDescription` | Indonesian sentence | Why Scan Struk asks for the camera (CAT-05): the photo is read on the phone and deleted |
| `INFOPLIST_KEY_NSMicrophoneUsageDescription` | Indonesian sentence | Why Input Suara asks for the microphone (CAT-10): the voice becomes text and is deleted |
| `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription` | Indonesian sentence | Why Input Suara asks for speech recognition, which runs on the device only |

## `Config/Debug.xcconfig`

The Debug configuration: `Base.xcconfig` (through `#include`) plus what a debug build needs. Link it
as the project's Debug base configuration (setup's by-hand step); `xcode-settings.sh` checks the
link (check X1).

| Setting | Value | Why |
| --- | --- | --- |
| `DEBUG_INFORMATION_FORMAT` | `dwarf` | Fast debug builds without a dSYM |
| `ENABLE_TESTABILITY` | `YES` | Tests reach internal symbols with `@testable import` |
| `ONLY_ACTIVE_ARCH` | `YES` | Builds only the architecture being run |
| `SWIFT_ACTIVE_COMPILATION_CONDITIONS` | `DEBUG $(inherited)` | `#if DEBUG` code, such as the design system gallery, compiles in Debug only |
| `SWIFT_OPTIMIZATION_LEVEL` | `-Onone` | Debuggable Swift |
| `GCC_OPTIMIZATION_LEVEL` | `0` | Debuggable C and Objective-C |

## `Config/Release.xcconfig`

The Release configuration: `Base.xcconfig` (through `#include`) plus what a shipped build needs.
Link it as the project's Release base configuration (setup's by-hand step); `xcode-settings.sh`
checks the link (check X1).

| Setting | Value | Why |
| --- | --- | --- |
| `DEBUG_INFORMATION_FORMAT` | `dwarf-with-dsym` | A dSYM, so crash reports symbolicate |
| `SWIFT_COMPILATION_MODE` | `wholemodule` | Whole-module optimization for the shipped build |
| `VALIDATE_PRODUCT` | `YES` | Xcode validates the built product |
