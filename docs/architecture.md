# Architecture: Folders

Kira is MVVM, and its folders say which layer a file belongs to. Every layer uses the same area
names, so a feature's files are found in the same place in each layer:

Onboarding, Home, Score, Record, History, Import, Account, Plans, Plan, Lock, Community, Care, Budget,
Bills, Navigation, Session, Shared. `Plans` is Paket Kira and Beasiswa Kira; `Plan` is Rencana (the
tab, its goals, the calculators, the risk quiz and Portofolio Manual).

`Shared` holds what several areas use (money, dates, transactions, the six-digit code, the payday
sheet). An area folder is created only when it has a file.

Dompet, Budget & Tagihan (UNG) is split by feature like the others: `Budget` (Atur Budget, UNG-05)
and `Bills` (Tagihan & Cicilan, UNG-07) now, and `Wallets` (Dompet) and `WeeklySummary` (Ringkasan
Mingguan) when their screens land.

## Layers

| Layer | Folder | Holds |
| --- | --- | --- |
| Model | `Packages/AppCore/Sources/Domain/<Area>/Models/` | Entities and value types |
| Model | `Packages/AppCore/Sources/Domain/<Area>/Logic/` | Rules that are not a model: parsers, calculators, detectors, formatters, policies |
| ViewModel | `Packages/AppCore/Sources/Features/<Area>/ViewModels/` | The `@Observable` screen models, with the state types they expose (phases, steps, rows, routes) and their helpers |
| ViewModel | `Packages/AppCore/Sources/Features/<Area>/Services/Protocols/` | The area's service protocols and the device capabilities its models ask for |
| ViewModel | `Packages/AppCore/Sources/Features/<Area>/Services/Live/` | The live implementations: the API-backed services, their DTO-to-Domain mapping, and the stores kept on the device |
| API | `Packages/AppCore/Sources/APIClient/` | `KiraAPI` and its per-tag extensions, the hand-written DTOs, `AppProblem`, the spec copy, and `GeneratedSources/` |
| View | `App/Screens/<Area>/Views/` | Screens, sheets and flows: what is pushed or presented |
| View | `App/Screens/<Area>/Components/` | The subviews those screens are built from |
| View | `App/Screens/<Area>/Copy/` | The words and display names a screen writes for Domain values (`+Display`, `+Message`, copy tables) |
| View | `App/Screens/<Area>/Preview/` | The preview service and samples the previews and `-KiraScreen` use (debug only) |
| App | `App/Services/<Area>/` | Device services (camera, speech, Vision, Foundation Models, Keychain) and the composition of each area's services |
| App | `App/Launch/` | The debug-only `-KiraScreen` launcher, one file per area |
| App | `App/DesignSystem/` | Tokens, type, artwork, the `Kira…` components and the gallery |

The module names (`Domain`, `Features`, `APIClient`) do not change. SwiftPM compiles every file
under a target's folder, and the app target is an Xcode synchronized folder, so moving a file within
these folders needs no project or manifest edit.

## Rules

- **No loose files beside folders.** A folder holds files or folders, never both (SHAPE-1, checked
  by `scripts/check/folder-shape.mjs` in Packages/AppCore). That is why `Services/` holds `Protocols/`
  and `Live/` instead of loose protocol files.
- **Tests mirror their sources.** `Domain/Shared/Models/CalendarDay.swift` is tested by
  `Tests/DomainTests/Shared/Models/CalendarDayTests.swift` (SHAPE-2). Fakes, fixtures and samples go
  in `Tests/FeaturesTests/{Mocks,Fixtures,Support/<Area>}/`, never beside the tests (SHAPE-4).
- **APIClient stays flat.** The OpenAPI generator reads `openapi.json` and
  `openapi-generator-config.yaml` from the target's root, so area subfolders there would leave loose
  files beside folders. Its files are named for their area instead (`AccountAPI`, `AccountModels`).
- **UITests stay flat.** There is one `<Area>AuditTests.swift` per area beside `ScreenAudit.swift`.

## Where new code goes

A Community screen, for example:

- its entities: `Domain/Community/Models/`, and any parser or detector: `Domain/Community/Logic/`;
- its screen model: `Features/Community/ViewModels/`;
- its service protocol: `Features/Community/Services/Protocols/`;
- the live service and its DTO mapping: `Features/Community/Services/Live/`;
- its DTOs and API extension: `APIClient/CommunityAPI.swift` and `APIClient/CommunityModels.swift`;
- the screen: `App/Screens/Community/Views/`, with its parts in `Components/`, its words in `Copy/`
  and its preview service in `Preview/`;
- its launcher: `App/Launch/CommunityLaunch.swift`;
- its audits: `UITests/CommunityAuditTests.swift`;
- tests at the mirror of each source under `Tests/DomainTests/` and `Tests/FeaturesTests/`.
