/**
 Gallery page for the Kira Score, each section the artifact's preview of the component with its
 words: band pills, the meter, indicator rows and the next-step card.
 */
#if DEBUG
    import Domain
    import SwiftUI

    struct GalleryScore: View {
        var body: some View {
            GallerySection(title: "gallery.section.band") {
                KiraFlowRow {
                    ForEach(ScoreBand.allCases.reversed(), id: \.self) { band in KiraBandPill(band) }
                    ForEach(ScoreBand.allCases.reversed(), id: \.self) { band in KiraBandPill(band, size: .small) }
                }
            }
            GallerySection(title: "gallery.section.meter") {
                KiraScoreMeter(Score(66), delta: 4, deltaLabel: "gallery.meter.since")
                KiraIllustration(.plant(for: Score(66).band), size: 96)
                KiraScoreMeter(Score(38), delta: 0)
                Text("gallery.type.caption").kiraFont(.caption).foregroundStyle(.inkMuted)
            }
            GallerySection(title: "gallery.section.indicator") {
                KiraRowStack {
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.fund"), value: Text("gallery.indicator.fund.value"),
                        points: Score(50), action: {}
                    )
                    .target(Text("gallery.indicator.fund.target"))
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.instalment"), value: Text("gallery.indicator.instalment.value"),
                        points: Score(70), action: {}
                    )
                    .target(Text("gallery.indicator.instalment.target"))
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.debt"), value: Text("gallery.indicator.debt.value"),
                        points: Score(50), action: {})
                    KiraIndicatorRow(
                        name: Text("gallery.indicator.assets"), value: Text("gallery.indicator.assets.value"),
                        points: Score(0)
                    )
                    .band(.vulnerable)
                }
                .padding(.vertical, KiraSpacing.space1)
                .padding(.horizontal, KiraSpacing.space4)
                .kiraCard()
            }
            GallerySection(title: "gallery.section.nextStep") {
                KiraNextStepCard(
                    "gallery.step.title", message: "gallery.step.body", primaryLabel: "gallery.action.seePlan",
                    onPrimary: {}, onSecondary: {}
                )
                .eyebrow("gallery.step.eyebrow")
                .meta("gallery.step.meta")
                .illustration(.cardPaidOff)
                .impact("gallery.step.impact")
                .secondaryLabel("ds.later")
            }
        }
    }

    #Preview { GalleryScore().galleryPage() }
#endif
