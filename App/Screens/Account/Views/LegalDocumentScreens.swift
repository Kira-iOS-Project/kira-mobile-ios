/**
 The static documents opened from Tentang Kira (AKN-08b, 08c, 08d; canvas SyaratKetentuan,
 KebijakanPrivasi, LayananPengaduan): a large title, a dated or explanatory line, numbered cards,
 and the document's actions at the bottom.
 */
import Features
import SwiftUI

/** Syarat dan Ketentuan (AKN-08b). */
struct TermsScreen: View {
    var body: some View {
        LegalDocument(
            title: "account.terms.title", subtitle: "account.legal.effective",
            sections: [
                LegalSection("account.terms.1.title", "account.terms.1.body"),
                LegalSection("account.terms.2.title", "account.terms.2.body"),
                LegalSection("account.terms.3.title", "account.terms.3.body"),
                LegalSection("account.terms.4.title", "account.terms.4.body"),
                LegalSection("account.terms.5.title", "account.terms.5.body"),
            ])
    }
}

/** Kebijakan Privasi (AKN-08c): ends with Atur Data & Privasi. */
struct PrivacyPolicyScreen: View {
    let onOpen: (AppRoute) -> Void

    var body: some View {
        LegalDocument(
            title: "account.privacyPolicy.title", subtitle: "account.legal.effective",
            sections: [
                LegalSection("account.privacyPolicy.1.title", "account.privacyPolicy.1.body"),
                LegalSection("account.privacyPolicy.2.title", "account.privacyPolicy.2.body"),
                LegalSection("account.privacyPolicy.3.title", "account.privacyPolicy.3.body"),
                LegalSection("account.privacyPolicy.4.title", "account.privacyPolicy.4.body"),
            ]
        ) {
            KiraButton("account.privacyPolicy.manage") { onOpen(.privacy) }.block()
        }
    }
}

/** Layanan Pengaduan (AKN-08d): call OJK 157 or email bantuan@kira.id. */
struct ComplaintsScreen: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        LegalDocument(
            title: "account.complaints.title", subtitle: "account.complaints.subtitle",
            sections: [
                LegalSection("account.complaints.1.title", "account.complaints.1.body"),
                LegalSection("account.complaints.2.title", "account.complaints.2.body"),
                LegalSection("account.complaints.3.title", "account.complaints.3.body"),
            ]
        ) {
            KiraButtonPair(
                secondary: KiraButton("account.complaints.call", variant: .secondary, size: .small) { open("tel:157") }
                    .icon(.phone),
                primary: KiraButton("account.complaints.email", size: .small) { open("mailto:bantuan@kira.id") }
                    .icon(.send))
        }
    }

    private func open(_ link: String) {
        if let url = URL(string: link) { openURL(url) }
    }
}

/** One numbered card: its heading and its sentence. */
struct LegalSection {
    let title: LocalizedStringResource
    let body: LocalizedStringResource

    init(_ title: LocalizedStringResource, _ body: LocalizedStringResource) {
        self.title = title
        self.body = body
    }
}
