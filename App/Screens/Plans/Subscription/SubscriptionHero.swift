/** Langganan's hero card: the plan, its price and the renewal and reminder dates (or the end, once cancelled). */
import Domain
import SwiftUI

struct SubscriptionHero: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: KiraSpacing.space3) {
                Text("subscription.hero.status \(String(localized: subscription.plan.title))")
                    .kiraFont(.overline).foregroundStyle(.onHeroMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraLogo(.mark, tone: .hero, size: 26)
            }
            .frame(minHeight: 24)
            PlanPriceLine(spacing: KiraSpacing.space2) {
                KiraAmount(Decimal(subscription.price), size: .large).inverse()
                Text(subscription.period == .monthly ? "plans.price.perMonth" : "plans.price.perYear")
                    .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.onHeroMuted)
            }
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                if subscription.cancelAtPeriodEnd {
                    line(Text("subscription.hero.ends \(subscription.renewsOn.date, format: .plansFullDay)"))
                } else {
                    line(Text("subscription.hero.renews \(subscription.renewsOn.date, format: .plansFullDay)"))
                    line(Text("subscription.hero.reminder \(subscription.reminderOn.date, format: .plansFullDay)"))
                }
            }
            .padding(.top, KiraSpacing.space1)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 64, trailing: 20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottom) {
            /**
             The hills cut to the 64 pt under the dates (the board draws 92): taller, their crest ran
             behind "Email pengingat …" and failed the contrast audit.
             */
            KiraScenery(tone: .hero, height: 64).accessibilityHidden(true)
        }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .padding(.top, KiraSpacing.space1)
    }

    private func line(_ text: Text) -> some View {
        HStack(spacing: KiraSpacing.space2) {
            KiraIcon(.calendar, size: 16)
            text.font(.subheadline).kiraLineHeight(20, size: 15)
        }
        .foregroundStyle(.onHeroMuted)
    }
}

/** Kuota Bulan Ini: chat, voice (on a plan that has it) and receipts, refilled on the reset day. */
struct SubscriptionQuotas: View {
    let usage: Usage

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.sparkle, size: 20).foregroundStyle(.pandan)
                    .frame(width: 38, height: 38)
                    .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
                VStack(alignment: .leading, spacing: 2) {
                    Text("subscription.quota.title").font(.headline).kiraLineHeight(22, size: 17)
                        .foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                    Text("subscription.quota.resets \(usage.resetsOn.date, format: .plansFullDay)")
                        .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
            ribbon(
                usage.aiMessages, label: "subscription.quota.chat",
                value: "subscription.quota.chat.value \(usage.aiMessages.used) \(usage.aiMessages.limit)")
            if usage.voiceSeconds.limit > 0 {
                ribbon(
                    usage.voiceSeconds, label: "subscription.quota.voice",
                    value: "subscription.quota.voice.value \(voiceMinutes) \(voiceHours)"
                )
            }
            ribbon(
                usage.receipts, label: "subscription.quota.receipts",
                value: "subscription.quota.receipts.value \(usage.receipts.used) \(usage.receipts.limit)")
        }
        .padding(.vertical, 18)
        .padding(.horizontal, KiraSpacing.space4)
        .kiraCard()
    }

    private var voiceMinutes: Int { usage.voiceSeconds.used / 60 }
    private var voiceHours: Int { usage.voiceSeconds.limit / 3600 }

    private func ribbon(
        _ quota: UsageMeter, label: LocalizedStringResource, value: LocalizedStringResource
    ) -> KiraProgressRibbon {
        KiraProgressRibbon(value: Double(quota.used), target: Double(quota.limit), label: label, valueLabel: value)
    }
}
