/**
 Catat's top bar (canvas Catat): the list button to Riwayat on the left, "Catat" with the payday
 period under it in the middle, the help heart on the right; a surface band with a hairline under it.
 */
import Domain
import SwiftUI

struct RecordHeader: View {
    let profile: RecordProfile?
    let onHistory: () -> Void
    let onHelp: () -> Void

    var body: some View {
        HStack(spacing: KiraSpacing.space4) {
            KiraIconButton(.list, label: "record.history", variant: .outline, action: onHistory)
            VStack(spacing: 0) {
                Text("record.title")
                    .font(.headline).kiraLineHeight(22, size: 17)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                if let profile {
                    period(profile)
                        .font(.caption).kiraLineHeight(16, size: 12)
                        .foregroundStyle(.inkMuted)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
            KiraHelpButton(.icon, action: onHelp)
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.bottom, KiraSpacing.space2)
        .background(.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(.hairline).frame(height: 1) }
    }

    /** "Periode 25 September – 24 Oktober 2026". */
    private func period(_ profile: RecordProfile) -> Text {
        let start = profile.periodStart.formatted(.kiraDayMonth)
        return Text("record.period \(start) \(profile.periodEnd.formatted(.kiraDate))")
    }
}
