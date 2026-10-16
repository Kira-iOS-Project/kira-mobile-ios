/**
 Field (design system): an input with its label always visible above a hairline box. Money takes
 the "Rp" prefix: the person types digits only, ",00" is added on save and said in the hint. An
 error uses `vulnerable` and a sentence that offers a way out, never blame. Kira never asks for a bank
 PIN, a password or a bank OTP; its own app-lock PIN and email code use KiraCodeField. Set the
 keyboard on the field as on any view: `.keyboardType(.numberPad)`.
 */
import SwiftUI

/** A labelled text input. */
struct KiraField: View {
    private let label: LocalizedStringResource
    @Binding private var text: String
    private let prompt: LocalizedStringResource?
    private var hintText: LocalizedStringResource?
    private var errorText: LocalizedStringResource?
    private var prefixText: LocalizedStringResource?
    private var suffixText: LocalizedStringResource?
    private var iconName: KiraIconName?
    private var minimumLines = 1
    @FocusState private var isFocused: Bool
    /**
     An empty prompt: without one, a text field shows its label in the box, and Kira's label
     already sits above it.
     */
    private static let noPrompt = ""

    init(_ label: LocalizedStringResource, text: Binding<String>, prompt: LocalizedStringResource? = nil) {
        self.label = label
        _text = text
        self.prompt = prompt
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
                .accessibilityHidden(true)
            box
            if let message = errorText ?? hintText {
                Text(message)
                    .font(.footnote).kiraLineHeight(18, size: 13)
                    .foregroundStyle(errorText == nil ? Color.inkMuted : Color.vulnerable)
                    .padding(.horizontal, 4)
            }
        }
    }

    private var box: some View {
        HStack(spacing: KiraSpacing.space2) {
            if let prefixText { affix(prefixText) }
            TextField(
                text: $text, prompt: prompt.map { Text($0).foregroundStyle(.inkMuted) } ?? Text(Self.noPrompt),
                axis: minimumLines > 1 ? .vertical : .horizontal
            ) {
                Text(label)
            }
            .lineLimit(minimumLines...max(minimumLines, 6))
            .font(.body)
            .foregroundStyle(.ink)
            .focused($isFocused)
            .accessibilityLabel(Text(label))
            .padding(.vertical, 14)
            if let suffixText { affix(suffixText) }
            if let iconName { KiraIcon(iconName, size: 20).foregroundStyle(.inkMuted) }
        }
        .padding(.horizontal, KiraSpacing.space4)
        .frame(minHeight: 52)
        .kiraCard(border: borderColor, cornerRadius: KiraRadius.medium)
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.medium + 3, style: .continuous)
                .strokeBorder(isFocused ? Color.pandanLine : .clear, lineWidth: 3)
                .padding(-3)
        }
    }

    private var borderColor: Color {
        if errorText != nil { return .vulnerable }
        return isFocused ? .pandan : .hairline
    }

    private func affix(_ text: LocalizedStringResource) -> some View {
        Text(text).font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(.inkMuted)
    }

    /** The same field with a hint under it. */
    func hint(_ text: LocalizedStringResource) -> Self { copy { $0.hintText = text } }

    /** The same field in error, with the sentence that says how to fix it. */
    func error(_ text: LocalizedStringResource?) -> Self { copy { $0.errorText = text } }

    /** The same field with a prefix in the box, such as "Rp". */
    func prefix(_ text: LocalizedStringResource) -> Self { copy { $0.prefixText = text } }

    /** The same field with a suffix in the box, such as "%". */
    func suffix(_ text: LocalizedStringResource) -> Self { copy { $0.suffixText = text } }

    /** The same field with an icon at the end of the box, such as `.search`. */
    func icon(_ name: KiraIconName) -> Self { copy { $0.iconName = name } }

    /** The same field, growing to show at least `lines` lines. */
    func multiline(_ lines: Int) -> Self { copy { $0.minimumLines = lines } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var field = self
        change(&field)
        return field
    }
}

#if DEBUG
    #Preview { GalleryForms().galleryPage() }
#endif
