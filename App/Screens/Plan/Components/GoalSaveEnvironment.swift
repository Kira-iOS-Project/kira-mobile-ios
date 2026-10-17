/**
 How a Hasil Simulasi saves, set by the route that opened it: Tujuan Baru's "Jadikan Pos Budget"
 creates the goal; Ubah Tujuan's "Simpan Perubahan" changes the goal through the route's own
 `GoalBudgetModel`, which DP Rumah's and Menikah's results use in place of theirs.
 */
import Features
import SwiftUI

extension EnvironmentValues {
    /** The result's save button. */
    @Entry var goalSaveLabel: LocalizedStringResource = "plan.result.budget"
    /** Ubah Tujuan's save, for the results that otherwise create the goal themselves; nil for a new goal. */
    @Entry var goalEditBudget: GoalBudgetModel?
}
