/**
 Jadikan Pos Budget's failure, over a goal's result (a full screen, so nothing closes): the
 problem's sentence, Coba Lagi to create the goal again, and Tutup.
 */
import APIClient
import Domain
import Features
import SwiftUI

extension View {
    /** The failure dialog of `budget`'s create; Coba Lagi sends `draft` again. */
    func goalBudgetDialog(_ budget: GoalBudgetModel, draft: GoalDraft) -> some View {
        kiraDialog(
            isPresented: Binding(get: { budget.failure != nil }, set: { if !$0 { budget.failure = nil } })
        ) {
            KiraDialog(
                "plan.result.budget.failed", message: (budget.failure ?? .connectionLost).failureMessage,
                art: .illustration(.umbrella),
                primary: KiraButton("plan.result.budget.retry") { Task { await budget.save(draft) } },
                secondary: KiraButton("plan.result.budget.close", variant: .secondary) {})
        }
    }
}
