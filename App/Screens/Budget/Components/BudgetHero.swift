/**
 Budget's hero (board Budget): "Sisa uang · gajian N hari lagi", the money left in the large inverse
 amount, about how much a day, and how much of the pay is spent. The eye hides the hero's amounts
 (Rp••••••) on this screen.
 */
import Domain
import SwiftUI

struct BudgetHero: View {
    let budget: BudgetOverview
    /** The hero's eye: it masks the amounts here only, as the board draws it. */
    @State private var isMasked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            overline.kiraFont(.overline).foregroundStyle(.onHeroMuted).kiraSmallType()
                .frame(minHeight: 24, alignment: .leading)
                .padding(.trailing, 40)
            KiraAmount(budget.remaining.rupiah, size: .extraLarge).inverse().masked(isMasked)
            Text("budget.hero.perDay \(budget.perDay.rupiah, format: .rupiah.masked(isMasked))")
                .font(.subheadline).kiraLineHeight(20, size: 15)
                .foregroundStyle(.onHeroMuted)
            KiraProgressRibbon(
                value: Double(budget.used), target: Double(budget.income), label: "budget.hero.spent",
                valueLabel: "budget.hero.spentShare \(budget.spentPercent)"
            )
            .inverse()
            .padding(.top, 10)
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .overlay(alignment: .topTrailing) {
            KiraIconButton(isMasked ? .eyeOff : .eye, label: isMasked ? "budget.hero.show" : "budget.hero.hide") {
                isMasked.toggle()
            }
            .foregroundStyle(.onHero)
            .accessibilityAddTraits(isMasked ? .isSelected : [])
            .padding(.top, 10)
            .padding(.trailing, 10)
        }
    }

    private var overline: Text {
        switch budget.period.daysUntilPayday {
        case 0: Text("budget.hero.paydayToday")
        case 1: Text("budget.hero.paydayTomorrow")
        default: Text("budget.hero.paydayIn \(budget.period.daysUntilPayday)")
        }
    }
}
