/**
 Mode Darurat Utang (PED-07, board ModeDaruratUtang): free on every plan. The situations open their
 guides (PED-08, PED-13, PED-14, PED-15) and the negotiation script (PED-09); OJK's contacts call or
 open their sites in the browser; Beasiswa Kira opens the scholarship. Opening the screen turns the
 mode on quietly (DebtEmergencyModel), and nothing on it waits for that.
 */
import Domain
import Features
import SwiftUI

struct DebtEmergencyScreen: View {
    @State private var model: DebtEmergencyModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(care: any CareService, service: any DebtEmergencyService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: DebtEmergencyModel(care: care, service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        DebtCareFrame {
            KiraNavBar("debtEmergency.title", leading: .back("debtEmergency.back") { dismiss() })
            DebtEmergencyHeader()
            situations
            contacts
            DebtScholarshipCard { onOpen(.scholarship) }
            KiraHelpButton(.row, label: "debtEmergency.help") { onOpen(.care) }
        }
        .task { await model.load() }
        .task { await model.activate() }
    }

    private var situations: some View {
        KiraListGroup("debtEmergency.situations") {
            guideRow("debtGuide.harshCollection.row", icon: .phone, guide: .harshCollection)
            guideRow("debtGuide.illegalLender.row", icon: .flag, guide: .illegalLender)
            guideRow("debtGuide.unresolvedComplaint.row", icon: .file, guide: .unresolvedComplaint)
            KiraListRow(Text("debtEmergency.instalment"), leading: .icon(.calendar)) { onOpen(.negotiationScript) }
                .subtitle(Text("debtEmergency.instalment.subtitle"))
            KiraListRow(Text("debtGuide.payoffOffer.row"), leading: .icon(.alert)) {
                onOpen(.debtGuide(.payoffOffer))
            } extra: {
                KiraTag("debtEmergency.payoffOffer.tag", tone: .vulnerable)
            }
            .subtitle(Text("debtGuide.payoffOffer.row.subtitle"))
        }
    }

    private func guideRow(_ title: LocalizedStringResource, icon: KiraIconName, guide: DebtGuide) -> some View {
        KiraListRow(Text(title), leading: .icon(icon)) { onOpen(.debtGuide(guide)) }
            .subtitle(Text(guideSubtitle(guide)))
    }

    private func guideSubtitle(_ guide: DebtGuide) -> LocalizedStringResource {
        switch guide {
        case .harshCollection: "debtGuide.harshCollection.row.subtitle"
        case .illegalLender: "debtGuide.illegalLender.row.subtitle"
        case .unresolvedComplaint: "debtGuide.unresolvedComplaint.row.subtitle"
        case .payoffOffer: "debtGuide.payoffOffer.row.subtitle"
        }
    }

    private var contacts: some View {
        KiraListGroup("debtEmergency.contacts") {
            KiraListRow(Text("debtEmergency.ojk"), leading: .icon(.phone)) { open(model.callURL(.ojk157)) }
                .subtitle(ojkSubtitle)
            siteRow("debtEmergency.satgas", icon: .shield, key: .satgasPasti)
            siteRow("debtEmergency.iasc", icon: .globe, key: .iasc)
        }
    }

    /** "Telepon 157 · WhatsApp 081157157157", the numbers from the contact list. */
    private var ojkSubtitle: Text {
        let ojk = model.contact(.ojk157)
        let phone = ojk?.phone ?? ""
        guard let whatsApp = ojk?.whatsApp else { return Text("debtEmergency.ojk.phone \(phone)") }
        return Text("debtEmergency.ojk.subtitle \(phone) \(whatsApp)")
    }

    private func siteRow(_ title: LocalizedStringResource, icon: KiraIconName, key: CareContactKey) -> some View {
        KiraListRow(Text(title), leading: .icon(icon), trailing: .external) { open(model.website(key)) }
            .subtitle(Text(model.siteName(key) ?? ""))
            .accessibilityHint(Text("debtEmergency.opensBrowser"))
    }

    private func open(_ url: URL?) {
        if let url { openURL(url) }
    }
}

#Preview {
    NavigationStack {
        DebtEmergencyScreen(care: PreviewCareService(), service: PreviewDebtEmergencyService()) { _ in }
    }
}
