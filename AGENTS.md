# AGENTS.md: Kira iOS app

The numbered rules of this repo. Each row states the rule once and names what enforces it: a
SwiftLint rule, a check script, the compiler, a CI step, or `reviewer` (the
`agent-ios-swiftui:reviewer` subagent and code review; no machine checks it). How to follow a rule,
with examples, is in the file of the Detail column, which loads while you edit the files it covers.

Numbers are append-only: a new rule takes the next free number, and a retired one keeps its number
with the word "Retired". A citation such as "Rule 12" must mean one thing to every reader, and
`scripts/check/ai-config.sh` fails a citation this table does not define.

## Compliance status: fill this in first

Rules adopted after the code was written describe a target, not the code. Say which, per group, so
an agent never cites a rule for code that does not exist yet. Three states: Enforced, Partial (name
the rules that bind), Not met (name the shape to follow until it is).

| Rules | Group | Status | What that means here |
| --- | --- | --- | --- |
| 1–4 | Architecture | Enforced | Every built screen has its `@Observable` model in `Features/<Area>/ViewModels/` (Navigation, Session, Lock, Onboarding, Home, Score, Record, History, Import, Account, Plans) and its view in `App/Screens/<Area>/Views/` (layout in `docs/architecture.md`); helpers two areas share live once in `App/Screens/Shared/`. Each area's entry view still waits in its slot in `App/Screens/Navigation/Components/AreaSlots.swift` until the root wires it (follow-up 2). |
| 5–9 | Text and locale | Enforced | Indonesian only: the catalogs' source language is `id`, so every key carries its `id` text (setup answered `locales=en`, the single-language option). |
| 10–14 | Network, errors and auth | Partial | Rules 10–13 bind: the client is generated from the backend's spec, `ProblemCode` equals its codes, `KiraAPI` has a `package` call for every tag the screens use, and `SessionStore` keeps the refresh token in the Keychain (`KeychainVault`) and the bearer token in memory, served to the client by `AuthMiddleware`. Screens reach the API through their area's service protocol (`HomeService`, `RecordService`, `HistoryService`, …), which runs on a preview service until the live implementations land (follow-ups 2 and 3); the codes those calls add to `ProblemCode` arrive with them. |
| 15–18 | Code shape | Enforced | Applies as written. |
| 19–21 | Build and dependencies | Enforced | Applies as written. |
| 22–24 | Tests and coverage | Partial | Rules 22 and 23 bind: every logic file at 100%, Swift Testing only. Rule 24 binds for the root and the lock screen (`-KiraLocked`, debug only); the other primary screens get their audit test with follow-up 4. |
| 25–28 | Platform and release | Enforced | Releases go to Firebase App Distribution from `prod` (`docs/firebase-app-distribution.md`). |
| 29–33 | Payload contract (only with `payload-encryption=yes`; otherwise N/A) | N/A | Setup answered `payload-encryption=no`: bodies rely on TLS. |

Follow-up work, in order, each naming the rules it unblocks:

1. ~~The design system (colours, type, the logo and the app icon)~~: done 2026-10-16. Tokens, fonts,
   artwork and the `Kira…` components are in `App/DesignSystem/` and `App/Assets.xcassets/`;
   `docs/design-system.md` maps each design component to its SwiftUI type
2. In progress (E1): the live services and `RootView`. The generated client implements each area's
   service protocol, the session refreshes through it, and the root puts each area's entry view in
   its slot: unblocks Rules 10–13 in practice
3. In progress (E2): Catat on the live API (chat, drafts, receipts, voice, quota), on the same
   client: Rules 10–13 for Catat
4. In progress (A1): an accessibility-audit UI test per primary screen, each reached with a debug
   `-KiraScreen <name>` launch argument: Rule 24 everywhere
5. In progress (R2): Apple's Foundation Models used only where `supportsLocale` says Indonesian is
   supported; on iOS 27 its vision may suggest a receipt's store name, never an amount (README,
   On-device AI). No rule; recorded so a review does not read the gating as missing

## Rules

| # | Rule | Enforced by | Detail |
| --- | --- | --- | --- |
| 1 | The app target holds the composition root and the views; logic lives in the `Packages/AppCore` targets | `package-graph.sh` P1; reviewer | `.claude/rules/ios/packages.md` |
| 2 | Logic targets import Foundation and Observation, never SwiftUI or UIKit; a target imports only the layers `package-graph.json` lists, and features never import each other | SwiftLint `no_ui_import_in_logic`; `package-graph.sh` P2 | `.claude/rules/ios/packages.md` |
| 3 | A view lays out, binds and calls its screen model; I/O, the clock, filtering, sorting and the logic of a `Task {}` live in the model | SwiftLint `no_io_in_view`, `no_clock_in_view`, `no_data_shaping_in_view`; reviewer | `.claude/rules/ios/swiftui.md` |
| 4 | One `@Observable` screen model per screen, exposing one `Phase` enum: `loading`, `empty`, `loaded`, `failed` | reviewer | `.claude/rules/ios/swiftui.md` |
| 5 | Display text a model exposes is a `LocalizedStringResource`; views use catalog keys, and UIKit text comes from `String(localized:)` | SwiftLint `no_text_verbatim`, `no_uikit_literal_text`; reviewer (`Text(String)`) | `.claude/rules/ios/strings.md` |
| 6 | Every String Catalog key has every locale the app ships, in state translated | `i18n-catalog.mjs` I1, I2 | `.claude/rules/ios/strings.md` |
| 7 | Every key the code uses is in its catalog, and the catalog holds only keys the code uses | `i18n-catalog.mjs` I3; I4 against the build in CI | `.claude/rules/ios/strings.md` |
| 8 | Package code names its bundle: `bundle: #bundle` | SwiftLint `package_text_names_bundle` | `.claude/rules/ios/strings.md` |
| 9 | Numbers and dates are formatted with a `FormatStyle` in the view, so they follow the screen's locale | SwiftLint `no_unlocalized_format`; reviewer | `.claude/rules/ios/strings.md` |
| 10 | Requests go through the generated client and its `URLSessionTransport`; route paths exist only in the generated code | SwiftLint `no_route_literal`, `no_urlsession_outside_transport` | `.claude/rules/ios/packages.md` |
| 11 | The generated client and the spec copy change only through `bash scripts/ios/api-client.sh`, and are committed | `generated-guard` hook; client drift check in CI | `.claude/rules/ios/packages.md` |
| 12 | A problem is identified by its `type` (the API's base plus its code): screens switch over `AppProblem.knownCode` with every case listed, show `problem.unknown` with the reference `CODE · requestId` for anything else, and never show `detail` or branch on a status | compiler; SwiftLint `no_default_on_problem_code`, `no_status_branch`; `error-codes.sh` | `.claude/rules/common/error-codes.md` |
| 13 | The refresh token lives in the Keychain (`AfterFirstUnlockThisDeviceOnly`), the bearer token in memory; neither ever reaches `UserDefaults` | SwiftLint `no_token_in_user_defaults`; reviewer | `.claude/rules/ios/packages.md` |
| 14 | The server decides authorization; the app shows what the API returns | reviewer; `agent-core:security-guard` | `.claude/rules/ios/swiftui.md` |
| 15 | A file holds at most 150 code lines (blank and comment lines do not count) | SwiftLint `file_length` | `.claude/anti-patterns/file-length-counts-comments-by-default.md` |
| 16 | A type holds at most 120 lines, a function 40, a closure 30; cyclomatic complexity at most 10 | SwiftLint `type_body_length`, `function_body_length`, `closure_body_length`, `cyclomatic_complexity` | `.swiftlint.yml` |
| 17 | A suppression covers one rule on one line and says why: `// swiftlint:disable:next <rule> - <reason>`; the root `.swiftlint.yml` is the only one, paths go in `.swift-format-ignore`, and `@diagnose` only raises a diagnostic | `superfluous_disable_command`, `blanket_disable_command`; `lint-suppressions.sh` | `.claude/anti-patterns/nested-swiftlint-config-replaces-root.md` |
| 18 | Types are concrete: no `Any` or `AnyObject`, no `as!`, `try!`, force unwrap or implicitly unwrapped optional | SwiftLint `no_any_type`, `force_cast`, `force_try`, `force_unwrapping`, `implicitly_unwrapped_optional` | `.swiftlint.yml` |
| 19 | Swift 6 language mode, approachable concurrency, MainActor default isolation for the app; a build ends with zero warnings | `xcode-settings.sh` X3; warning count of the build (`scripts/ios/app.sh`, CI) | `.claude/anti-patterns/preconcurrency-warnings-escape-werror.md` |
| 20 | Build settings live in `Config/*.xcconfig`; `project.pbxproj` holds no `SWIFT_*` key | `xcode-settings.sh` X1, X2 | `.claude/rules/ios/swiftui.md` |
| 21 | Remote packages are pinned with `exact:` and `Package.resolved` is committed; a build-tool plugin or a macro needs a written decision | `package-graph.sh` P4, P5; CI resolves only from `Package.resolved` | `.claude/rules/ios/packages.md` |
| 22 | Every file of the logic targets is covered to 100% of its lines and functions, and every library target has its test target | `coverage.sh` + `coverage-per-file.mjs`; `package-graph.sh` P3; the coverage floor in CI | `.claude/rules/swift/coverage.md` |
| 23 | Tests use Swift Testing, share no mutable state, give `.serialized` a reason, and never retry | reviewer; the gate never passes `-retry-tests-on-failure` | `.claude/rules/ios/testing.md` |
| 24 | Every primary screen has a UI test that runs `performAccessibilityAudit` | `/agent-ios-swiftui:a11y-audit`; reviewer; the UI tests in CI | `.claude/rules/ios/testing.md` |
| 25 | The privacy manifest declares every required-reason API category the code uses, with its reason | `privacy-manifest.sh` | `.claude/rules/ios/swiftui.md` |
| 26 | Logs go through `os.Logger` | SwiftLint `no_print` | `.claude/rules/ios/packages.md` |
| 27 | Code nothing uses is deleted | Periphery `--strict` in CI | `.claude/rules/swift/dead-code.md` |
| 28 | Secrets stay out of the app: none in the bundle, the app's property list or an xcconfig; App Transport Security stays on | gitleaks (`secrets.sh`); `xcode-settings.sh` X4, X5 | `.claude/rules/ios/swiftui.md` |
| 29 | Every operation the client calls is in the generated payload registry, written only by `node scripts/generate/payload-registry.mjs`; an unregistered one is refused before it is sent. Rules 29 to 33 apply when setup answered `payload-encryption=yes` | `payload-registry.mjs`; `PayloadMiddlewareTests` | `.claude/rules/ios/payload.md` |
| 30 | Bodies are sealed and opened only in `PayloadMiddleware`, the last of the client's middlewares; the payload types stay `internal` | compiler; reviewer | `.claude/rules/ios/payload.md` |
| 31 | The app holds no payload secret: one key is agreed per session from the handshake, kept in memory only and never pinned, and a Release build never accepts `off` | `PayloadSessionTests`, `PayloadMiddlewareTests` | `.claude/rules/ios/payload.md` |
| 32 | An `ENVELOPE_*` failure reaches screens through the one error mapper, `AppProblem(failure:)`, as the problem of its code, which `ProblemCode` lists | compiler; `error-codes.sh` | `.claude/rules/ios/payload.md` |
| 33 | The cipher, its AAD and the key agreement pass the shared vectors in `scripts/check/payload-vectors.json`, which are never regenerated to pass | `PayloadVectorsTests` | `.claude/rules/common/payload-contract.md` |
| 34 | Comments are block comments: `/** Summary. */` on one line, or `/**` and ` */` around lines with no leading `*`; a trailing note is `/** note */`. Code examples in the docs follow it too. A line comment (`//`, `///`) remains only where a tool reads one: the `// swift-tools-version:` line, `// swiftlint:` and `// periphery:ignore` directives, and generated code; the xcconfig files, which accept only `//`, carry no comments (`docs/build-settings.md` explains each setting) | SwiftLint `no_line_comment`; swift-format with `UseTripleSlashForDocumentationComments` and `NoBlockComments` off; reviewer for the docs | `.swiftlint.yml`, `docs/build-settings.md` |
| 35 | Identifiers are English: types, properties, functions, parameters, enum cases and raw values, file names, asset catalog folders and image and colour set names, gallery pages and launch arguments, test names and String Catalog keys. Indonesian appears only in the catalog's translations (source language `id`) and in the names a person reads there; `docs/design-system.md` maps each artifact name to its English one | `english-names.mjs` (a heuristic denylist of the design vocabulary); reviewer | `docs/design-system.md` (Names) |
