import Features
import SwiftUI

/** The ordinary recurring-bill schedule fields and save action. */
struct BillEditForm: View {
    @Bindable var model: BillEditModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            BillEditInputFields(model: model)
            BillEditScheduleFields(model: model)
            KiraButton("bills.edit.save") { Task { await model.save() } }
                .block()
                .disabled(model.isSaving)
        }
    }
}
