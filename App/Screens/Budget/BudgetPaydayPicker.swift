/** The budget editor's button and selection binding for Kira's payday sheet. */
import Domain
import SwiftUI

struct BudgetPaydayPicker: View {
    let payday: Payday
    let onSelect: (Payday) -> Void
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack {
                Text("budget.payday.label").font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
                Spacer()
                Text(title).foregroundStyle(.ink)
                KiraIcon(.chevronDown, size: 18).foregroundStyle(.inkMuted)
            }
            .padding(KiraSpacing.space3)
            .kiraCard(border: .hairline, cornerRadius: KiraRadius.medium)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("budget.payday.label"))
        .accessibilityValue(Text(title))
        .kiraPaydayPicker(isPresented: $isPresented, selectedDay: payday.day) { day in
            onSelect(day.map { Payday(day: $0) } ?? .endOfMonth)
        }
    }

    private var title: LocalizedStringResource {
        if let day = payday.day { return "budget.payday.day \(day)" }
        return "budget.payday.endOfMonth"
    }
}
