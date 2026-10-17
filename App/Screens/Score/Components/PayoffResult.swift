/**
 What the plan comes to, as the RencanaPelunasan boards lay it: the hero ("Kalau mulai bulan ini",
 the first account and its day, and when every consumer debt is paid off), "Urutan Pelunasan" with
 the debts the plan leaves alone at its end, then the other method (SKR-03c) and "Hanya Simulasi".
 */
import Domain
import SwiftUI

/** "Kalau mulai bulan ini": the first account paid off, and all of them. */
struct PayoffHero: View {
    let simulation: PayoffSimulation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("payoff.hero.overline").kiraFont(.overline).kiraSmallType().foregroundStyle(.onHeroMuted)
            if let first = simulation.firstAccount {
                Text("payoff.hero.first \(first.name)").kiraFont(.headline).padding(.top, KiraSpacing.space2)
                Text(PayoffCopy.heroDate(first))
                    .font(KiraFont.display(36, .heavy, relativeTo: .largeTitle))
                    .kiraLineHeight(42, size: 36, natural: 1.26, relativeTo: .largeTitle)
                    .tracking(-0.9).monospacedDigit()
            }
            HStack(spacing: 10) {
                KiraIcon(.check, size: 16, weight: .bold)
                    .frame(width: 28, height: 28).background(.heroTrack, in: Circle())
                Text(PayoffCopy.allPaid(simulation)).kiraFont(.callout)
            }
            .padding(.top, 14)
            .overlay(alignment: .top) { Rectangle().fill(.heroTrack).frame(height: 1) }
            .padding(.top, 14)
        }
        .foregroundStyle(.onHero)
        /** The board's 22 pt at the bottom puts the last line on the hills; 64, as SubscriptionHero, keeps it clear. */
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 64, trailing: 20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/** "Urutan Pelunasan": the consumer accounts in the plan's order, then the debts it leaves alone. */
struct PayoffOrderList: View {
    let simulation: PayoffSimulation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("payoff.order.title", trailing: .note(PayoffCopy.orderNote(simulation.method)))
            VStack(spacing: KiraSpacing.space2) {
                ForEach(simulation.accounts, id: \.id) { account in
                    PayoffOrderRow(
                        rank: account.position, category: account.kind.category, name: account.name,
                        remaining: account.remaining, when: PayoffCopy.when(account),
                        tag: PayoffCopy.tag(account, in: simulation), isFirst: account.position == 1)
                }
                ForEach(Array(simulation.productive.enumerated()), id: \.element.id) { index, debt in
                    PayoffOrderRow(
                        rank: simulation.accounts.count + index + 1, category: debt.kind.category, name: debt.name,
                        remaining: debt.remaining, when: nil, tag: "payoff.tag.productive", isFirst: false)
                }
            }
        }
        .padding(.top, KiraSpacing.space1)
    }
}

/** One account: its tile with the rank, the name, what is left, when it is paid off, and its tag. */
private struct PayoffOrderRow: View {
    let rank: Int
    let category: KiraCategory
    let name: String
    let remaining: Int
    let when: LocalizedStringResource?
    let tag: LocalizedStringResource
    let isFirst: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            KiraCategoryIcon(category)
                .overlay(alignment: .topLeading) {
                    Text(rank, format: .number)
                        .font(KiraFont.display(11, .heavy, relativeTo: .caption2))
                        .kiraSmallType()
                        .foregroundStyle(isFirst ? .onPandan : .ink)
                        .frame(width: 20, height: 20)
                        .background(isFirst ? Color.pandan : Color.surfaceMuted, in: Circle())
                        .overlay(Circle().strokeBorder(.surfaceRaised, lineWidth: 2))
                        .offset(x: -7, y: -7)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(name).kiraFont(.headline).foregroundStyle(.ink)
                Text("payoff.row.remaining \(PayoffCopy.rupiah(remaining))").kiraFont(.callout)
                    .foregroundStyle(.inkMuted)
                if let when {
                    Text(when).kiraFont(.callout).foregroundStyle(.inkMuted)
                }
                KiraTag(tag, tone: isFirst ? .pandan : .neutral).padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
        .kiraCard(cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .combine)
    }
}

/** The other method against this one, the rates still missing, and "Hanya Simulasi". */
struct PayoffNotices: View {
    let simulation: PayoffSimulation

    var body: some View {
        if let comparison = simulation.comparison {
            KiraNotice(
                .info, title: PayoffCopy.comparisonTitle(simulation.method),
                message: PayoffCopy.comparison(comparison, chosen: simulation.method))
        }
        if simulation.hasUnknownRate {
            KiraNotice(.info, title: "payoff.unknownRate.title", message: "payoff.unknownRate.body")
        }
        KiraNotice(.simulation, title: "payoff.simulation.title", message: "payoff.simulation.body")
    }
}
