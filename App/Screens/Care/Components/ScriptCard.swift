/**
 The "NASKAH" card of PED-09: the overline and the lender, the script with its coloured phrases (a
 tap opens the phrase's sheet), and "Ketuk bagian berwarna untuk mengubah." under a line. VoiceOver
 offers the two phrases as actions, since inline links are hard to reach by swiping.
 */
import Domain
import Features
import SwiftUI

struct ScriptCard: View {
    let model: NegotiationScriptModel

    /** "NASKAH" and, when one is chosen, the lender it is for. */
    private var header: some View {
        HStack(spacing: KiraSpacing.space3) {
            Text("care.script.overline").kiraFont(.overline).foregroundStyle(.inkMuted)
            Spacer(minLength: 0)
            if let lender = model.lender {
                Text("care.script.for \(lender.name)")
                    .font(.caption.weight(.medium)).kiraLineHeight(16, size: 12)
                    .foregroundStyle(.inkMuted)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            header
            Text(ScriptText.shown(model.shown))
                .font(.subheadline).kiraLineHeight(23, size: 15)
                .foregroundStyle(.ink)
                .tint(.coping)
                .environment(
                    \.openURL,
                    OpenURLAction { url in
                        if url == ScriptText.contractLink { model.edit(.contract) } else { model.edit(.reason) }
                        return .handled
                    }
                )
                .accessibilityAction(named: Text("care.script.reason.a11y")) { model.edit(.reason) }
                .accessibilityAction(named: Text("care.script.contract.a11y")) { model.edit(.contract) }
            HStack(spacing: 6) {
                KiraIcon(.pencil, size: 15).accessibilityHidden(true)
                Text("care.script.editHint")
            }
            .font(.footnote).kiraLineHeight(18, size: 13)
            .foregroundStyle(.inkMuted)
            .padding(.top, KiraSpacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
        }
        .padding(.top, 18)
        .padding(.horizontal, 18)
        .padding(.bottom, KiraSpacing.space4)
        .kiraCard()
        .accessibilityElement(children: .contain)
    }
}

/** The sheet of a coloured phrase: the reason, or the contract number (kept on this screen only). */
struct ScriptPhraseSheet: View {
    @Bindable var model: NegotiationScriptModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            if model.editing == .contract {
                KiraField("care.script.contract.field", text: $model.draft)
                    .hint("care.script.contract.hint")
                    .textContentType(.none)
                    .autocorrectionDisabled()
            } else {
                KiraField("care.script.reason.field", text: $model.draft).hint("care.script.reason.hint")
            }
            KiraButtonPair(
                secondary: KiraButton("care.script.sheet.cancel", variant: .secondary, size: .small) {
                    model.editing = nil
                },
                primary: KiraButton("care.script.sheet.save", size: .small) { model.finishEditing() })
        }
    }
}
