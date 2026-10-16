/**
 BRD-01's hero: the money left this pay period, about how much a day, and how much of the pay is
 spent. The card opens Budget; the eye hides every amount on Beranda (Rp••••••).
 */
import Domain
import Features
import SwiftUI

struct HomeMoneyCard: View {
    let money: PeriodMoney
    let period: PayPeriod
    let model: HomeModel
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 6) {
                overline.kiraFont(.overline).foregroundStyle(.onHeroMuted).kiraSmallType()
                    .frame(minHeight: 24, alignment: .leading)
                    .padding(.trailing, 40)
                KiraAmount(money.remaining.rupiah, size: .extraLarge).inverse().masked(model.isMasked)
                Text("home.money.perDay \(money.perDay.rupiah, format: .rupiah.masked(model.isMasked))")
                    .font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.onHeroMuted)
                KiraProgressRibbon(
                    value: Double(money.spent),
                    target: Double(money.income), label: "home.money.spent",
                    valueLabel: "home.money.spentShare \(money.spentPercent)"
                )
                .inverse()
                .padding(.top, 10)
            }
            .padding(KiraSpacing.space5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .bottom) {
                KiraScenery(tone: .hero, height: 92).accessibilityHidden(true)
            }
            .background(.hero)
            .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("home.money.openBudget"))
        .overlay(alignment: .topTrailing) {
            KiraIconButton(
                model.isMasked ? .eyeOff : .eye, label: model.isMasked ? "home.money.show" : "home.money.hide"
            ) {
                Task { await model.toggleMasked() }
            }
            .foregroundStyle(.onHero)
            .accessibilityAddTraits(model.isMasked ? .isSelected : [])
            .padding(.top, 10)
            .padding(.trailing, 10)
        }
    }

    private var overline: Text {
        switch period.daysUntilPayday {
        case 0: Text("home.money.paydayToday")
        case 1: Text("home.money.paydayTomorrow")
        default: Text("home.money.paydayIn \(period.daysUntilPayday)")
        }
    }
}
