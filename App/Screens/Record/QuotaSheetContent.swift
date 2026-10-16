/**
 Kuota AI (canvas KuotaAI, CAT-09): a calm sheet when a month's quota is used up. When it fills
 again, the ribbon at its end, what keeps working without AI, and two equal choices, Lihat Paket and
 Catat Manual. No countdown and no pressure; Lihat Paket only shows the plans. The board draws the
 chat quota; receipts (CAT-05) and voice use the same sheet with their own words.
 */
import Domain
import Features
import SwiftUI

struct QuotaSheetContent: View {
    let sheet: QuotaSheet
    let onPlans: () -> Void
    let onManual: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space1) {
            KiraIllustration(.receipt, size: 96)
            Text(title)
                .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                .tracking(-0.33)
                .foregroundStyle(.ink)
                .padding(.top, KiraSpacing.space2)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.subheadline).kiraLineHeight(21, size: 15)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: 300)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        KiraProgressRibbon(
            value: Double(sheet.counter.used), target: Double(sheet.counter.limit), label: ribbonLabel,
            valueLabel: "record.quota.ribbonValue \(sheet.counter.used / unit) \(sheet.counter.limit / unit)")
        KiraNotice(.safe, message: "record.quota.free")
        Spacer(minLength: 0)
        KiraButtonPair(
            secondary: KiraButton("record.quota.plans", variant: .secondary, action: onPlans),
            primary: KiraButton("record.quota.manual", action: onManual))
    }

    /** Voice is counted in seconds and shown in minutes. */
    private var unit: Int { sheet.kind == .voice ? 60 : 1 }

    private var resets: String { sheet.resetsOn.formatted(.kiraDate) }

    private var title: LocalizedStringResource {
        switch sheet.kind {
        case .aiMessages: "record.quota.chatTitle"
        case .receipts: "record.quota.receiptTitle"
        case .voice: "record.quota.voiceTitle"
        }
    }

    private var message: LocalizedStringResource {
        let used = sheet.counter.used
        let limit = sheet.counter.limit
        switch sheet.kind {
        case .aiMessages: return "record.quota.chatBody \(used) \(limit) \(resets)"
        case .receipts: return "record.quota.receiptBody \(used) \(limit) \(resets)"
        case .voice: return "record.quota.voiceBody \(used / unit) \(limit / unit) \(resets)"
        }
    }

    private var ribbonLabel: LocalizedStringResource {
        switch sheet.kind {
        case .aiMessages: "record.quota.chatRibbon"
        case .receipts: "record.quota.receiptRibbon"
        case .voice: "record.quota.voiceRibbon"
        }
    }
}

extension PlanID {
    /** The plan's name: "Kira Gratis", "Kira Muda", "Kira Plus". */
    var recordName: LocalizedStringResource {
        switch self {
        case .free: "record.plan.free"
        case .young: "record.plan.young"
        case .plus: "record.plan.plus"
        }
    }
}
