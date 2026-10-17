/**
 REN-09, Cek Legalitas (board CekLegalitas): "Cek Dulu Sebelum Percaya" with the shield, a search
 field whose words stay in this screen's memory and are never stored or sent (Kira decides nothing,
 so it filters nothing), the notice that Kira does not judge, Daftar Resmi's four official places,
 Tanda Bahaya's four signs and IASC's sentence. The official sites open in the browser; Kontak OJK
 157 offers the call and the WhatsApp chat, each number copied with a long press.
 */
import Domain
import Features
import SwiftUI

struct LegalityCheckScreen: View {
    let onOpen: (AppRoute) -> Void
    // periphery:ignore - used only as $binding (@State macro), which Periphery 3.8 cannot follow
    @State private var search = ""
    @State private var showsContact = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        PlanScreenFrame(backdrop: { EmptyView() }, content: {
            KiraNavBar("legality.title", leading: .back("legality.back") { dismiss() }) {
                KiraHelpButton(.icon) { onOpen(.care) }
            }
            header
            KiraField("legality.search", text: $search).icon(.search).hint("legality.search.hint")
                .textInputAutocapitalization(.never).autocorrectionDisabled()
            VStack(alignment: .leading, spacing: 10) {
                KiraNotice(.info, title: "legality.notice.title", message: "legality.notice.body")
                officialList
            }
            .padding(.top, KiraSpacing.space1)
            LegalityWarnings().padding(.top, KiraSpacing.space2)
        })
        .kiraSheet(isPresented: $showsContact, title: "legality.ojk157") { LegalityContactSheet() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            PlanHeading(title: "legality.heading", subtitle: "legality.heading.subtitle", size: 26, lineHeight: 31)
            KiraIllustration(.shield, size: 88)
        }
    }

    private var officialList: some View {
        KiraListGroup("legality.official") {
            site("legality.lenders", subtitle: "legality.lenders.subtitle", icon: .list, url: LegalityLinks.ojk)
            site(
                "legality.investments", subtitle: "legality.investments.subtitle", icon: .chart, url: LegalityLinks.ojk)
            site("legality.report", subtitle: "legality.report.subtitle", icon: .flag, url: LegalityLinks.satgasPasti)
            KiraListRow(Text("legality.ojk157"), leading: .icon(.phone), trailing: .external) { showsContact = true }
                .subtitle(Text("legality.ojk157.subtitle"))
        }
    }

    private func site(
        _ title: LocalizedStringResource, subtitle: LocalizedStringResource, icon: KiraIconName, url: URL?
    ) -> some View {
        KiraListRow(Text(title), leading: .icon(icon), trailing: .external) { if let url { openURL(url) } }
            .subtitle(Text(subtitle))
            .accessibilityHint(Text("debtEmergency.opensBrowser"))
    }
}

/**
 Kontak OJK 157's two ways in, from the verified contacts: Telepon 157 and WhatsApp 081157157157
 (wa.me/6281157157157). A long press copies the number (content not on a board: owner content review).
 */
private struct LegalityContactSheet: View {
    @Environment(\.openURL) private var openURL
    private let contact = LegalityLinks.ojk157

    var body: some View {
        KiraListGroup {
            if let phone = contact?.phone {
                KiraListRow(Text("legality.ojk157.call \(phone)"), leading: .icon(.phone)) {
                    if let url = contact?.callURL { openURL(url) }
                }
                .copiesNumber(phone)
            }
            if let whatsApp = contact?.whatsApp {
                KiraListRow(Text("legality.ojk157.whatsApp \(whatsApp)"), leading: .icon(.chat), trailing: .external) {
                    if let url = contact?.whatsAppURL(message: nil) { openURL(url) }
                }
                .copiesNumber(whatsApp)
            }
        }
        .padding(.bottom, KiraSpacing.space4)
    }
}

#if DEBUG
    #Preview {
        NavigationStack { LegalityCheckScreen { _ in } }
    }
#endif
