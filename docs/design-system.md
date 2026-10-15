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
- **Red (`darurat`) only for the 119 call and reporting**; `bahaya` (terracotta) confirms deletions.
- **At most one handwritten note per screen**, anchored to a section title, an illustration or the
  splash.
- **Glass only on the dock.** A scrolling screen calls `.kiraScrollEdges()`: from iOS 26 a scroll
  view blurs its top and bottom edges, which is glass (and fades text the accessibility audit then
  reads as low contrast); the modifier hides that effect and lays a solid `surface` band behind the
  status bar.

## Tokens

### Colour

Every colour token of `tokens.json` is a colour set in `App/Assets.xcassets/Tokens/`, named as the
design system names it, with its light and dark value (the design system defines both themes, so
dark mode follows the device). Xcode generates a symbol per set, so a token is used by name:

```swift
Text("home.title").foregroundStyle(.ink)
VStack { ... }.background(.surface)
Capsule().fill(.pandanSoft)
```

The generated name is the token in lowerCamelCase: `surface-raised` → `.surfaceRaised`,
`hero-alam-2` → `.heroAlam2`, `ilu-kunyit-muda` → `.iluKunyitMuda`. `AccentColor` is pandan, so
the cursor and system selections carry the accent. The groups: surfaces (`surface`,
`surface-raised`, `surface-muted`, `button`, `button-line`, `track`, `line`, `hairline`,
`line-strong`), text (`ink`, `ink-muted`), accent (`pandan`, `pandan-strong`, `pandan-soft`,
`pandan-line`, `on-pandan`), the hero card (`hero`, `on-hero`, `on-hero-muted`, `hero-track`,
`hero-accent`, `hero-alam`, `hero-alam-2`), the Kira Score bands (`sehat`, `bertahan`, `rentan`,
each with `-soft` and `-line`), `darurat`, `darurat-soft`, `on-darurat`, `glass`, `scrim`, and the
illustration paints (`ilu-*`), which are for artwork only, never text or buttons.

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
| `t-overline` | `.overline` | `.caption`, Bold, capitals, tracked (12; the design system says 11) |
| `t-formula` | `.formula` | `.footnote` monospaced, Medium (13) |
| `t-hand` | `.hand` | Kalam 19, `.body` |
| `t-hand-sm` | `.handSmall` | Kalam 16, `.subheadline` |

The design system uses CSS weights 650 and 750, which SwiftUI cannot name: 650 maps to Semibold and
750 to ExtraBold (`.heavy`). Line heights are the system's. Letter spacing follows the tokens.

No text is smaller than 12 pt, and no Plus Jakarta Sans text smaller than 13 pt. Apple's
accessibility audit reports anything smaller as only partly supporting Dynamic Type (Caption 2
never shrinks below 11 pt, and an 11 pt custom font shrinks under it), so the overline and the
dock's "Catat" use Caption 1, and an amount's "Rp" and ",00" never go under 13 pt.

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
| `Button` (primary, secondary, quiet, darurat, bahaya; md 50, sm 44; block; icon, iconEnd) | `KiraButton(_:variant:size:action:)` `.icon(_:)` `.iconEnd(_:)` `.block()`; a pair: `KiraButtonPair(secondary:primary:)` | `Components/Controls/KiraButton.swift`, `KiraButtonStyle.swift` |
| `IconButton` (plain, outline) | `KiraIconButton(_:label:variant:action:)`, `.back(_:action:)`, `.close(_:action:)` | `Components/Controls/KiraIconButton.swift` |
| `HelpButton` (pill, icon, row) | `KiraHelpButton(_:action:)` | `Components/Controls/KiraHelpButton.swift` |
| `Toggle` | `KiraToggle(_:isOn:)` | `Components/Controls/KiraToggle.swift` |
| `Field` (prefix, suffix, hint, error, multiline) | `KiraField(_:text:prompt:)` `.prefix` `.suffix` `.hint` `.error` `.multiline` | `Components/Controls/KiraField.swift` |
| `Checkbox` (canvas ONB-10c: a full-width row) | `KiraCheckbox(_:isOn:)` | `Components/Controls/KiraCheckbox.swift` |
| Code boxes (canvas "PIN 6 kotak (pola OTP)": the app-lock PIN, the email code; hint, error) | `KiraCodeField(_:code:kind:)` (`.pin`, `.code`) `.hint` `.error`; digits kept by `DigitCode` | `Components/Controls/KiraCodeField.swift`, `KiraCodeFieldParts.swift`, `Packages/AppCore/Sources/Domain/Code/DigitCode.swift` |
| `.k-link` (on its own; inside a sentence) | `KiraLink(_:action:)`; `KiraLinkText(_:onOpen:)` with Markdown links in the catalog value | `Components/Controls/KiraLink.swift` |
| `Segmented` | `KiraSegmented(_:options:selection:)` | `Components/Controls/KiraSegmented.swift` |
| `Chip` (selected, icon, category) | `KiraChip(_:isSelected:leading:action:)`; wrap many in `KiraFlowRow` | `Components/Controls/KiraChip.swift`, `Layout/KiraFlowRow.swift` |
| `Tag` (netral, pandan, kunyit, sehat, rentan, darurat, hero) | `KiraTag(_:tone:icon:)` | `Components/Content/KiraTag.swift` |
| `Notice` (info, simulasi, edukasi, privasi, aman, ai, peringatan) | `KiraNotice(_:title:message:icon:)` (`ai` is `.aiText`) | `Components/Content/KiraNotice.swift` |
| `Amount` (sm, md, lg, xl; masked, signed, muted, inverse) | `KiraAmount(_:size:)` `.masked(_:)` `.signed()` `.muted()` `.inverse()` | `Components/Content/KiraAmount.swift` |
| `Avatar` | `KiraAvatar(_:size:tone:label:)` | `Components/Content/KiraAvatar.swift` |
| `Accordion` (raised, soft; controlled or not) | `KiraAccordion(_:subtitle:icon:isExpanded:content:)` `.soft()` | `Components/Content/KiraAccordion.swift` |
| `ProgressPita` (milestones, caption, tone, inverse) | `KiraProgressPita(value:target:label:valueLabel:)` `.milestones` `.caption` `.tone` `.inverse()` | `Components/Content/KiraProgressPita.swift` |
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
| `TabBar` (the dock with Catat) | `KiraTabBar(selection:isCatatActive:onCatat:)`, `KiraTab` | `Components/Navigation/KiraTabBar.swift` |
| `Sheet` | `.kiraSheet(isPresented:title:subtitle:content:)` | `Components/Navigation/KiraSheet.swift` |
| `.k-dialog` (success, failure, confirm; illustration or round icon; one or two buttons) | `KiraDialog(_:message:art:primary:secondary:)`, presented with `.kiraDialog(isPresented:dialog:)` | `Components/Dialog/KiraDialog.swift`, `KiraDialogPresentation.swift` |
| (screen edges) | `.kiraScrollEdges()` | `Layout/KiraScrollEdges.swift` |
| `ChatBubble` (me, kira; meta, initial, saved) | `KiraChatBubble(_:meta:initial:content:)` `.saved(_:)` `.hidesAvatar()` (`me` is `.user`) | `Components/Chat/KiraChatBubble.swift` |
| `DraftCard` | `KiraDraftCard(items:total:onSave:onEdit:)` `.secondary` `.eyebrow` `.saveLabel`; items `KiraDraftItem` | `Components/Chat/KiraDraftCard.swift` |
| `Icon` (duotone) | `KiraIcon(_:size:weight:isFilled:)`, names `KiraIconName` | `Artwork/KiraIcon.swift`, `KiraIconName.swift` |
| `Logo` (icon, mark, wordmark; pandan, hero, mono) | `KiraLogo(_:tone:size:)` | `Artwork/KiraLogo.swift` |
| `Mascot` (tenang, senang, bangga; frame; face crop) | `KiraMascot(_:size:isFramed:crop:)` | `Artwork/KiraMascot.swift` |
| `CategoryIcon` (28 names) | `KiraCategoryIcon(_:size:isRound:label:)`, names and titles `KiraCategory` | `Artwork/KiraCategoryIcon.swift`, `KiraCategory.swift` |
| `Illustration` (15 names), `plantFor` | `KiraIllustration(_:size:label:)`, `KiraIllustrationName.plant(for:)` | `Artwork/KiraIllustration.swift` |
| `HandNote` (tones, sizes, arrows, tilt) | `KiraHandNote(_:tone:size:tilt:arrow:)` | `Artwork/KiraHandNote.swift` |
| `Leaf` (ranting, pandan, daun; alam, lembut, hero; flip) | `KiraLeaf(_:tone:size:isFlipped:)` | `Artwork/KiraNature.swift` |
| `Scenery` (alam with sun, hero) | `KiraScenery(tone:hasSun:height:)` | `Artwork/KiraNature.swift` |
| `formatRupiah`, `bandOf` | `RupiahFormatStyle` (`.rupiah`), `ScoreBand(score:)`, `Score` | `Packages/AppCore/Sources/Domain/` |

A dialog confirms a deletion or reports how an action went. Its buttons close it after their own
action, so a screen only flips its flag:

```swift
.kiraDialog(isPresented: $confirmsDelete) {
    KiraDialog(
        "transaction.delete.title", message: "transaction.delete.body", art: .illustration(.peduli),
        primary: KiraButton("transaction.delete", variant: .bahaya) { model.delete() },
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
                KiraNotice(.simulasi, title: "debt.simulation.title", message: "debt.simulation.body")
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
the design system's duotone, the symbol's `.fill` variant (`symbolVariant(.fill)`, which falls back
to the outline when a symbol has none).

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
`#Preview` shows its gallery page. The gallery and its `gallery.*` catalog keys exist in debug
builds only; release builds compile none of it.

## Assets and where they come from

- **App icon**: the artifact's `kira-ikon-1024.png` (asset `71b17ca1ba371f63f5e8b48a782beea7`), a
  full 1024 px square without alpha; iOS applies the mask (`ASSETCATALOG_COMPILER_APPICON_NAME`
  in `Config/Base.xcconfig`).
- **Artwork** (`Ilustrasi/`, `Kategori/`, `Maskot/`, `Alam/`, `Tulisan/`, `Logo/`): SVG image sets
  with vector data preserved, one SVG per theme. They were generated from the artifact's own
  drawing data, the tables of `components/bundle.js` (`ILLUSTRATIONS`, `CATEGORIES`, `KUKU_*`,
  `LEAF_ART`, `SCENES`, `ARROWS`, `LOGO_LEAF`, `LOGO_VEIN`), read as data, with each paint resolved
  to its `ilu-*` or `hero-*` token in the light and the dark theme. The artifact's uploaded SVGs
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
  whatever is behind it, as the design system asks (`--k-logo-bg`); `logo-tanda-mono` and the
  hand-drawn arrows are template images that take the surrounding colour.
- Uploaded assets map as `design-system.json` lists them: Maskot `2e557f5b…` is `kuku-tenang`,
  `d9c5f557…` `kuku-senang`, `f033f686…` `kuku-bangga`; the nine Kategori uploads (07:10:59–07:11:06)
  are makan, transportasi, kopi, belanja, tagihan, gaji, paylater, tabungan and proteksi; the eight
  07:22 uploads are the Ilustrasi group; the eight earlier 07:10:52–58 uploads are older
  illustration exports no group lists.

## Not done yet, or done differently

| Item | State | Why |
| --- | --- | --- |
| Dialog buttons | Stacked | Primary on top and secondary under it, both as wide as the dialog, as `bundle.css` (`.k-dialog__actions`, a column) and every dialog on the canvas boards draw them; the side-by-side rule (secondary left, primary right) is `KiraButtonPair` on screens |
| Dialog presentation | Full-screen cover | A transparent full-screen cover that appears without its slide, so the scrim covers the nav bar and the dock wherever `.kiraDialog` is attached; the card fades in and grows from 96% (fade only under Reduce Motion) |
| Text link underline | System | SwiftUI draws the platform underline; the canvas's 1.5 px line 3 px under the text is not available on `Text` |
| PIN keypad of the lock screen (canvas BukaKunci) | Not done | That screen draws its own keypad on the hero background; `KiraCodeField` uses the system number pad |
| Pasting a code | Edit menu | The number pad has no paste key: a long press on the boxes opens the edit menu, and any text pasted keeps its first six digits ("Kode: 381 449" fills all six); Mail's code comes from the keyboard's suggestion on `.code` |
| `ScoreMeter` `onExplain` / `explainLabel` | Not done | Deprecated in the README in favour of an Accordion under the meter |
| `NextStepCard` buttons | Partial | Equal widths through `KiraButtonPair` (the Berdaya pillar), where `bundle.css` uses 1 : 1.3 |
| `Accordion` `defaultOpen` | Different | Closed by default; open it from outside with `isExpanded:` |
| `TabBar` custom `items` | Not done | The dock's three destinations are fixed product decisions (`KiraTab`) |
| `Field` `type`, `inputMode`, `readOnly` | Different | Set `.keyboardType(_:)`, `.textContentType(_:)` or `.disabled(_:)` on the field as on any view |
| Disabled `Button` | Done, not in the gallery | Opacity 0.45 as in `bundle.css`; left out of the gallery so its audit does not read a disabled control's contrast |
| `StepProgress` with the label hidden (`label=""`) | Not done | A 6 pt bar alone is an element the audit reports as too small; the line also tells sighted readers how many steps are left |
| Labels that never wrap (`white-space: nowrap`) | Different | At the largest Dynamic Type sizes labels wrap instead of truncating, which the audit requires; at the default sizes nothing wraps |
| Wordmark | Drawn, not text | "Kira" is painted in a canvas at the logo's size, so the logo keeps its proportions and is one image named "Kira" for VoiceOver, as `role="img"` is in the design system |
| Avatar initials | Scale with text | The circle grows with Dynamic Type together with its initials |
| Category chip | Two buttons | The round tile is a separate button with the same action, hidden from VoiceOver, so the labelled button holds only text (the audit reads a pastel tile inside a button as low-contrast text) |
| Line heights of the text styles | System | SwiftUI sets no absolute line height; the styles keep the system's leading |
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
