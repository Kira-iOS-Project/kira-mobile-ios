/** The warm warning shown when planned categories add up to more than monthly income. */
import SwiftUI

struct BudgetOverallocationNotice: View {
    var body: some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            KiraIcon(.alert, size: 18, weight: .semibold).foregroundStyle(.coping).padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text("budget.overallocated.title").font(.subheadline.weight(.semibold)).foregroundStyle(.ink)
                Text("budget.overallocated.body").font(.footnote).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KiraSpacing.space3)
        .kiraCard(.copingSoft, border: .copingLine, cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .combine)
    }
}
