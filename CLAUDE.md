# Kira (iOS)

Kira is a personal-finance companion for people in Indonesia: record spending by chat, check your
financial health, and plan ahead. SwiftUI app, Indonesian copy, iPhone only.

Done means `bash scripts/check/gates.sh` passes: the list pre-commit and CI run. Build and test the
app through `bash scripts/ios/app.sh`, which picks the simulator and never signs.

## Decisions to keep

- Bundle ID `com.kira` (UI tests `com.kira.uitests`); if Apple refuses `com.kira` as taken, use
  `com.serenitycode.kira` (UI tests `com.serenitycode.kira.uitests`). The backend is `kira-backend`
  (`https://api-kira.serenitycode.tech`), whose `openapi.json` is copied into
  `Packages/AppCore/Sources/APIClient/`.
- String Catalogs: source language `id`, Indonesian only (`App/Localizable.xcstrings`).
- Releases: a merge into `prod` goes to Firebase App Distribution
  (`.github/workflows/firebase-distribution.yml`); the app embeds no Firebase SDK.
- No CI env file: `scripts/check/ci-env.sh` is owned here (`agent-sync own`) and runs the tests with
  no variable.
- Kit workarounds for the gate's macOS job: `scripts/check/secrets.sh` is owned and passes there
  without gitleaks (the Linux job scans the PR); SwiftLint's gates.list line is `swiftlint --quiet`,
  so it runs on macOS only (swiftlint-static aborts on custom rules).
- Comments are written `/** … */`, never `//` or `///` (AGENTS.md Rule 34, SwiftLint
  `no_line_comment`), in code and in the code examples of the docs. Line comments remain only where a
  tool reads one: the `// swift-tools-version:` line, `// swiftlint:` and `// periphery:ignore`
  directives, and generated code. The xcconfig files, which accept only `//`, carry no comments;
  `docs/build-settings.md` explains each setting.

## On-demand references

| Read when | File |
| --- | --- |
| Citing or checking a numbered rule | `AGENTS.md` |
| Changing or reviewing a build setting in `Config/*.xcconfig` | `docs/build-settings.md` |
| A failure that looks familiar | `.claude/anti-patterns/INDEX.md` |
| Xcode's own tools (previews, build log) for one session | `.claude/mcp/xcode.example.json` |
| Hooks, CI, reviews, MCP pins, releases | `.claude/OPERATIONS.md` |
| Signing, Firebase and the distribution workflow's inputs | `docs/firebase-app-distribution.md` |
| Building a screen from the design: tokens, type, `Kira…` components, assets | `docs/design-system.md` |

<!-- >>> agent-config-kit: managed by /agent-core:setup and sync; edit outside this block -->
## Agent config kit

<!-- agent-config-kit/agent-core -->
### Guardrails and workflow (agent-core)

- The kit's hooks run here while `.claude/agent-config-kit.lock` exists. A hook refusal or a deny
  rule is never argued away: hand the command to the user to run with `!`.
- `.env*` files: list one with `bash scripts/env/show.sh <file>` (secrets masked); change a value
  with `scripts/env/set.sh <file> <KEY>` (value on stdin), which works only while the user has
  unlocked `env`. Only the user unlocks `env` or `db` (`docs/unlock.md`).
- Commit by pathspec (`git commit -- <paths>`); only `/agent-core:ship` stages everything.
- Flow: `/agent-core:plan` → `/agent-core:review` → `/agent-core:commit` →
  `/agent-core:create-pr` → `/agent-core:merge-pr`. `/agent-core:help` lists every command.
- `/agent-core:sync --check` reports drift from what setup installed.

<!-- agent-config-kit/agent-deploy -->
### Deploys (agent-deploy)

- Deploy target and adapter: `.claude/OPERATIONS.md` § Deploys. Only the user starts
  `/agent-deploy:verify-deploy` and `/agent-deploy:promote-deploy`. A deploy counts once a deployment
  created after the merge has finished; an accepted webhook or a green CI run is not that proof.
- `scripts/deploy/*.sh` use the network, so Claude asks first. The user runs `trigger-deploy.sh`,
  whose webhook URL is a secret, in their own terminal.

<!-- agent-config-kit/agent-ios-swiftui -->
### iOS app (agent-ios-swiftui)

- Rules: `AGENTS.md`; traps: `.claude/anti-patterns/INDEX.md`. Review with the
  `agent-ios-swiftui:reviewer` and `agent-ios-swiftui:i18n-guard` subagents.
- The API client is generated from the backend's spec copy: refresh it with
  `bash scripts/ios/api-client.sh`; the `generated-guard` hook refuses hand edits to either.
<!-- <<< agent-config-kit -->
