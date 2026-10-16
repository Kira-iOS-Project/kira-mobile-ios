/**
 Pilih Tanggal Gajian (ONB-10b, ONB-10c): the days 1–31 in rows of seven, the chosen one in a
 pandan-soft circle with a pandan ring, the others like secondary buttons; "Gajian di akhir bulan"
 dims them. The button names the choice, fills the row and closes the sheet.
 */
import Domain
import Features
import SwiftUI

struct PaydaySheet: View {
    @Binding var payday: Payday
    @Binding var isPresented: Bool
    @State private var model: PaydayPickerModel
    @Environment(\.dynamicTypeSize) private var typeSize

    init(payday: Binding<Payday>, isPresented: Binding<Bool>) {
        _payday = payday
        _isPresented = isPresented
        _model = State(initialValue: PaydayPickerModel(payday: payday.wrappedValue))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: KiraSpacing.space4) {
                /** Seven columns as on the board; four at the accessibility sizes, so each day keeps its digits. */
                let columns = typeSize.isAccessibilitySize ? 4 : 7
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: columns), spacing: 6) {
                    ForEach(Payday.days, id: \.self) { day in DayButton(day: day, model: model) }
                }
                .opacity(model.isEndOfMonth ? 0.4 : 1)
                .disabled(model.isEndOfMonth)
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    KiraCheckbox("onboarding.payday.endOfMonth.option", isOn: $model.isEndOfMonth)
                    if model.isEndOfMonth {
                        Text("onboarding.payday.endOfMonth.note").onboardingNote().padding(
                            .horizontal, KiraSpacing.space1)
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        KiraButton(model.isEndOfMonth ? "onboarding.payday.pickEnd" : "onboarding.payday.pick \(model.day)") {
            payday = model.payday
            isPresented = false
        }
        .block()
        .padding(.bottom, KiraSpacing.space2)
    }
}

/** One day of the calendar. */
private struct DayButton: View {
    let day: Int
    let model: PaydayPickerModel
    /** 44 pt, growing with the text up to the 80 pt a four-column row allows. */
    @ScaledMetric(relativeTo: .callout) private var side: CGFloat = KiraSize.tap

    var body: some View {
        let isChosen = model.isChosen(day)
        Button {
            model.choose(day)
        } label: {
            Text(day, format: .number)
                .font(.callout.weight(isChosen ? .bold : .medium))
                .foregroundStyle(isChosen ? Color.pandan : .ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, KiraSpacing.space1)
                .frame(width: min(side, 80), height: min(side, 80))
                .background(isChosen ? Color.pandanSoft : .button, in: Circle())
                .overlay { Circle().strokeBorder(isChosen ? Color.pandan : .buttonLine, lineWidth: isChosen ? 1.5 : 1) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("onboarding.payday.day \(day)"))
        .accessibilityAddTraits(isChosen ? [.isSelected] : [])
    }
}
