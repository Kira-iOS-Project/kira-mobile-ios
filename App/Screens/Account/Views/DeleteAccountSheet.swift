/**
 Hapus Akun dan Data (AKN-05, 05b, 05c; canvas HapusAkun*): what is deleted for good, the
 subscription cancelled with it, Unduh Datamu Dulu (the CSV emailed to the account), and Hapus
 Permanen, on once "HAPUS" is typed in any case. Success ends at the Splash, signed out; a failure
 of either closes the sheet for its dialog (`kiraSheet(_:…)` on Data & Privasi), the typing kept.
 */
import Features
import SwiftUI

/** The content of the Hapus Akun sheet. */
struct DeleteAccountSheet: View {
    @Bindable var model: DeleteAccountModel
    let email: String

    var body: some View {
        GeometryReader { frame in
            ScrollView {
                form.frame(minHeight: frame.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .kiraFieldRingRoom()
        }
        .kiraDialog(isPresented: $model.showsDeleted) {
            KiraDialog(
                "account.delete.done.title", message: "account.delete.done.message", art: .illustration(.bloom),
                primary: KiraButton("account.done", action: model.finish))
        }
    }

    /** The form, its buttons at the bottom of the sheet as the board's `margin-top: auto` puts them. */
    private var form: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            DeletedItemsList()
            KiraNotice(
                .info, title: "account.delete.subscription.title", message: "account.delete.subscription.message")
            KiraListGroup {
                KiraListRow(Text("account.delete.export"), leading: .icon(.download)) {
                    Task { await model.emailData() }
                }
                .subtitle(exportSubtitle)
                .disabled(model.emailExport == .sending)
            }
            KiraField("account.delete.field", text: $model.confirmation, prompt: "account.delete.field.prompt")
                .hint("account.delete.field.hint")
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("account.delete.confirm", variant: .destructive) { Task { await model.delete() } }
                    .block()
                    .disabled(!model.canDelete)
                KiraButton("account.cancel", variant: .secondary) { model.sheet.close() }.block()
            }
        }
    }

    private var exportSubtitle: Text {
        switch model.emailExport {
        case .idle, .sending: Text("account.delete.export.subtitle \(email)")
        case .sent: Text("account.delete.export.sent \(email)")
        }
    }
}

/** Yang akan dihapus permanen: four rows, each with its muted icon tile. */
private struct DeletedItemsList: View {
    private let items: [(KiraIconName, LocalizedStringResource)] = [
        (.receipt, "account.delete.item.transactions"), (.chart, "account.delete.item.score"),
        (.target, "account.delete.item.goals"), (.chat, "account.delete.item.chat"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("account.delete.items")
                .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
                .accessibilityAddTraits(.isHeader)
            KiraRowStack {
                ForEach(items.indices, id: \.self) { index in
                    HStack(spacing: KiraSpacing.space3) {
                        KiraIcon(items[index].0, size: 18)
                            .foregroundStyle(.inkMuted)
                            .frame(width: 32, height: 32)
                            .kiraCard(.surfaceMuted, cornerRadius: 10)
                            .accessibilityHidden(true)
                        Text(items[index].1).font(.subheadline).kiraLineHeight(20, size: 15)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: 48)
                    .kiraRowSeparator()
                }
            }
            .padding(.vertical, KiraSpacing.space1)
            .padding(.horizontal, KiraSpacing.space4)
            .kiraCard()
        }
    }
}
