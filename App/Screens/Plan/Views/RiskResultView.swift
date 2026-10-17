/**
 REN-07, Hasil Kuis (board HasilRisiko): the scenery behind the profile card (the stairs, "Profil
 risikomu", the profile and its sentence, the three-step scale), Pelajari Dulu with the six asset
 classes lowest risk first, each opening its module, the education notice, then Ulangi Kuis and
 Mulai Belajar (Reksa Dana Pasar Uang's module), 1 to 1.3.
 */
import Domain
import Features
import SwiftUI

struct RiskResultView: View {
    let profile: RiskProfile
    let onOpen: (AppRoute) -> Void
    let onRestart: () -> Void
    let onBack: () -> Void

    var body: some View {
        PlanScreenFrame {
            KiraScenery(hasSun: true, height: 150).padding(.top, 50)
        } content: {
            KiraNavBar(
                "plan.risk.result.title", subtitle: "plan.risk.result.subtitle",
                leading: .back("plan.risk.result.back", onBack)
            ) {
                KiraHelpButton(.icon) { onOpen(.care) }
            }
            RiskProfileCard(profile: profile).padding(.top, 80)
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("plan.risk.result.learn", trailing: .note("plan.risk.result.learn.note"))
                KiraListGroup(footer: "plan.risk.result.learn.footer") {
                    ForEach(AssetClass.allCases, id: \.self) { asset in
                        KiraListRow(Text(asset.title), leading: .category(asset.tile), trailing: .chevron) {
                            onOpen(.assetModule(asset))
                        } extra: {
                            KiraTag(asset.risk.title, tone: asset.risk.tone)
                        }
                        .subtitle(Text(asset.subtitle))
                    }
                }
            }
            .padding(.top, KiraSpacing.space2)
            KiraNotice(.education, title: "plan.risk.education.title", message: "plan.risk.result.education.body")
            Spacer(minLength: KiraSpacing.space1)
            PlanButtonRow(
                secondary: KiraButton("plan.risk.result.restart", variant: .secondary, action: onRestart),
                primary: KiraButton("plan.risk.result.start") { onOpen(.assetModule(.moneyMarketFund)) })
        }
    }
}
