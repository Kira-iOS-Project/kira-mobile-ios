/**
 Ringkasan Mingguan's body as the board lays it: Kuku with the hand note, the title and the days;
 the total against the week before with the bars; Terbesar Minggu Ini; Catatan Minggu Ini; and
 Lihat Riwayat.
 */
import Domain
import SwiftUI

struct WeeklySummaryContent: View {
    let summary: WeeklySummary
    let onHistory: () -> Void

    var body: some View {
        WeeklySummaryHeader(summary: summary)
        WeeklySummaryTotal(summary: summary)
        KiraSectionTitle("summary.weekly.top").padding(.top, KiraSpacing.space1)
        KiraListGroup {
            ForEach(summary.topShares, id: \.self) { share in
                KiraListRow(
                    Text(share.spending.category.title), leading: .category(share.spending.category.tile)
                ) {
                    KiraProgressRibbon(value: Double(share.spending.amount), target: Double(summary.total))
                }
                .subtitle(Text("summary.weekly.share \(share.percent)"))
                .amount(KiraAmount(Decimal(share.spending.amount), size: .small))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("summary.weekly.top.label"))
        if let note = summary.note {
            KiraNotice(.info, title: "summary.weekly.tip.title", message: note)
        }
        KiraButton("summary.weekly.history", action: onHistory).icon(.list).block()
            .padding(.top, KiraSpacing.space1)
    }
}

/** Kuku, the hand note, "Uangmu ke Mana Minggu Ini" and the week's days. */
private struct WeeklySummaryHeader: View {
    let summary: WeeklySummary

    var body: some View {
        VStack(spacing: KiraSpacing.space2) {
            KiraMascot(.calm, size: 124).accessibilityLabel(Text("summary.weekly.mascot"))
            KiraHandNote(summary.handNote, tilt: -2)
            Text("summary.weekly.headline").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text(summary.daysText).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

/** "Total pengeluaran", the amount, the comparison, the bars and the busiest and quietest days. */
private struct WeeklySummaryTotal: View {
    let summary: WeeklySummary

    var body: some View {
        let tag = summary.comparisonTag
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            Text("summary.weekly.total").kiraFont(.overline).foregroundStyle(.inkMuted)
            KiraAmount(Decimal(summary.total), size: .large)
            KiraTag(tag.text, tone: tag.isLess ? .healthy : .neutral)
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                KiraBars(summary.chartLabel, columns: summary.columns, height: 112)
                if let extremes = summary.extremesText {
                    extremes.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
            .padding(.top, KiraSpacing.space1)
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("summary.weekly.total.label"))
    }
}
