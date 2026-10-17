import SwiftUI

/** The summary's loading placeholders. */
struct WeeklyLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraListGroup("weekly.totals") {
                KiraListRow(Text("weekly.expense")).redacted(reason: .placeholder)
                KiraListRow(Text("weekly.income")).redacted(reason: .placeholder)
            }
            KiraBars("weekly.chart.accessibility", columns: [])
                .padding(KiraSpacing.space4).kiraCard().redacted(reason: .placeholder)
        }
        .disabled(true)
    }
}

/** A no-activity week, with no fabricated financial note. */
struct WeeklyEmptyView: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraMascot(.calm, size: 144)
            Text("weekly.empty.title").kiraFont(.title).foregroundStyle(.ink)
            Text("weekly.empty.body")
                .font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KiraSpacing.space8)
    }
}
