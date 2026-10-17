/**
 "Tanggal" (board TambahAset): drawn as a Field with the calendar icon, read-only; tapping it opens
 the calendar under it, today at the latest.
 */
import Domain
import Features
import SwiftUI

struct AssetDayField: View {
    @Bindable var model: AssetFormModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("asset.day").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
                .accessibilityHidden(true)
            box
            if model.isPickingDay {
                DatePicker(selection: $model.valuedOn, in: ...model.latestDay, displayedComponents: .date) {
                    Text("asset.day")
                }
                .datePickerStyle(.graphical)
                .tint(.pandan)
            }
            if let issue = model.issue(in: .day) {
                Text(issue.message).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.vulnerable)
                    .padding(.horizontal, 4)
            }
        }
    }

    /** The box: the day and the calendar icon, its border vulnerable while the day is refused. */
    private var box: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) { model.isPickingDay.toggle() }
        } label: {
            HStack(spacing: KiraSpacing.space2) {
                Text(model.valuedOn, format: .kiraDate).font(.body).foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.calendar, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space4)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .kiraCard(border: model.issue(in: .day) == nil ? .hairline : .vulnerable, cornerRadius: KiraRadius.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("asset.day"))
        .accessibilityValue(Text(model.valuedOn, format: .kiraDate))
    }
}
