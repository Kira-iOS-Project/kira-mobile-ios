/**
 Kuota AI Bulan Ini on Profil: a ribbon for Chat AI and one for Scan Struk, the day the quota fills
 again, and Lihat Paket. A full ribbon never blocks manual entry, as the card's line says.
 */
import Domain
import SwiftUI

/** The AI quota card. */
struct ProfileQuotaCard: View {
    let usage: Usage
    let onPlans: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.sparkle, size: 20)
                    .foregroundStyle(.pandan)
                    .frame(width: 38, height: 38)
                    .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("account.profile.quota.title").font(.headline).accessibilityAddTraits(.isHeader)
                    Text("account.profile.quota.subtitle")
                        .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                /**
                 The column's whole width, growing downwards: sized to its own one-line width, the
                 title is reported by the accessibility audit as clipped (as KiraListRow's text was).
                 */
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            KiraProgressRibbon(
                value: Double(usage.aiMessages.used), target: Double(usage.aiMessages.limit),
                label: "account.profile.quota.chat",
                valueLabel: "account.profile.quota.chat.value \(usage.aiMessages.used) \(usage.aiMessages.limit)")
            KiraProgressRibbon(
                value: Double(usage.receipts.used), target: Double(usage.receipts.limit),
                label: "account.profile.quota.receipts",
                valueLabel: "account.profile.quota.receipts.value \(usage.receipts.used) \(usage.receipts.limit)")
            footer
        }
        .padding(EdgeInsets(top: 18, leading: 16, bottom: 16, trailing: 16))
        .kiraCard(cornerRadius: KiraRadius.large)
    }

    /** The reset day beside Lihat Paket, above it at the accessibility text sizes. */
    private var footerLayout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space3))
            : AnyLayout(HStackLayout(spacing: KiraSpacing.space3))
    }

    private var footer: some View {
        footerLayout {
            HStack(spacing: 6) {
                KiraIcon(.refresh, size: 16).accessibilityHidden(true)
                Text("account.profile.quota.resets \(usage.resetsOn.date, format: .accountDay)")
            }
            .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13)
            .foregroundStyle(.inkMuted)
            /** Fills the row instead of a Spacer, so only the board's one 12 pt gap stays. */
            .frame(maxWidth: .infinity, alignment: .leading)
            /** At its own width, so the reset day keeps the rest on one line as on the board. */
            KiraButton("account.profile.quota.plans", variant: .secondary, size: .small, action: onPlans)
                .fixedSize()
        }
        .padding(.top, 14)
        .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
    }
}
