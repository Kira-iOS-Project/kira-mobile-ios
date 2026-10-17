import Domain
import Features
import SwiftUI

/** Category, repetition and first due date for a recurring bill. */
struct BillCreateScheduleFields: View {
    @Bindable var model: BillCreateModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            categoryPicker
            repeatPicker
            dueDatePicker
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.create.category")
            KiraFlowRow {
                ForEach(model.categories, id: \.self) { category in
                    KiraChip(category.title, isSelected: model.category == category, leading: .category(category.tile))
                    {
                        model.category = category
                    }
                }
            }
        }
    }

    private var repeatPicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.create.repeat")
            KiraSegmented("bills.create.repeat", options: repeatOptions, selection: $model.repeatInterval)
        }
    }

    private var dueDatePicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.create.date")
            DatePicker(
                "bills.create.date", selection: dueDate, in: model.minimumDueDate...Date.distantFuture,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .tint(.pandan)
            .environment(\.calendar, Self.calendar)
            .environment(\.timeZone, Self.timeZone)
            if let error = model.dueDateError {
                Text(error).font(.footnote).foregroundStyle(.vulnerable).padding(.horizontal, 4)
            }
        }
    }

    private var repeatOptions: [KiraSegmented<BillRepeatInterval>.Option] {
        [
            .init(id: .weekly, title: "bills.create.repeat.weekly"),
            .init(id: .monthly, title: "bills.create.repeat.monthly"),
            .init(id: .yearly, title: "bills.create.repeat.yearly"),
        ]
    }

    private var dueDate: Binding<Date> {
        Binding(get: { model.dueDate.date }, set: { model.selectDueDate($0) })
    }

    private func fieldHeading(_ key: LocalizedStringResource) -> some View {
        Text(key).font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
            .padding(.horizontal, KiraSpacing.space1)
    }

    private static let calendar = Calendar(identifier: .gregorian)
    private static let timeZone = TimeZone(secondsFromGMT: CalendarDay.wibOffset) ?? .current
}
