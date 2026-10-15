# kira-mobile-ios

**Kira**, a personal-finance companion for iPhone: SwiftUI, Swift 6, iOS 17 and later. The app's
logic lives in the `Packages/AppCore` Swift package, tested with `swift test`; the app target holds
the composition root and the views.

## Getting started

Prerequisites: Xcode 27.0, SwiftLint 0.65.1 (`brew upgrade swiftlint`; `.swiftlint.yml` pins it)
and Node 20 or newer for the check scripts.

```bash
git config core.hooksPath .githooks   # the pre-commit gate, once per clone
open Kira.xcodeproj                    # or: bash scripts/ios/app.sh build
```

| Command | What it does |
| --- | --- |
| `bash scripts/ios/app.sh build` | Builds for the simulator, unsigned, failing on any warning |
| `bash scripts/ios/app.sh test` | The UI tests, the accessibility audit among them |
| `bash scripts/ios/api-client.sh` | Regenerates the API client from the backend's spec copy |
| `bash scripts/check/gates.sh` | Every pre-commit gate, as CI runs them |

## The API client

`Packages/AppCore/Sources/APIClient/openapi.json` is a copy of `kira-backend`'s exported spec, and
`GeneratedSources/` is generated from it by swift-openapi-generator. When the backend changes its
contract: copy its `openapi.json` here, run `bash scripts/ios/api-client.sh`, and map any new error
code in `ProblemCode` (`bash scripts/check/error-codes.sh` says which). Never edit either by hand.

## Branches and releases

`internal/{scope}` → `dev` → `prod`. The quality gate runs on every pull request; a merge into
`prod` sends an Ad Hoc build to the Firebase testers (`docs/firebase-app-distribution.md`). Never
push to `dev` or `prod` directly.
