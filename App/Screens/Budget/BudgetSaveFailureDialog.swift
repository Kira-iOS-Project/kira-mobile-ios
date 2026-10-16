/**
 The failed-save dialog for Atur Budget. The screen owns its entered budget values and passes the
 same save action here, so retrying closes this overlay without replacing the draft behind it.
 */
import SwiftUI

extension View {
    /** Presents the connection failure dialog while `isPresented` is true. */
    func budgetSaveFailureDialog(isPresented: Binding<Bool>, onRetry: @escaping () -> Void) -> some View {
        kiraDialog(isPresented: isPresented) {
            KiraDialog(
                "budget.save.failure.title",
                message: "budget.save.failure.message",
                art: .illustration(.umbrella),
                primary: KiraButton("budget.save.failure.retry", action: onRetry),
                secondary: KiraButton("budget.save.failure.close", variant: .secondary) {}
            )
        }
    }
}
