// Gallery pages for the screen parts: the Kira Score, lists, navigation and chat.
#if DEBUG
    import Domain
    import SwiftUI

    struct GalleryScore: View {
        var body: some View {
            GallerySection(title: "gallery.section.band") {
                HStack(spacing: KiraSpacing.space2) {
                    ForEach(ScoreBand.allCases, id: \.self) { band in KiraBandPill(band) }
                }
                HStack(spacing: KiraSpacing.space2) {
                    ForEach(ScoreBand.allCases, id: \.self) { band in KiraBandPill(band, size: .small) }
                }
            }
            GallerySection(title: "gallery.section.meter") {
                KiraIllustration(.plant(for: Score(66).band), size: 96)
                KiraScoreMeter(Score(66), delta: 5)
                Text("gallery.type.caption").kiraFont(.caption).foregroundStyle(.inkMuted)
            }
            GallerySection(title: "gallery.section.indicator") {
                KiraRowStack {
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.fund"), value: Text("gallery.indicator.fund.value"),
                        points: Score(37), action: {}
                    )
                    .target(Text("gallery.indicator.fund.target"))
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.saving"), value: Text("gallery.indicator.saving.value"),
                        points: Score(82))
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.debt"), value: Text("gallery.indicator.debt.value"),
                        points: Score(0)
                    )
                    .band(.rentan)
                }
                .padding(.horizontal, KiraSpacing.space4)
                .kiraCard()
            }
            GallerySection(title: "gallery.section.nextStep") {
                KiraNextStepCard(
                    "gallery.step.title", message: "gallery.step.body", primaryLabel: "gallery.step.primary",
                    onPrimary: {}, onSecondary: {}
                )
                .eyebrow("gallery.step.eyebrow")
                .meta("gallery.step.meta")
                .illustration(.kartuLunas)
                .impact("gallery.step.impact")
                .secondaryLabel("gallery.step.secondary")
            }
        }
    }

    struct GalleryLists: View {
        // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
        @State private var locks = true
        @State private var method = 0

        var body: some View {
            KiraSectionTitle("gallery.list.priority", trailing: .note("gallery.hand.start"))
            KiraSectionTitle("gallery.list.bills", trailing: .action("gallery.list.seeAll", {}))
            KiraSectionTitle("gallery.list.plain", showsLeaf: false)
            KiraListGroup("gallery.list.wallets", footer: "gallery.list.wallets.footer") {
                KiraListRow(Text("gallery.list.bank"), leading: .category(.bank), action: {})
                    .amount(KiraAmount(2_450_000, size: .medium))
                KiraListRow(Text("gallery.list.ewallet"), leading: .category(.ewallet))
                    .subtitle(Text("gallery.list.ewallet.sub"))
                    .amount(KiraAmount(320_000, size: .small).masked())
                KiraListRow(
                    Text("gallery.list.paylater"), leading: .category(.paylater), action: {},
                    extra: {
                        KiraTag("gallery.tag.soon", tone: .kunyit)
                        KiraProgressPita(value: 2, target: 6)
                    })
            }
            KiraListGroup("gallery.list.settings") {
                KiraListRow(Text("gallery.list.pin"), leading: .icon(.lock), trailing: .toggle($locks))
                KiraListRow(Text("gallery.list.weekly"), leading: .illustration(.surat), action: {})
                    .value(Text("gallery.list.weekly.value"))
                KiraListRow(Text("gallery.list.ojk"), leading: .icon(.shield), trailing: .external, action: {})
                KiraListRow(Text("gallery.list.admin"), leading: .initials("D", .hijau))
                    .subtitle(Text("gallery.list.admin.sub"))
                KiraListRow(Text("gallery.action.deleteAccount"), leading: .icon(.trash), action: {}).danger()
            }
            KiraListGroup("gallery.segmented.label") {
                KiraListRow(Text("gallery.segmented.snowball"), trailing: .check(method == 0), action: { method = 0 })
                KiraListRow(Text("gallery.segmented.avalanche"), trailing: .check(method == 1), action: { method = 1 })
            }
        }
    }

    #Preview { GalleryScore().galleryPage() }
    #Preview { GalleryLists().galleryPage() }
#endif
