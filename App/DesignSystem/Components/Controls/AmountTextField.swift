/**
 The text field of a `.amount()` KiraField: a UITextField that applies each edit itself, grouped
 (AmountEdit), inside `shouldChangeCharactersIn`, and only then hands the text to the binding. Nothing
 is written back later, so a digit already in the keyboard's buffer can never be overwritten by the
 grouping of an older value ("7500000" typed fast was once stored as "750.000"). The caret stays
 after the digits it was after. The number pad, Dynamic Type and the field's label and hint for
 VoiceOver are built in; KiraField draws the box, the prompt, the "Rp" and the focus ring around it.
 */
import Domain
import SwiftUI
import UIKit

struct AmountTextField: UIViewRepresentable {
    @Binding var text: String
    /** Whether the field is being typed in, for KiraField's focus ring and border. */
    @Binding var isEditing: Bool
    let label: LocalizedStringResource
    let hint: LocalizedStringResource?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.keyboardType = .numberPad
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.textColor = UIColor(resource: .ink)
        field.tintColor = UIColor(resource: .pandan)
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        /** One line tall, never stretched by a container that offers more height (a sheet, a VStack). */
        field.setContentHuggingPriority(.required, for: .vertical)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        return field
    }

    /** The width offered, and the height of one line of its font: what a SwiftUI TextField takes. */
    func sizeThatFits(_ proposal: ProposedViewSize, uiView field: UITextField, context _: Context) -> CGSize? {
        let height = field.intrinsicContentSize.height
        return CGSize(width: proposal.width ?? field.intrinsicContentSize.width, height: height)
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        field.accessibilityLabel = String(localized: label)
        field.accessibilityHint = hint.map { String(localized: $0) }
        /** A late echo of an older value never reaches a field being typed in (AmountEdit.shown). */
        let shown = AmountEdit.shown(current: field.text ?? "", binding: text, isEditing: field.isFirstResponder)
        if field.text != shown { field.text = shown }
    }

    /** Applies each edit as it happens and tells the binding. */
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AmountTextField

        init(_ parent: AmountTextField) {
            self.parent = parent
        }

        func textField(
            _ field: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
        ) -> Bool {
            let edit = AmountEdit.apply(
                to: field.text ?? "", location: range.location, length: range.length, replacement: string)
            field.text = edit.text
            if let caret = field.position(from: field.beginningOfDocument, offset: edit.caret) {
                field.selectedTextRange = field.textRange(from: caret, to: caret)
            }
            parent.text = edit.text
            return false
        }

        func textFieldDidBeginEditing(_: UITextField) { parent.isEditing = true }

        /** Hands the final text to the binding once more, so it ends on what the field shows. */
        func textFieldDidEndEditing(_ field: UITextField) {
            parent.isEditing = false
            if parent.text != field.text ?? "" { parent.text = field.text ?? "" }
        }
    }
}
