# Kira design system on iOS

The SwiftUI implementation of the Kira design system. The source of truth is the design system
artifact ([claude.ai/artifact/MQa6sNVYYc1xPFmRgZhF6F](https://claude.ai/artifact/MQa6sNVYYc1xPFmRgZhF6F),
type "Design System"; this implementation follows its version `1792080087-37bd`, `tokens.json`
version 6, last changed 15 October 2026). When a ticket names a component (`Kira.Button`,
`ListRow`, `DraftCard`), the table under [Components](#components) gives its SwiftUI type.

| Where | What |
| --- | --- |
| `App/Assets.xcassets` | Colour sets (every token, light and dark), the app icon, artwork image sets |
| `App/Fonts/` | Plus Jakarta Sans (variable) and Kalam, each beside its `OFL.txt` |
| `App/DesignSystem/Tokens/` | Spacing, radius and size scales; the hairline and card modifiers |
| `App/DesignSystem/Typography/` | Font registration and the text styles |
| `App/DesignSystem/Artwork/` | Icon, Logo, Mascot, CategoryIcon, Illustration, Leaf, Scenery, HandNote |
| `App/DesignSystem/Components/` | The components, by group: Controls, Content, Score, Lists, Navigation, Dialog, Chat |
| `App/DesignSystem/Layout/` | Row separators, the wrapping row (chips), the weighted row, the scroll edges |
| `App/DesignSystem/Gallery/` | The debug-only gallery of every component |
| `Packages/AppCore/Sources/Domain/` | `RupiahFormatStyle`, `Score`, `ScoreBand`, `DigitCode`: logic, tested at 100% |

## Rules every screen keeps

These come from the design system and the product owner; the components already follow them, and
a screen built from them keeps them by default.

- **No purple, no shadow of any kind.** Depth is a 1 pt hairline plus the surface colour: never
  `.shadow()`. The dock is the only glass, and it is the `glass` token over a material blur rather
  than iOS 26's `.glassEffect()`, whose highlights the design system does not draw.
- **Cards and badges always have a 1 pt border**: `.kiraCard()` and the components do it.
- **Buttons are capsules with Title Case labels.** Non-primary buttons use `button` with a
  `button-line` border. A pair is `KiraButtonPair`: secondary on the left, primary on the right
  (stacked, primary on top). Back buttons are icon-only (`KiraIconButton.back`).
- **Title Case** for titles, headings, notice titles, tags and buttons; Indonesian prepositions and
  conjunctions (dari, di, ke, dan, untuk, yang, terhadap) stay lowercase. Small labels, overlines
  and sentences stay sentence case. The catalog holds the cased copy: no code changes case.
- **Money in full with two decimals**: `Rp10.000,00`, through `RupiahFormatStyle` or `KiraAmount`.
  A big amount sits alone on its line with its words in a small label above it.
- **The right side of a row is for actions only** (chevron, toggle, check, an outside link):
  amounts, values and tags go under the title.
- **Red (`emergency`, the artifact's `darurat`) only for the 119 call and reporting**; `destructive`
  (`bahaya`, terracotta) confirms deletions.
- **At most one handwritten note per screen**, anchored to a section title, an illustration or the
  splash.
- **Glass only on the dock.** A scrolling screen calls `.kiraScrollEdges()`: from iOS 26 a scroll
  view blurs its top and bottom edges, which is glass (and fades text the accessibility audit then
  reads as low contrast); the modifier hides that effect and lays a solid `surface` band behind the
  status bar.

## Tokens

### Colour

Every colour token of `tokens.json` is a colour set in `App/Assets.xcassets/Tokens/`, under its
English name (the artifact's Indonesian names map in [Names](#names-the-artifacts-words-and-the-swift-ones)),
with its light and dark value (the design system defines both themes, so
dark mode follows the device). Xcode generates a symbol per set, so a token is used by name:

```swift
Text("home.title").foregroundStyle(.ink)
VStack { ... }.background(.surface)
Capsule().fill(.pandanSoft)
```

The generated name is the token in lowerCamelCase: `surface-raised` → `.surfaceRaised`,
`hero-nature-2` → `.heroNature2`, `art-turmeric-light` → `.artTurmericLight`. `AccentColor` is pandan, so
the cursor and system selections carry the accent. The groups: surfaces (`surface`,
`surface-raised`, `surface-muted`, `button`, `button-line`, `track`, `line`, `hairline`,
`line-strong`), text (`ink`, `ink-muted`), accent (`pandan`, `pandan-strong`, `pandan-soft`,
`pandan-line`, `on-pandan`), the hero card (`hero`, `on-hero`, `on-hero-muted`, `hero-track`,
`hero-accent`, `hero-nature`, `hero-nature-2`), the Kira Score bands (`healthy`, `coping`,
`vulnerable`, each with `-soft` and `-line`), `emergency`, `emergency-soft`, `on-emergency`, `glass`,
`scrim`, and the illustration paints (`art-*`), which are for artwork only, never text or buttons.

### Spacing, radius, size

| Design system | Swift |
| --- | --- |
| `space-1` … `space-10` (4, 8, 12, 16, 20, 24, 32, 40) | `KiraSpacing.space1` … `KiraSpacing.space10`; the screen margin is `KiraSpacing.screen` (16) |
| `radius-xs`, `-sm`, `-md`, `-lg`, `-xl`, `-full` (6, 12, 18, 24, 30, capsule) | `KiraRadius.extraSmall`, `.small`, `.medium`, `.large`, `.extraLarge`, `.full` |
| `size-tap`, `size-icon`, `size-tile` (44, 24, 40) | `KiraSize.tap`, `.icon`, `.tile` |

Corners are continuous. `.kiraCard(_ fill:, border:, cornerRadius:)` draws a card (fill, then a
hairline inside the shape); `.hairline(_:cornerRadius:)` and `.capsuleHairline(_:)` draw the border
alone.

## Typography

- **Plus Jakarta Sans** (Tokotype; the variable font, weights 200–800) for numbers and titles,
  **Kalam** for the handwritten note, and **SF Pro** (the system font) for all other text, as the
  design system's `text` family says. Both bundled fonts are under the SIL Open Font License 1.1,
  downloaded from [google/fonts](https://github.com/google/fonts) at commit
  `1d0e46c7933245c8180fe83e47917961c913bbdb` (`ofl/plusjakartasans/PlusJakartaSans[wght].ttf`,
  renamed `PlusJakartaSans-VariableFont_wght.ttf`, and `ofl/kalam/Kalam-Regular.ttf`). Each
  `OFL.txt` sits beside its font; both stay out of the app bundle (two files of one name would
  collide there), and each font file carries the licence in its own name table.
- `KiraFont` registers the files with `CTFontManagerRegisterFontsForURL` on first use, which also
  covers Xcode previews (no `UIAppFonts` entry is needed).
- Every style scales with Dynamic Type: display styles use `Font.custom(_:size:relativeTo:)`, text
  styles are the iOS ones. Apply one with `.kiraFont(_:)`:

```swift
Text("score.title").kiraFont(.largeTitle)
Text(note).kiraFont(.hand)
```

| Design system | `KiraTextStyle` | Font, scaled like |
| --- | --- | --- |
| `t-score` | `.score` | Plus Jakarta Sans 64 ExtraBold, tabular, `.largeTitle` |
| `t-amount-xl` | `.amountXL` | Plus Jakarta Sans 40 ExtraBold, tabular, `.largeTitle` |
| `t-large-title` | `.largeTitle` | Plus Jakarta Sans 34 ExtraBold, `.largeTitle` |
| `t-title` | `.title` | Plus Jakarta Sans 20 Bold, `.title3` |
| `t-amount` | `.amount` | Plus Jakarta Sans 20 Bold, tabular, `.title3` |
| `t-headline` | `.headline` | `.headline` (17 Semibold) |
| `t-body` | `.body` | `.body` (17) |
| `t-callout` | `.callout` | `.subheadline` (15) |
| `t-footnote` | `.footnote` | `.footnote`, Medium (13) |
| `t-caption` | `.caption` | `.caption`, Medium (12) |
| `t-overline` | `.overline` | `.caption2` (11), Bold, capitals, tracked 0.08 em |
| `t-formula` | `.formula` | `.footnote` monospaced, Medium (13) |
| `t-hand` | `.hand` | Kalam 19, `.body` |
| `t-hand-sm` | `.handSmall` | Kalam 16, `.subheadline` |

The design system uses CSS weights 650 and 750, which SwiftUI cannot name (`Font.Weight` has no
public initializer from a number): 650 maps to Semibold and 750 to ExtraBold (`.heavy`). Letter
spacing follows the tokens.

Line heights follow the design system (`kiraLineHeight(_:size:)`, applied by `kiraFont` and the
components): where the CSS line is taller than the font's own (every SF Pro size), iOS 26 and
later set it on every line, so a 17 pt line is 22 pt as in the artifact (iOS 17 and 18 keep the
system's, 1 to 2 pt shorter). Plus Jakarta Sans (1.26 em) and Kalam (1.59 em) have taller natural
lines than the CSS values; their text keeps its own line, which Apple's accessibility audit needs,
and gives the difference back as negative padding, so it takes the artifact's height in layout.

The sizes are the artifact's, including the ones below what Apple's accessibility audit accepts as
full Dynamic Type support: the 11 pt overline (Caption 2), the medium amount's 11 pt "Rp" and
",00", the dock's 10 pt "Catat" and the bars' 11 pt caption. The audit reports each as "Dynamic
Type font sizes are partially unsupported". They carry the accessibility identifier
`kira.small-type`, and the gallery's audit test lists these findings apart: the owner keeps the
artifact's sizes, an accepted deviation from the audit.

## Money and the Kira Score (Domain)

`RupiahFormatStyle` (in the `Domain` target, tested at 100%) writes rupiah the one way Kira does:
`Rp10.000,00`, negative `−Rp10.000,00`, rounded half away from zero to two decimals. The format is a
product rule, not a regional preference, so it does not change with the device's region. Use it as
any `FormatStyle`, in the view:

```swift
Text(amount, format: .rupiah) /** Rp10.000,00 */
Text(amount, format: .rupiah.sign(.always)) /** +Rp10.000,00 */
Text(amount, format: .rupiah.masked(isHidden)) /** Rp •••••• */
```

`.part(_:)` returns one piece (sign, symbol, integer, fraction), which `KiraAmount` uses to size
"Rp" and ",00" apart. Amounts are `Decimal`. `Score` clamps a 0–100 value (the Kira Score or an
indicator's points) and names its `ScoreBand`: Rentan 0–39, Bertahan 40–79, Sehat 80–100. The score
engine sends the band when a rule overrides the points (`KiraIndicatorRow.band(_:)`).

## Components

Text a component shows comes from the String Catalog. A label of a control takes a
`LocalizedStringResource` (a catalog key such as `"home.cta"`, or a screen model's resource). A
content slot that often holds data (a row's title, a transaction's name, a chat message) takes a
`Text`, so it holds `Text("settings.pin")` and `Text(transaction.name)` alike. The components'
own words are catalog keys under `ds.*` ("Nanti Saja", "Butuh Bantuan Sekarang", "Tutup").
Options beyond five initializer parameters are chained modifiers, such as
`KiraButton("cta") { … }.icon(.phone).block()`.

| Design system | SwiftUI | File (under `App/DesignSystem/`) |
| --- | --- | --- |
| `Button` (primary, secondary, quiet, emergency, destructive; md 50, sm 44; block; icon, iconEnd) | `KiraButton(_:variant:size:action:)` `.icon(_:)` `.iconEnd(_:)` `.block()`; a pair: `KiraButtonPair(secondary:primary:)` | `Components/Controls/KiraButton.swift`, `KiraButtonStyle.swift` |
| `IconButton` (plain, outline) | `KiraIconButton(_:label:variant:action:)`, `.back(_:action:)`, `.close(_:action:)` | `Components/Controls/KiraIconButton.swift` |
| `HelpButton` (pill, icon, row) | `KiraHelpButton(_:action:)` | `Components/Controls/KiraHelpButton.swift` |
| `Toggle` | `KiraToggle(_:isOn:)` | `Components/Controls/KiraToggle.swift` |
| `Field` (prefix, suffix, hint, error, multiline) | `KiraField(_:text:prompt:)` `.prefix` `.suffix` `.hint` `.error` `.multiline` | `Components/Controls/KiraField.swift` |
| `Checkbox` (canvas ONB-10c: a full-width row) | `KiraCheckbox(_:isOn:)` | `Components/Controls/KiraCheckbox.swift` |
| Code boxes (canvas "PIN 6 kotak (pola OTP)": the app-lock PIN, the email code; hint, error) | `KiraCodeField(_:code:kind:)` (`.pin`, `.code`) `.hint` `.error`; digits kept by `DigitCode` | `Components/Controls/KiraCodeField.swift`, `KiraCodeFieldParts.swift`, `Packages/AppCore/Sources/Domain/Code/DigitCode.swift` |
| `.k-link` (on its own; inside a sentence) | `KiraLink(_:action:)`; `KiraLinkText(_:onOpen:)` with Markdown links in the catalog value | `Components/Controls/KiraLink.swift` |
| `Segmented` | `KiraSegmented(_:options:selection:)` | `Components/Controls/KiraSegmented.swift` |
| `Chip` (selected, icon, category) | `KiraChip(_:isSelected:leading:action:)`; wrap many in `KiraFlowRow` | `Components/Controls/KiraChip.swift`, `Layout/KiraFlowRow.swift` |
| `Tag` (neutral, pandan, turmeric, healthy, vulnerable, emergency, hero) | `KiraTag(_:tone:icon:)` | `Components/Content/KiraTag.swift` |
| `Notice` (info, simulation, education, privacy, safe, ai, warning) | `KiraNotice(_:title:message:icon:)` (`ai` is `.aiText`) | `Components/Content/KiraNotice.swift` |
| `Amount` (sm, md, lg, xl; masked, signed, muted, inverse) | `KiraAmount(_:size:)` `.masked(_:)` `.signed()` `.muted()` `.inverse()` | `Components/Content/KiraAmount.swift` |
| `Avatar` | `KiraAvatar(_:size:tone:label:)` | `Components/Content/KiraAvatar.swift` |
| `Accordion` (raised, soft; controlled or not) | `KiraAccordion(_:subtitle:icon:isExpanded:content:)` `.soft()` | `Components/Content/KiraAccordion.swift` |
| `ProgressPita` (milestones, caption, tone, inverse) | `KiraProgressRibbon(value:target:label:valueLabel:)` `.milestones` `.caption` `.tone` `.inverse()` | `Components/Content/KiraProgressRibbon.swift` |
| `StepProgress` | `KiraStepProgress(current:total:)` | `Components/Content/KiraStepProgress.swift` |
| `Bars` | `KiraBars(_:columns:height:)` | `Components/Content/KiraBars.swift` |
| `BandPill` (md, sm) | `KiraBandPill(_:size:)` | `Components/Score/KiraBandPill.swift`, `ScoreBand+Style.swift` |
| `ScoreMeter` | `KiraScoreMeter(_:delta:)` | `Components/Score/KiraScoreMeter.swift` |
| `IndicatorRow` | `KiraIndicatorRow(name:value:points:action:)` `.target(_:)` `.band(_:)` | `Components/Score/KiraIndicatorRow.swift` |
| `NextStepCard` | `KiraNextStepCard(_:message:primaryLabel:onPrimary:onSecondary:)` `.eyebrow` `.meta` `.illustration` `.impact` `.secondaryLabel` | `Components/Score/KiraNextStepCard.swift` |
| `SectionTitle` (note or action, leaf) | `KiraSectionTitle(_:showsLeaf:trailing:)` | `Components/Lists/KiraSectionTitle.swift` |
| `ListGroup` | `KiraListGroup(_:footer:rows:)`; rows in any card: `KiraRowStack` | `Components/Lists/KiraListGroup.swift`, `Layout/RowSeparators.swift` |
| `ListRow` (category, icon, illustration, initial; chevron, external, toggle, check; danger) | `KiraListRow(_:leading:trailing:action:extra:)` `.subtitle` `.amount` `.value` `.danger()` | `Components/Lists/KiraListRow.swift`, `KiraListRowParts.swift` |
| `NavBar` (back, close, large, eyebrow, actions) | `KiraNavBar(_:subtitle:leading:isLarge:trailing:)` `.eyebrow(_:)` | `Components/Navigation/KiraNavBar.swift` |
| `TabBar` (the dock with Catat) | `KiraTabBar(selection:isRecordActive:onRecord:)`, `KiraTab` | `Components/Navigation/KiraTabBar.swift` |
| `Sheet` | `.kiraSheet(isPresented:title:subtitle:content:)`: the artifact's sheet, not the system one (the scrim, a line-strong grabber, the hairline top, 30 pt corners, the close X on the right), in a KiraCover | `Components/Navigation/KiraSheet.swift`, `Layout/KiraCover.swift` |
| `.k-dialog` (success, failure, confirm; illustration or round icon; one or two buttons) | `KiraDialog(_:message:art:primary:secondary:)`, presented with `.kiraDialog(isPresented:dialog:)` | `Components/Dialog/KiraDialog.swift`, `KiraDialogPresentation.swift` |
| (screen edges) | `.kiraScrollEdges()` | `Layout/KiraScrollEdges.swift` |
| `ChatBubble` (me, kira; meta, initial, saved) | `KiraChatBubble(_:meta:initial:content:)` `.saved(_:)` `.hidesAvatar()` (`me` is `.user`) | `Components/Chat/KiraChatBubble.swift` |
| `DraftCard` | `KiraDraftCard(items:total:onSave:onEdit:)` `.secondary` `.eyebrow` `.saveLabel`; items `KiraDraftItem` | `Components/Chat/KiraDraftCard.swift` |
| `Icon` (duotone) | `KiraIcon(_:size:weight:isFilled:)`, names `KiraIconName` | `Artwork/KiraIcon.swift`, `KiraIconName.swift` |
| `Logo` (icon, mark, wordmark; pandan, hero, mono) | `KiraLogo(_:tone:size:)` | `Artwork/KiraLogo.swift` |
| `Mascot` (calm, happy, proud; frame; face crop) | `KiraMascot(_:size:isFramed:crop:)` | `Artwork/KiraMascot.swift` |
| `CategoryIcon` (28 names) | `KiraCategoryIcon(_:size:isRound:label:)`, names and titles `KiraCategory` | `Artwork/KiraCategoryIcon.swift`, `KiraCategory.swift` |
| `Illustration` (15 names), `plantFor` | `KiraIllustration(_:size:label:)`, `KiraIllustrationName.plant(for:)` | `Artwork/KiraIllustration.swift` |
| `HandNote` (tones, sizes, arrows, tilt) | `KiraHandNote(_:tone:size:tilt:arrow:)` | `Artwork/KiraHandNote.swift` |
| `Leaf` (twig, pandan, single; nature, soft, hero; flip) | `KiraLeaf(_:tone:size:isFlipped:)` | `Artwork/KiraNature.swift` |
| `Scenery` (nature with sun, hero) | `KiraScenery(tone:hasSun:height:)` | `Artwork/KiraNature.swift` |
| `formatRupiah`, `bandOf` | `RupiahFormatStyle` (`.rupiah`), `ScoreBand(score:)`, `Score` | `Packages/AppCore/Sources/Domain/` |

A dialog confirms a deletion or reports how an action went. Its buttons close it after their own
action, so a screen only flips its flag:

```swift
.kiraDialog(isPresented: $confirmsDelete) {
    KiraDialog(
        "transaction.delete.title", message: "transaction.delete.body", art: .illustration(.care),
        primary: KiraButton("transaction.delete", variant: .destructive) { model.delete() },
        secondary: KiraButton("transaction.keep", variant: .secondary) {})
}
```

### A screen, put together

```swift
struct DebtDetailView: View {
    let model: DebtDetailModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space6) {
                KiraNavBar("debt.title", subtitle: model.name, leading: .back("debt.back") { dismiss() }) {
                    KiraHelpButton(.icon) { model.openHelp() }
                }
                VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                    Text("debt.remaining").font(.footnote.weight(.medium)).foregroundStyle(.inkMuted)
                    KiraAmount(model.remaining, size: .large)
                }
                KiraNotice(.simulation, title: "debt.simulation.title", message: "debt.simulation.body")
                KiraButtonPair(
                    secondary: KiraButton("debt.later", variant: .secondary) { model.later() },
                    primary: KiraButton("debt.plan") { model.openPlan() })
            }
            .padding(KiraSpacing.screen)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}
```

A screen that uses `KiraNavBar` hides the system bar. A tab root lays `KiraTabBar` over a
`TabView` whose own bar is hidden (`.toolbar(.hidden, for: .tabBar)`), in a bottom
`safeAreaInset`, and leaves `KiraSpacing.space10` at the end of its scroll.

### Accessibility built in

Every control is at least 44 pt, labels scale with Dynamic Type and wrap rather than truncate at the
largest sizes, and parts that would squeeze each other stack at the accessibility sizes (a button
pair, primary on top; a nav bar's buttons above its title; a section title's note under it; the
dock grows taller). An amount stays on one line and shrinks to fit there, and a large title shrinks
before it would clip. Icon-only buttons require a name,
artwork is one named image or hidden (`artworkLabel(_:)`), selected chips, segments, tabs and
checks carry the selected trait, the switch carries the toggle trait and says "Aktif" or
"Nonaktif", the accordion says whether it is open, an amount reads as one value in words
("1.840.000 rupiah", or "Nominal disembunyikan" when masked), avatars grow with the text, and
motion stops under Reduce Motion. A checkbox carries the toggle trait and says "Dicentang" or
"Belum dicentang". The six code boxes are one text field to VoiceOver, named by its label, that
says the digits on screen and how many are in ("3 8, 2 dari 6 angka terisi"); a masked PIN gives
the count alone. "Tahan untuk Lihat" keeps its words as its name, and VoiceOver and Voice Control,
which cannot hold, turn the digits on and off with its action. A presented dialog
covers the whole window, so nothing behind it can be reached; VoiceOver starts on its title, and
the escape gesture runs the secondary action (or the only one) and closes it. `UITests/DesignSystemGalleryAuditTests.swift` runs Apple's
accessibility audit over every gallery page.

## Icons

`KiraIcon` draws the SF Symbol the design system maps each name to (Icon README); `isFilled` is
the design system's duotone: the outline over the symbol's `.fill` variant at 20 % opacity, as the
artifact paints a duotone icon (the help button's heart, the active dock tab).

| Name | SF Symbol | Name | SF Symbol | Name | SF Symbol |
| --- | --- | --- | --- | --- | --- |
| home | house | chat | bubble.left | target | target |
| users | person.2 | chevron-right/left/down | chevron.right/left/down | calculator | function |
| close | xmark | eye | eye | eye-off | eye.slash |
| camera | camera | mic | mic | arrow-up | arrow.up |
| trend-up | chart.line.uptrend.xyaxis | heart | heart | pencil | pencil |
| info | info.circle | check | checkmark | plus | plus |
| wallet | wallet.bifold | phone | phone | lock | lock |
| receipt | receipt | search | magnifyingglass | bell | bell |
| settings | slider.horizontal.3 | user | person | shield | checkmark.shield |
| upload, share | square.and.arrow.up | download | square.and.arrow.down | file | doc.text |
| calendar | calendar | external | arrow.up.forward.square | flag | flag |
| map-pin | mappin | trash | trash | book | book |
| chart | chart.bar | clock | clock | copy | doc.on.doc |
| alert | exclamationmark.triangle | help | questionmark.circle | logout | rectangle.portrait.and.arrow.right |
| link | link | card | creditcard | bank | building.columns |
| sparkle | sparkle | stop | stop | refresh | arrow.clockwise |
| filter | line.3.horizontal.decrease | minus | minus | star | star |
| key | key | face-id | faceid | scan | viewfinder |
| image | photo | play | play | pause | pause |
| wind | wind | list | list.bullet | globe | globe |
| gift | gift | arrow-right | arrow.right | more | ellipsis |
| percent | percent | send | paperplane | | |

`minus` and `star` are in `index.d.ts` but not in the README's mapping; they use the symbols of
the same name.

## The gallery

A debug build launched with `-KiraGallery` opens the gallery instead of the app: every token,
style, icon, artwork and component, page by page (the Kira scheme lists the argument, off; tick it
under Run › Arguments, or add a page name after it, such as `-KiraGallery chat`). Every component's
`#Preview` shows its gallery page. Each section repeats the artifact's preview of its component
(`project/components/<Name>/preview.html`) with the same words and options, so the two compare side
by side; further variants follow it. The gallery and its `gallery.*` catalog keys exist in debug
builds only; release builds compile none of it.

## Names: the artifact's words and the Swift ones

The design system names tokens, components and artwork in Indonesian, as designers and tickets use
them. Code, asset names, file names and String Catalog keys are English (AGENTS.md Rule 35);
Indonesian stays in the catalog's translations. A ticket's word finds its Swift name here, and
`scripts/generate/design-assets.py` holds the same pairs for the asset catalog.

| Artifact | Swift and asset catalog |
| --- | --- |
| Colour `sehat`, `bertahan`, `rentan` (each with `-soft`, `-line`) | `healthy`, `coping`, `vulnerable` (`.healthy`, `.copingSoft`, `.vulnerableLine`, …) |
| Colour `darurat`, `darurat-soft`, `on-darurat` | `emergency`, `emergency-soft`, `on-emergency` |
| Colour `hero-alam`, `hero-alam-2` | `hero-nature`, `hero-nature-2` |
| Colour `ilu-*` | `art-*`: `hijau` green, `hijau-tua` green-dark, `hijau-muda` green-light, `hijau-lembut` green-soft, `kunyit` turmeric, `kunyit-tua` turmeric-dark, `kunyit-muda` turmeric-light, `persik` peach, `persik-muda` peach-light, `bata` brick, `tanah` soil, `tanah-tua` soil-dark, `langit` sky, `langit-tua` sky-dark, `langit-muda` sky-light, `putih` white, `tinta` ink, `kilau` gleam, `bulu` feather, `bulu-tua` feather-dark, `topeng` mask, `krem` cream, `mata` eye |
| Colours already English (`surface…`, `ink…`, `pandan…`, `hero`, `hero-accent`, `hero-track`, `on-hero…`, `button…`, `track`, `line…`, `hairline`, `glass`, `scrim`) | unchanged |
| Score band `rentan`, `bertahan`, `sehat` (`bandOf`) | `ScoreBand.vulnerable`, `.coping`, `.healthy` |
| Button variant `darurat`, `bahaya` | `KiraButton.Variant.emergency`, `.destructive` |
| Tag tone `netral`, `kunyit`, `sehat`, `rentan`, `darurat` | `KiraTag.Tone.neutral`, `.turmeric`, `.healthy`, `.vulnerable`, `.emergency` |
| Notice tone `simulasi`, `edukasi`, `privasi`, `aman`, `peringatan`, `ai` | `KiraNotice.Tone.simulation`, `.education`, `.privacy`, `.safe`, `.warning`, `.aiText` |
| Avatar tone `kunyit`, `hijau`, `langit`, `persik` | `KiraAvatar.Tone.turmeric`, `.green`, `.sky`, `.peach` |
| HandNote tone `bertahan` | `KiraHandNote.Tone.coping` |
| ProgressPita, tone `sehat` | `KiraProgressRibbon`, `.healthy` |
| TabBar tabs `beranda`, `rencana`, `komunitas`; the Catat button | `KiraTab.home`, `.plan`, `.community`; `isRecordActive`, `onRecord` |
| Mascot `tenang`, `senang`, `bangga`; face crop | `KiraMascot.Expression.calm`, `.happy`, `.proud`; `mascot-calm` and `mascot-calm-face` image sets |
| Leaf `ranting`, `pandan`, `daun`; tones `alam`, `lembut`, `hero` | `KiraLeaf.Name.twig`, `.pandan`, `.single`; `Tone.nature`, `.soft`, `.hero`; image sets `leaf-<name>-<tone>` |
| Scenery `alam` (with `sore`, the late sun), `hero` | `KiraScenery.Tone.nature`, `.hero`; `scenery-nature`, `scenery-nature-evening`, `scenery-hero` |
| Illustration `tunas`, `tumbuh`, `mekar`, `celengan`, `kartu-lunas`, `peduli`, `struk`, `payung`, `perisai`, `kalender`, `tangga`, `buku`, `surat`, `gembok`, `komunitas` | `KiraIllustrationName.sprout`, `.growing`, `.bloom`, `.piggyBank`, `.cardPaidOff`, `.care`, `.receipt`, `.umbrella`, `.shield`, `.calendar`, `.stairs`, `.book`, `.letter`, `.padlock`, `.community`; image sets `illustration-<kebab name>` |
| Category `makan`, `transportasi`, `kopi`, `belanja`, `tagihan`, `gaji`, `paylater`, `tabungan`, `proteksi`, `rumah`, `pendidikan`, `kesehatan`, `hiburan`, `menikah`, `pensiun`, `bank`, `ewallet`, `tunai`, `kartu`, `pinjol`, `emas`, `saham`, `reksadana`, `kripto`, `sbn`, `darurat`, `barang`, `lainnya` | `KiraCategory.food`, `.transport`, `.coffee`, `.shopping`, `.bills`, `.salary`, `.paylater`, `.savings`, `.protection`, `.home`, `.education`, `.health`, `.entertainment`, `.wedding`, `.retirement`, `.bank`, `.ewallet`, `.cash`, `.card`, `.onlineLoan`, `.gold`, `.stocks`, `.mutualFunds`, `.crypto`, `.governmentBonds`, `.emergency`, `.goods`, `.other`; image sets `category-<kebab name>` |
| Logo `logo-tanda` (and `-hero`, `-mono`), `logo-ikon` | `logo-mark` (and `-hero`, `-mono`), `logo-icon` |
| Hand-drawn arrows `panah-*` | `arrow-*` |
| Asset folders `Ilustrasi/`, `Kategori/`, `Maskot/`, `Alam/`, `Tulisan/` | `Illustrations/`, `Categories/`, `Mascot/`, `Nature/`, `Handwriting/` |
| Catalog keys `ds.band.sehat`, `ds.category.makan`, `ds.mascot.tenang`, `ds.tab.komunitas`, `ds.pita.*`, … | `ds.band.healthy`, `ds.category.food`, `ds.mascot.calm`, `ds.tab.community`, `ds.ribbon.*`, …: the same English word as the Swift case; the Indonesian text is the value |

`scripts/check/english-names.mjs` (a gate) fails on an identifier, asset name, Swift file name or
catalog key that holds a word of this Indonesian vocabulary.

## Assets and where they come from

- **App icon**: the artifact's `kira-ikon-1024.png` (asset `71b17ca1ba371f63f5e8b48a782beea7`), as
  `kira-icon-1024.png`, a
  full 1024 px square without alpha; iOS applies the mask (`ASSETCATALOG_COMPILER_APPICON_NAME`
  in `Config/Base.xcconfig`).
- **Artwork** (`Illustrations/`, `Categories/`, `Mascot/`, `Nature/`, `Handwriting/`, `Logo/`): SVG image sets
  with vector data preserved, one SVG per theme. They were generated from the artifact's own
  drawing data, the tables of `components/bundle.js` (`ILLUSTRATIONS`, `CATEGORIES`, `KUKU_*`,
  `LEAF_ART`, `SCENES`, `ARROWS`, `LOGO_LEAF`, `LOGO_VEIN`), read as data, with each paint resolved
  to its `art-*` (the artifact's `ilu-*`) or `hero-*` token in the light and the dark theme. The artifact's uploaded SVGs
  are light-theme exports of the same tables (compared shape by shape with `tunas.svg`,
  `makan.svg` and `kuku-tenang.svg`: identical, apart from the mascot's frame circle and the
  category tile, which the components draw); the generated sets add the dark theme and the names the
  uploads lack (15 illustrations instead of 8, 28 category tiles instead of 9, the face crops, the
  leaves and the sceneries). A category set holds the tile's art only; `KiraCategoryIcon` draws the
  tile, so its tint and hairline follow the theme too.
- **Regenerating**: `scripts/generate/design-assets.py` rebuilds the whole catalog (colour sets,
  icon, artwork) from the artifact's `tokens.json`, `bundle.js` and icon PNG; its header says how.
  Rebuild when the artifact changes, then check the gallery.
- **Logo marks** cut the leaf's vein out of the mark (even-odd fill), so the vein always shows
  whatever is behind it, as the design system asks (`--k-logo-bg`); `logo-mark-mono` and the
  hand-drawn arrows are template images that take the surrounding colour.
- Uploaded assets map as `design-system.json` lists them: Maskot `2e557f5b…` is `kuku-tenang`
  (`mascot-calm`), `d9c5f557…` `kuku-senang` (`mascot-happy`), `f033f686…` `kuku-bangga`
  (`mascot-proud`); the nine Kategori uploads (07:10:59–07:11:06) are makan, transportasi, kopi,
  belanja, tagihan, gaji, paylater, tabungan and proteksi; the eight 07:22 uploads are the Ilustrasi
  group; the eight earlier 07:10:52–58 uploads are older
  illustration exports no group lists.

## Precision against the artifact

Each component was compared with the artifact's own preview: the preview rendered in Chrome at
393 pt and 3x from `bundle.css`, `bundle.js` and `tokens.json`, beside the matching gallery page on
an iPhone 16 simulator (393 pt), light and dark, with the CSS values read from `bundle.css`. The
table lists the properties that differed and what they are now; every other property of the
components (sizes, paddings, radii, borders, colours, icon sizes) already matched and is unchanged.

| Component | Property | Artifact | Before | Now |
| --- | --- | --- | --- | --- |
| Text styles | Line height of SF Pro text | `line-height` 22 (17 pt), 21 (16), 20 (15), 18 (13), 16 (12) | System: 20.3, 19.1, 17.9, 15.5, 14.3 for one line | The artifact's, from iOS 26 (`kiraLineHeight`) |
| Text styles | Line box of Plus Jakarta Sans and Kalam | `t-score` 64, `t-amount-xl` 46, `t-large-title` 41, `t-hand` 22, `t-hand-sm` 19 | The fonts' own: 80.6, 50.4, 42.8, 30.3, 25.4 | The artifact's in layout; the glyphs keep their own line |
| `t-overline` | Size, tracking | 11 pt Bold, 0.08 em | 12 pt (Caption 1), 0.96 pt | 11 pt (Caption 2), 0.88 pt |
| Amount | "Rp" and ",00" | 0.55 em: 11 (md), 18.7 (lg), 23.1 (xl) | Never under 13 pt | 11, 18.7, 23.1 |
| Amount | Space after "Rp", before ",00" | 0.14 em and 0.03 em of their own size | 0.14 of the amount's size; none | 0.14 and 0.03 of their own size |
| Amount | Masked | "Rp" then "••••••", the same gap | A word space | The same gap |
| Amount | Too wide for its line | Overflows | Each part shrank on its own | The whole amount shrinks as one |
| ScoreMeter | "/100" | Plus Jakarta Sans 17 Bold | SF Pro 17 Bold | Plus Jakarta Sans 17 Bold |
| ScoreMeter | Track in layout | 12 pt, the 24 pt mark overhangs | 24 pt | 12 pt, the mark overhangs |
| ScoreMeter | Delta label | `deltaLabel` ("dari September") | "dari bulan lalu" only | `deltaLabel:` |
| NextStepCard | Buttons | `minmax(max-content, 1fr) minmax(max-content, 1.3fr)` | Equal halves | 1 : 1.3; stacked at the accessibility sizes |
| NextStepCard | Illustration margin | −4 top, right and bottom; 0 left | −4 all round | −4 top, right and bottom |
| ProgressPita | Value weight | 500 | 400 | 500 (Medium) |
| ProgressPita | Space around the "·" | 8 pt each side (`gap` and `margin-right`) | A word space | An en space (7.5 pt at 15 pt) |
| TabBar | Active label tracking | −0.01 em | None | −0.15 pt |
| TabBar | Catat label | 10/12 pt Bold, 0.02 em | 12 pt Bold | 10 pt Bold, 0.2 pt, 12 pt line |
| TabBar | Catat active ring | 2 pt outline 3 pt out, corners grown with it | Corners not grown | Corners 28 and 12 |
| Icon | Duotone (active tab, help heart) | Stroke over a 20 % fill | The solid `.fill` symbol | The outline over the `.fill` symbol at 20 % |
| HelpButton | Heart | Duotone, 15 pt (20 in the icon button), stroke 2 | Solid heart, 11 and 15 pt | Duotone, 15 and 20 pt |
| HelpButton | Label | `label` prop | Fixed | `label:` |
| ChatBubble | Width | `max-width` 82 %, 76 % beside an avatar; a card 82 % | Spacers of 56 and 40 pt | 82 %, 76 %, a card 82 % (`ChatLineLayout`) |
| DraftCard | Edit button | 44 pt with margins −6 −10 −6 −6 | 44 pt in layout | 44 pt overhanging the same margins |
| SectionTitle | Action padding | 0 2 pt | None | 0 2 pt |
| ListRow | External icon | 18 pt | 20 pt | 18 pt |
| Tag | Hero border | `#ffffff33` | on-hero at 20 % | White at 20 % |
| Avatar | Initials | `round(size × 0.4)` | `max(13, size × 0.4)` | `round(size × 0.4)` |
| Bars | Caption | 11/14 pt, 650 | 12 pt | 11 pt (Caption 2), 14 pt line |
| Dialog | Illustration | `margin-top: −4px` | 0 | −4 pt |
| Chip | Height in layout | 40 pt, the 44 pt target outside it | 44 pt | 40 pt, the 44 pt target outside it |
| NavBar | Large: eyebrow | Its own row 2 pt above the title; the buttons centred on the title | Buttons centred on eyebrow and title | Buttons centred on the title |
| Logo | Wordmark gap and size | `round(size × 0.24)`, `round(size × 0.92)` | Not rounded | Rounded |
| Accordion | `defaultOpen` | Supported | Closed only | `.openByDefault()` |
| Field | `icon` | Supported | None | `.icon(_:)` |
| StepProgress | `label` | Supported | "Langkah N dari M" only | `label:` |
| Sheet | Whole sheet | The scrim token, a 36×5 line-strong grabber at 50 %, a hairline top border, 30 pt top corners, padding 8 16, header 44 / 1fr / 44 with 16 pt gaps, top 56 | The system sheet: system dimming and grabber, medium and large detents, no top border | The artifact's sheet in a KiraCover, closed by the grabber, the scrim, the X or the escape gesture |

## Not done yet, or done differently

| Item | State | Why |
| --- | --- | --- |
| Dialog buttons | Stacked | Primary on top and secondary under it, both as wide as the dialog, as `bundle.css` (`.k-dialog__actions`, a column) and every dialog on the canvas boards draw them; the side-by-side rule (secondary left, primary right) is `KiraButtonPair` on screens |
| Dialog presentation | Full-screen cover | A transparent full-screen cover that appears without its slide, so the scrim covers the nav bar and the dock wherever `.kiraDialog` is attached; the card fades in and grows from 96% (fade only under Reduce Motion) |
| Text link underline | System | SwiftUI draws the platform underline; the canvas's 1.5 px line 3 px under the text is not available on `Text` |
| PIN keypad of the lock screen (canvas BukaKunci) | Not done | That screen draws its own keypad on the hero background; `KiraCodeField` uses the system number pad |
| Pasting a code | Edit menu | The number pad has no paste key: a long press on the boxes opens the edit menu, and any text pasted keeps its first six digits ("Kode: 381 449" fills all six); Mail's code comes from the keyboard's suggestion on `.code` |
| `ScoreMeter` `onExplain` / `explainLabel` | Not done | Deprecated in the README in favour of an Accordion under the meter |
| `Accordion` `defaultOpen` | Done | `.openByDefault()`; `isExpanded:` opens or closes it from outside |
| `TabBar` custom `items` | Not done | The dock's three destinations are fixed product decisions (`KiraTab`) |
| `Field` `type`, `inputMode`, `readOnly` | Different | Set `.keyboardType(_:)`, `.textContentType(_:)` or `.disabled(_:)` on the field as on any view |
| Disabled `Button` | Done, not in the gallery | Opacity 0.45 as in `bundle.css`; left out of the gallery so its audit does not read a disabled control's contrast |
| `StepProgress` with the label hidden (`label=""`) | Not done | A 6 pt bar alone is an element the audit reports as too small; the line also tells sighted readers how many steps are left |
| Labels that never wrap (`white-space: nowrap`) | Different | At the largest Dynamic Type sizes labels wrap instead of truncating, which the audit requires; at the default sizes nothing wraps |
| Wordmark | Drawn, not text | "Kira" is painted in a canvas at the logo's size, so the logo keeps its proportions and is one image named "Kira" for VoiceOver, as `role="img"` is in the design system |
| Avatar initials | Scale with text | The artifact's size at the default text size; the circle grows with Dynamic Type together with its initials |
| Category chip | Two buttons | The round tile is a separate button with the same action, hidden from VoiceOver, so the labelled button holds only text (the audit reads a pastel tile inside a button as low-contrast text) |
| Line heights | iOS 26 and later | Set as in the artifact from iOS 26 (`lineHeight`); iOS 17 and 18 keep the system's leading, 1 to 2 pt shorter per line |
| Font weights 650 and 750 | Nearest named | Semibold (600) and ExtraBold (800): SwiftUI's `Font.Weight` has no public initializer from a number |
| Small sizes the audit reports | Accepted deviation | The owner keeps the artifact's sizes: the 11 pt overline, the medium amount's 11 pt "Rp" and ",00", the 10 pt "Catat" and the 11 pt bar caption. Apple's audit reports each as "Dynamic Type font sizes are partially unsupported"; they carry `kira.small-type`, and the gallery's audit test lists them apart |
| Text behind a dialog's scrim | Accepted in the test | The dimmed screen shows through the scrim, and the audit reads its text, which VoiceOver rightly cannot reach while the dialog is modal, as text without an element ("Potentially inaccessible text", no element named); the presented-dialog test accepts only that finding |
| Field prompt | Drawn by the field | A single-line field draws its prompt as text that wraps at large sizes, where the system's prompt would be cut off; VoiceOver hears it as the field's hint |
| Button pair order in the Button preview | Rule | The preview puts the primary left; Kira's rule puts the secondary left and the primary right (`KiraButtonPair`) |
| Dark app icon and tinted icon (iOS 18) | Not done | The artifact ships the light icon only |

## Notes for screens

- **Dead code (Periphery 3.8, Xcode 27).** A `@State` that a view only reads through its binding
  (`$value`, handed to a field or a switch) is reported as unused: the `@State` macro generates the
  binding, and Periphery does not follow it. Mark that property
  `// periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow`,
  as `KiraAccordion` and the gallery do. A property the view also reads or writes directly needs
  nothing.
- **The accessibility audit.** `performAccessibilityAudit` reads only what is on screen; scroll and
  audit again for long screens. It reports any text under about 12 pt, a Plus Jakarta Sans text
  of about 23 pt or more scaled like Large Title, any text that truncates (`lineLimit`) at large
  sizes, fixed-size fonts (`.system(size:)`, `fixedSize:`), `ViewThatFits` around text, and a
  custom element (`.accessibilityElement(children:)`) under 44 pt. Use the components and text
  styles here and those findings do not arise.
- **Auditing a scrolled screen.** Scroll with a drag that holds before lifting (as
  `UITests/DesignSystemGalleryAuditTests.swift` does), never past the end: a fling or a bounce at
  the end leaves the accessibility frames where the content was, and the audit then reports
  contrast failures on text it measures in the wrong place. Text left under the status bar or at
  the home indicator is the one contrast finding the gallery's test accepts, with its reason.
- **iOS 17 and 18 (found while testing, not caused by this work).** A debug build does not launch on
  the iOS 17.5 simulator: dyld cannot find `libswiftCompatibilitySpan.dylib`, which the
  swift-collections code under the API client's `swift-openapi-urlsession` needs with the Swift 6.4
  toolchain. The deployment target is iOS 17.0, so check a Release build on an iOS 17 or 18
  device before the first distribution.
