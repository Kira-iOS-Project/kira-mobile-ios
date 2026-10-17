/**
 The card at the top of Riwayat Kira Score: the band's plant, the score out of 100, its band and
 its move since last month, the 6 Bulan / 1 Tahun choice, the monthly bars and the sentence under
 them. While the other range loads, the bars of the last one stay, dimmed.
 */
import Domain
import Features
import SwiftUI

struct ScoreHistoryCard: View {
    let history: ScoreHistory
    /** Nil while the placeholder shows. */
    let model: ScoreHistoryModel?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                KiraIllustration(KiraIllustrationName.plant(for: history.band), size: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .hairline(cornerRadius: 18)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    scoreLine
                    KiraFlowRow {
                        KiraBandPill(history.band, size: .small)
                        if let delta = history.deltaText {
                            Text(delta)
                                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                                .foregroundStyle((history.deltaFromPrevious ?? 0) > 0 ? Color.healthy : Color.inkMuted)
                        }
                    }
                }
            }
            KiraSegmented("score.history.range", options: options, selection: selection)
            KiraBars(history.chartLabel(model?.range ?? .sixMonths), columns: history.columns, height: 120)
                .opacity(model?.isSwitching == true ? 0.5 : 1)
            if let trend = history.trendText {
                Text(trend).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
        }
        .padding(KiraSpacing.space5)
        .kiraCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("score.history.cardLabel"))
    }

    /** "66 /100". */
    private var scoreLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space1) {
            Text(history.score, format: .number)
                .font(KiraFont.display(40, axisWeight: 800, relativeTo: .largeTitle, typeSize: typeSize))
                .kiraLineHeight(42, size: 40, relativeTo: .largeTitle)
                .tracking(-1.2)
                .monospacedDigit()
            Text("score.history.outOf")
                .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                .foregroundStyle(.inkMuted)
        }
        .accessibilityElement(children: .combine)
    }

    private var options: [KiraSegmented<ScoreHistoryRange>.Option] {
        ScoreHistoryRange.allCases.map { .init(id: $0, title: $0.title) }
    }

    private var selection: Binding<ScoreHistoryRange> {
        Binding(
            get: { model?.range ?? .sixMonths },
            set: { range in Task { await model?.select(range) } })
    }
}
