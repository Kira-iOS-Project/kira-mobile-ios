/**
 Tanggal on Tambah and Ubah Tagihan: the chosen date as it repeats ("Tiap Tanggal 22"), and Pilih
 Tanggal, the sheet with the calendar that sets it.
 */
import Domain
import SwiftUI

/** Tanggal: "Pilih Tanggal" until chosen, then how it repeats; opens Pilih Tanggal. */
struct BillDateField: View {
    @Binding var dueOn: CalendarDay?
    let repeats: BillRepeat
    @State private var isPicking = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("bills.add.date").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1).accessibilityHidden(true)
            Button {
                isPicking = true
            } label: {
                HStack(spacing: KiraSpacing.space3) {
                    value.font(.body).kiraLineHeight(22, size: 17).foregroundStyle(dueOn == nil ? .inkMuted : .ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    KiraIcon(.calendar, size: 22).foregroundStyle(.inkMuted)
                }
                .padding(.horizontal, KiraSpacing.space4)
                .frame(minHeight: 52)
                .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
                        .strokeBorder(isPicking ? Color.pandan : .hairline, lineWidth: 1.5)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("bills.add.date"))
            .accessibilityValue(value)
        }
        .kiraSheet(isPresented: $isPicking, title: "bills.add.date.sheet") {
            BillDateSheet(dueOn: $dueOn, isPresented: $isPicking)
        }
    }

    /** "Tiap Tanggal 22", "Tiap 22 Oktober", "22 Oktober 2026", or the prompt. */
    private var value: Text {
        guard let dueOn else { return Text("bills.add.date.prompt") }
        switch repeats {
        case .monthly: return Text("bills.add.date.monthly \(dueOn.day)")
        case .yearly: return Text("bills.add.date.yearly \(Text(dueOn.date, format: .dateTime.day().month(.wide)))")
        case .once: return Text(dueOn.date, format: .dateTime.day().month(.wide).year())
        }
    }
}

/** Pilih Tanggal: the month's calendar from today; Pilih Tanggal applies it and closes. */
struct BillDateSheet: View {
    @Binding var dueOn: CalendarDay?
    @Binding var isPresented: Bool
    @State private var chosen: Date

    init(dueOn: Binding<CalendarDay?>, isPresented: Binding<Bool>) {
        _dueOn = dueOn
        _isPresented = isPresented
        _chosen = State(initialValue: (dueOn.wrappedValue ?? CalendarDay(.now)).date)
    }

    var body: some View {
        DatePicker("bills.add.date", selection: $chosen, displayedComponents: .date)
            .datePickerStyle(.graphical).labelsHidden().tint(.pandan)
        KiraButton("bills.add.date.pick") {
            dueOn = CalendarDay(chosen)
            isPresented = false
        }
        .block()
    }
}
