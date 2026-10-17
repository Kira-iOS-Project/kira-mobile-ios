/**
 Perayaan Lunas (SKR-05): the sheet that opens once, when a payment settles an account. It names the
 account, the one the plan moves to next, and the score the engine expects; with no account left it
 offers the way to Kira Score. The score is an estimate, and says so.
 */
import Domain
import Features
import SwiftUI

struct PayoffCelebration: View {
    let payment: DebtPayment
    let name: String
    /** Closes the sheet, and opens `destination` when there is one. */
    let onClose: (AppRoute?) -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.cardPaidOff, size: 140)
            VStack(spacing: KiraSpacing.space2) {
                Text("plan.celebrate.title \(name)").kiraFont(.title).foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                if let next = payment.nextAccount {
                    Text("plan.celebrate.next \(next.name)").kiraFont(.callout).foregroundStyle(.inkMuted)
                }
            }
            .multilineTextAlignment(.center)
            if let estimate = payment.scoreEstimate {
                KiraNotice(.simulation, title: PayoffPlanCopy.score(estimate), message: "plan.celebrate.estimate")
            }
            actions
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.bottom, KiraSpacing.space6)
    }

    @ViewBuilder private var actions: some View {
        if payment.nextAccount == nil {
            KiraButtonPair(
                secondary: KiraButton("plan.celebrate.later", variant: .secondary) { onClose(nil) },
                primary: KiraButton("plan.celebrate.scoreCta") { onClose(.score) })
        } else {
            KiraButton("plan.celebrate.continue") { onClose(nil) }.block()
        }
    }
}
