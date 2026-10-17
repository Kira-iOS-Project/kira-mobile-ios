import Domain
import Features
import SwiftUI

/** The category, recurrence and next date of an ordinary recurring bill. */
struct BillEditScheduleFields: View {
    @Bindable var model: BillEditModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            categoryPicker
            repeatPicker
            dueDatePicker
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.edit.category")
            KiraFlowRow {
                ForEach(model.categories, id: \.self) { category in
                    KiraChip(
                        category.title, isSelected: model.draft?.category == category, leading: .category(category.tile)
                    ) {
                        model.draft?.category = category
                    }
                }
            }
        }
    }

    private var repeatPicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.edit.repeat")
            KiraSegmented("bills.edit.repeat", options: repeatOptions, selection: repeatInterval)
        }
    }

    private var dueDatePicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            fieldHeading("bills.edit.date")
            DatePicker("bills.edit.date", selection: dueDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .tint(.pandan)
                .environment(\.calendar, Self.calendar)
                .environment(\.timeZone, Self.timeZone)
        }
    }

    private var repeatOptions: [KiraSegmented<BillRepeatInterval>.Option] {
        [
            .init(id: .weekly, title: "bills.edit.repeat.weekly"),
            .init(id: .monthly, title: "bills.edit.repeat.monthly"),
            .init(id: .yearly, title: "bills.edit.repeat.yearly"),
        ]
    }

    private var repeatInterval: Binding<BillRepeatInterval> {
        Binding(get: { model.draft?.repeatInterval ?? .monthly }, set: { model.draft?.repeatInterval = $0 })
    }

    private var dueDate: Binding<Date> {
        Binding(
            get: { model.draft?.nextDueDate.date ?? Date.distantPast },
            set: { model.draft?.nextDueDate = CalendarDay($0) })
    }

    private func fieldHeading(_ key: LocalizedStringResource) -> some View {
        Text(key).font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
            .padding(.horizontal, KiraSpacing.space1)
    }

    private static let calendar = Calendar(identifier: .gregorian)
    private static let timeZone = TimeZone(secondsFromGMT: CalendarDay.wibOffset) ?? .current
}
