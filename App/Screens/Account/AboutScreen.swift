/**
 Tentang Kira (AKN-08, canvas TentangKira): what Kira is and is not, the version from the build,
 how it works, and its documents (Syarat dan Ketentuan, Kebijakan Privasi, Aturan Komunitas,
 Layanan Pengaduan), over the evening scenery.
 */
import Features
import SwiftUI

/** The Tentang Kira screen, opened from Profil. */
struct AboutScreen: View {
    let onOpen: (AppRoute) -> Void

    var body: some View {
        AccountPage("account.about.title", back: "account.back.profile") {
            AboutHeader()
            KiraListGroup("account.about.method") {
                KiraListRow(Text("account.about.score"), leading: .icon(.chart))
                    .subtitle(Text("account.about.score.subtitle"))
                KiraListRow(Text("account.about.ai"), leading: .icon(.sparkle))
                    .subtitle(Text("account.about.ai.subtitle"))
                KiraListRow(Text("account.about.education"), leading: .icon(.book))
                    .subtitle(Text("account.about.education.subtitle"))
            }
            KiraListGroup("account.about.documents") {
                KiraListRow(Text("account.terms.title"), leading: .icon(.file)) { onOpen(.terms) }
                KiraListRow(Text("account.privacyPolicy.title"), leading: .icon(.lock)) { onOpen(.privacyPolicy) }
                KiraListRow(Text("account.about.communityRules"), leading: .icon(.users)) {
                    onOpen(.unavailable(.community))
                }
                KiraListRow(Text("account.complaints.title"), leading: .icon(.help)) { onOpen(.complaints) }
            }
        } background: {
            KiraScenery(hasSun: true, height: 150)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
        .onHelp { onOpen(.care) }
    }
}

/** The wordmark, the handwritten line, the version and what Kira is not. */
private struct AboutHeader: View {
    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraLogo(.wordmark, size: 44)
            KiraHandNote("account.about.note", tilt: -2)
            Text("account.version \(Bundle.main.shortVersion)")
                .font(.caption.weight(.semibold)).monospacedDigit()
                .foregroundStyle(.inkMuted)
                .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                .kiraCard(.surfaceMuted, cornerRadius: KiraRadius.full)
                .padding(.top, KiraSpacing.space1)
            Text("account.about.position")
                .font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.top, KiraSpacing.space1)
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 12, trailing: 20))
        .frame(maxWidth: .infinity)
    }
}
