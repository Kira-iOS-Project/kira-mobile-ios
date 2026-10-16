/**
 The successful-save dialog for Atur Budget. Its parent presents this only after the server confirms
 the updated allocations; the primary button closes it back to the screen that triggered the save.
 */
import SwiftUI

extension View {
    /** Presents the saved-budget result while `isPresented` is true. */
    func budgetSaveSuccessDialog(isPresented: Binding<Bool>) -> some View {
        kiraDialog(isPresented: isPresented) {
            KiraDialog(
                "budget.save.success.title",
                message: "budget.save.success.message",
                art: .success,
                primary: KiraButton("budget.save.success.done") {}
            )
        }
    }
}
