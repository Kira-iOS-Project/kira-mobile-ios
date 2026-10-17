/**
 Field (design system): an input with its label always visible above a hairline box. Money takes
 the "Rp" prefix: the person types digits only, ",00" is added on save and said in the hint. An
 error uses `vulnerable` and a sentence that offers a way out, never blame. Kira never asks for a bank
 PIN, a password or a bank OTP; its own app-lock PIN and email code use KiraCodeField. Set the
 keyboard on the field as on any view: `.keyboardType(.numberPad)`. `.amount()` groups a rupiah
 field's digits with dots within each keystroke ("10.000.000", AmountTextField), on the number pad.
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
    private var groupsDigits = false
    private var wrapsText = false
    /** The focus ring's width, drawn outside the border (`kiraFieldRingRoom()` keeps it whole). */
    static let ringWidth: CGFloat = 3
    @FocusState private var isFocused: Bool
    /** Whether an `.amount()` field's UIKit text field is being typed in. */
    @State private var isEditingAmount = false
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
                /** A long label ("Harga Properti Impian Saat Ini") wraps, never squeezed by the field's container. */
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            box
            if let message = errorText ?? hintText {
                Text(message)
                    .font(.footnote).kiraLineHeight(18, size: 13)
                    .foregroundStyle(errorText == nil ? Color.inkMuted : Color.vulnerable)
                    .padding(.horizontal, 4)
                    /** As tall as its lines at every text size, never squeezed by the field's container. */
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var box: some View {
        HStack(spacing: KiraSpacing.space2) {
            if let prefixText { affix(prefixText) }
            ZStack(alignment: .leading) {
                /**
                 A single-line field draws its prompt itself, so a long one wraps at large text sizes
                 instead of being cut off; VoiceOver hears it as the field's hint.
                 */
                if isSingleLine, text.isEmpty, let prompt {
                    Text(prompt).font(.body).foregroundStyle(.inkMuted).accessibilityHidden(true)
                }
                if groupsDigits {
                    AmountTextField(text: $text, isEditing: $isEditingAmount, label: label, hint: prompt)
                } else {
                    textField
                }
            }
            .padding(.vertical, 14)
            if let suffixText { affix(suffixText) }
            if let iconName { KiraIcon(iconName, size: 20).foregroundStyle(.inkMuted) }
        }
        .padding(.horizontal, KiraSpacing.space4)
        .frame(minHeight: 52)
        .kiraCard(border: borderColor, cornerRadius: KiraRadius.medium)
        .overlay {
            RoundedRectangle(cornerRadius: KiraRadius.medium + Self.ringWidth, style: .continuous)
                .strokeBorder(isActive ? Color.pandanLine : .clear, lineWidth: Self.ringWidth)
                .padding(-Self.ringWidth)
        }
    }

    private var textField: some View {
        TextField(text: $text, prompt: systemPrompt, axis: isSingleLine && !wrapsText ? .horizontal : .vertical) {
            Text(label)
        }
        .lineLimit(minimumLines...max(minimumLines, 6))
        /** A wrapping field still holds one line of text: Return would type a line break, so it is dropped. */
        .onChange(of: text) { _, value in
            if wrapsText, value.contains(where: \.isNewline) { text = value.filter { !$0.isNewline } }
        }
        .font(.body)
        .foregroundStyle(.ink)
        .focused($isFocused)
        .accessibilityLabel(Text(label))
        .accessibilityHint(prompt.map { Text($0) } ?? Text(Self.noPrompt))
    }

    private var isSingleLine: Bool { minimumLines == 1 }

    /** Whether the field is being typed in: the SwiftUI field's focus, or the amount field's editing. */
    private var isActive: Bool { isFocused || isEditingAmount }

    /** The prompt the system draws: a multi-line field's, which wraps already; none for a single line. */
    private var systemPrompt: Text {
        guard !isSingleLine, let prompt else { return Text(Self.noPrompt) }
        return Text(prompt).foregroundStyle(.inkMuted)
    }

    private var borderColor: Color {
        if errorText != nil { return .vulnerable }
        return isActive ? .pandan : .hairline
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

    /** The same field holding whole rupiah: digits only, on the number pad, grouped with dots as they are typed. */
    func amount() -> Self { copy { $0.groupsDigits = true } }

    /** The same field, growing to show at least `lines` lines. */
    func multiline(_ lines: Int) -> Self { copy { $0.minimumLines = lines } }

    /**
     The same field, one line when empty, wrapping onto more lines as a long value grows (a contact's
     name), instead of scrolling it out of view at large text sizes. It stays one line of text: a
     typed line break is dropped.
     */
    func wraps() -> Self { copy { $0.wrapsText = true } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var field = self
        change(&field)
        return field
    }
}

#if DEBUG
    #Preview { GalleryForms().galleryPage() }
#endif
