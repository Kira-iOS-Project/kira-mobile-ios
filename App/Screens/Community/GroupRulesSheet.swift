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
    private let rules: [(KiraIconName, LocalizedStringResource, LocalizedStringResource)] = [
        (.shield, "community.rules.noDefault", "community.rules.noDefault.detail"),
        (.trendUp, "community.rules.noProfitPromise", "community.rules.noProfitPromise.detail"),
        (.link, "community.rules.affiliate", "community.rules.affiliate.detail"),
        (.lock, "community.rules.noDataTrade", "community.rules.noDataTrade.detail"),
        (.eyeOff, "community.rules.privacy", "community.rules.privacy.detail"),
    ]

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            Text("community.rules.lead").kiraFont(.callout).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, KiraSpacing.space1)
                .padding(.top, -4)
            KiraListGroup {
                ForEach(rules.indices, id: \.self) { index in
                    KiraListRow(Text(rules[index].1), leading: .icon(rules[index].0), trailing: .none)
                        .subtitle(Text(rules[index].2))
                }
            }
            .accessibilityLabel(Text("community.rules.listLabel"))
        }
    }
}
