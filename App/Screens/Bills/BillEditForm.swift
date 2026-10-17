import Features
import SwiftUI

/** The ordinary recurring-bill schedule fields and save action. */
struct BillEditForm: View {
    @Bindable var model: BillEditModel
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            BillEditInputFields(model: model)
            BillEditScheduleFields(model: model)
            KiraButton("bills.edit.save") { Task { await model.save() } }
                .block()
                .disabled(!model.canSave)
            KiraButton("bills.edit.delete.action", variant: .destructive, action: onDelete)
                .block()
                .disabled(!model.canDelete)
        }
    }
}
