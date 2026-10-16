/**
 BRD-03, Beranda for getting out of debt: what is paid off so far (no red, no warning), the step,
 the micro emergency-fund target and Mode Darurat Utang, free on every plan.
 */
import Domain
import Features
import SwiftUI

struct HomeDebtPlanSections: View {
    let home: HomeOverview
    let model: HomeModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        if let plan = home.debtPlan {
            HomeDebtPlanCard(plan: plan) { onOpen(.unavailable(.debtPlan)) }
        }
        if let step = model.visibleStep {
            HomeStepSection(step: step, home: home, model: model, onOpen: onOpen)
        }
        if let target = home.microTarget {
            HomeMicroTargetCard(target: target)
        }
        HomeDebtEmergencyCard { onOpen(.unavailable(.debtEmergency)) }
    }
}

private struct HomeDebtPlanCard: View {
    let plan: DebtPlanProgress
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            content
                .padding(KiraSpacing.space5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
                .background(.hero)
                .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("home.debt.open"))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("home.debt.overline").kiraFont(.overline).kiraSmallType()
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                KiraIcon(.chevronRight, size: 20)
            }
            .foregroundStyle(.onHeroMuted)
            .frame(minHeight: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text("home.debt.paidOff").font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.onHeroMuted)
                KiraAmount(plan.paidOff.rupiah, size: .extraLarge).inverse()
            }
            .padding(.top, 2)
            Text(plan.hasPaidSome ? "home.debt.encourage" : "home.debt.start")
                .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.onHeroMuted)
            VStack(alignment: .leading, spacing: 10) {
                KiraProgressRibbon(
                    value: Double(plan.paidOff),
                    target: Double(plan.total),
                    label: "home.debt.percent \(plan.percent)",
                    valueLabel: "home.debt.ofTotal \(plan.total.rupiah, format: .rupiah)"
                )
                .inverse()
                Text("home.debt.remaining \(remaining)")
                    .font(.subheadline.monospacedDigit()).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.onHeroMuted)
            }
            .padding(.top, KiraSpacing.space3)
        }
    }

    /** The total left, set in semibold on-hero inside its sentence. */
    private var remaining: Text {
        Text(plan.remaining.rupiah, format: .rupiah).fontWeight(.semibold).foregroundStyle(.onHero)
    }
}

private struct HomeMicroTargetCard: View {
    let target: MicroTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: KiraSpacing.space3) {
                KiraCategoryIcon(.emergency)
                VStack(alignment: .leading, spacing: 2) {
                    Text("home.micro.overline").kiraFont(.overline).foregroundStyle(.pandan).kiraSmallType()
                    Text(target.kind == .oneWeek ? "home.micro.week" : "home.micro.month")
                        .font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            KiraProgressRibbon(
                value: Double(target.current),
                target: Double(target.target),
                label: "home.micro.current \(target.current.rupiah, format: .rupiah)",
                valueLabel: "home.micro.ofTarget \(target.target.rupiah, format: .rupiah)"
            )
            .caption(target.kind == .oneWeek ? "home.micro.weekCaption" : "home.micro.monthCaption")
            /** The bar's visible label is the amount alone; VoiceOver hears what it counts. */
            .accessibilityLabel(Text("home.micro.spoken \(target.current.rupiah, format: .rupiah)"))
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

private struct HomeDebtEmergencyCard: View {
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.shield, size: 22)
                    .foregroundStyle(.pandan)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("home.emergency.title").font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                        .foregroundStyle(.ink)
                    Text("home.emergency.subtitle").font(.footnote).kiraLineHeight(18, size: 13)
                        .foregroundStyle(.inkMuted)
                    KiraTag("home.emergency.free", tone: .pandan, icon: .heart).padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(14)
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
