/** A simple payday selector; KIR-119 replaces this menu with the dedicated picker sheet. */
import Domain
import SwiftUI

struct BudgetPaydayMenu: View {
    let payday: Payday
    let onSelect: (Payday) -> Void

    var body: some View {
        Menu {
            ForEach(Payday.days, id: \.self) { day in
                Button("budget.payday.day \(day)") { onSelect(Payday(day: day)) }
            }
            Button("budget.payday.endOfMonth") { onSelect(.endOfMonth) }
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
        .accessibilityValue(Text(title))
    }

    private var title: LocalizedStringResource {
        if let day = payday.day { return "budget.payday.day \(day)" }
        return "budget.payday.endOfMonth"
    }
}
