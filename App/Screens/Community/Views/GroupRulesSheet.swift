/**
 Aturan Komunitas Kira (KOM-03): five rules, and "Setuju dan Lanjut" once "Aku sudah membaca dan
 setuju" is ticked; the acceptance is kept with the rules' version. The X closes without it.
 Komunitas's "Baca Aturan" shows the list alone.
 */
import Features
import SwiftUI

struct GroupRulesSheet: View {
    @Bindable var model: GroupDetailModel

    var body: some View {
        ScrollView {
            VStack(spacing: KiraSpacing.space4) {
                CommunityRulesList()
                KiraListGroup {
                    KiraListRow(Text("community.rules.agree"), trailing: .check(model.rulesAgreed)) {
                        model.rulesAgreed.toggle()
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        KiraButton("community.rules.continue") { Task { await model.acceptRules() } }
            .block()
            .disabled(!model.rulesAgreed || model.isWorking)
            .padding(.bottom, KiraSpacing.space2)
    }
}

/** The sentence and the five rules of the community. */
struct CommunityRulesList: View {
    /** One rule: its icon, its title and its sentence. */
    private struct Rule {
        let icon: KiraIconName
        let title: LocalizedStringResource
        let detail: LocalizedStringResource
    }

    private let rules = [
        Rule(icon: .shield, title: "community.rules.noDefault", detail: "community.rules.noDefault.detail"),
        Rule(
            icon: .trendUp, title: "community.rules.noProfitPromise", detail: "community.rules.noProfitPromise.detail"),
        Rule(icon: .link, title: "community.rules.affiliate", detail: "community.rules.affiliate.detail"),
        Rule(icon: .lock, title: "community.rules.noDataTrade", detail: "community.rules.noDataTrade.detail"),
        Rule(icon: .eyeOff, title: "community.rules.privacy", detail: "community.rules.privacy.detail"),
    ]

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            Text("community.rules.lead").kiraFont(.callout).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, KiraSpacing.space1)
                .padding(.top, -4)
            KiraListGroup {
                ForEach(rules.indices, id: \.self) { index in
                    KiraListRow(Text(rules[index].title), leading: .icon(rules[index].icon), trailing: .none)
                        .subtitle(Text(rules[index].detail))
                }
            }
            .accessibilityLabel(Text("community.rules.listLabel"))
        }
    }
}
