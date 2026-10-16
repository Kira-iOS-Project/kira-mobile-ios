/**
 A reusable payday sheet for onboarding and budgeting: choose a day from 1 to 31 or the last day
 of the month, then apply the draft selection to the screen that presented it.
 */
import SwiftUI

extension View {
    /** Presents Kira's payday picker and applies either a day from 1 to 31 or nil for month end. */
    func kiraPaydayPicker(
        isPresented: Binding<Bool>, selectedDay: Int?, onApply: @escaping (Int?) -> Void
    ) -> some View {
        modifier(KiraPaydayPickerModifier(isPresented: isPresented, selectedDay: selectedDay, onApply: onApply))
    }
}

/** The selection draft and calendar grid shared by payday entry points. */
private struct KiraPaydayPickerModifier: ViewModifier {
    @Binding private var isPresented: Bool
    private let selectedDay: Int?
    private let onApply: (Int?) -> Void
    @State private var draftDay: Int
    @State private var draftIsEndOfMonth: Bool
    @Environment(\.dynamicTypeSize) private var typeSize

    init(isPresented: Binding<Bool>, selectedDay: Int?, onApply: @escaping (Int?) -> Void) {
        _isPresented = isPresented
        self.selectedDay = selectedDay
        self.onApply = onApply
        _draftDay = State(initialValue: min(max(selectedDay ?? 25, 1), 31))
        _draftIsEndOfMonth = State(initialValue: selectedDay == nil)
    }

    func body(content: Content) -> some View {
        content.kiraSheet(isPresented: $isPresented, title: "payday.sheet.title", subtitle: "payday.sheet.subtitle") {
            sheetContent
        }
    }

    private var sheetContent: some View {
        VStack(spacing: KiraSpacing.space4) {
            LazyVGrid(columns: columns, spacing: KiraSpacing.space1) {
                ForEach(1...31, id: \.self) { day in
                    dayButton(day)
                }
            }
            KiraCheckbox("payday.endOfMonth", isOn: $draftIsEndOfMonth)
            Spacer(minLength: 0)
            KiraButton("payday.confirm") {
                onApply(draftIsEndOfMonth ? nil : draftDay)
                isPresented = false
            }
            .block()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: isPresented) { _, shown in
            if shown { resetDraft() }
        }
    }

    private var columns: [GridItem] {
        let count = typeSize.isAccessibilitySize ? 4 : 7
        return Array(repeating: GridItem(.flexible(minimum: KiraSize.tap), spacing: 0), count: count)
    }

    private func dayButton(_ day: Int) -> some View {
        let isSelected = !draftIsEndOfMonth && draftDay == day
        return Button {
            draftDay = day
            draftIsEndOfMonth = false
        } label: {
            Text(day, format: .number)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.pandanStrong : Color.ink)
                .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
                .background(isSelected ? Color.pandanSoft : .clear, in: Circle())
                .overlay {
                    Circle().strokeBorder(isSelected ? Color.pandan : .clear, lineWidth: 1.5)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("payday.day.accessibility \(day)"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("payday.day.\(day)")
    }

    private func resetDraft() {
        draftDay = min(max(selectedDay ?? 25, 1), 31)
        draftIsEndOfMonth = selectedDay == nil
    }
}

#if DEBUG
    #Preview {
        GalleryEntry().galleryPage()
    }
#endif
