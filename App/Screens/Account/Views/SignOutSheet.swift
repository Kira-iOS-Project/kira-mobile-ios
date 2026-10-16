/**
 Keluar's confirmation (AKN-01): what happens to the records, then Keluar (destructive) over Batal,
 as the Hapus Akun sheet stacks its buttons. Keluar ends the session and clears the device.
 */
import Features
import SwiftUI

/** The content of the Keluar sheet. */
struct SignOutSheet: View {
    let model: ProfileModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraNotice(.privacy, message: "account.signOut.message")
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("account.signOut.confirm", variant: .destructive) { Task { await model.signOut() } }
                    .block()
                    .disabled(model.isSigningOut)
                KiraButton("account.cancel", variant: .secondary) { model.isConfirmingSignOut = false }.block()
            }
        }
        .padding(.bottom, KiraSpacing.space2)
    }
}
