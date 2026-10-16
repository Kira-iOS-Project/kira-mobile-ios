/**
 Data & Privasi (AKN-04, 04b, 04c, 04d; canvas DataPrivasi*): the consents (core locked on, the
 others take effect at once), the rights (Unduh Datamu saves a CSV on the device after its dialog;
 Keberatan opens an email to privasi@kira.id), how data is processed (an accordion, closed at
 first) and the way to Hapus Akun dan Data, a sheet over this screen.
 */
import Domain
import Features
import SwiftUI
import UniformTypeIdentifiers

/** The Data & Privasi screen, opened from Profil and Kebijakan Privasi. */
struct PrivacyScreen: View {
    @State private var model: PrivacyModel
    @State private var confirmsExport = false
    @State private var objects = false
    @State private var deletes = false
    private let service: any AccountService
    private let settings: any SecuritySettings
    private let onOpen: (AppRoute) -> Void
    private let onSignedOut: @MainActor () -> Void
    @Environment(\.openURL) private var openURL

    init(
        service: any AccountService, settings: any SecuritySettings, onOpen: @escaping (AppRoute) -> Void,
        onSignedOut: @escaping @MainActor () -> Void
    ) {
        model = PrivacyModel(service: service)
        self.service = service
        self.settings = settings
        self.onOpen = onOpen
        self.onSignedOut = onSignedOut
    }

    var body: some View {
        AccountPage("account.privacy.title", back: "account.back.profile") {
            AccountIntro(
                illustration: .padlock, title: "account.privacy.intro", message: "account.privacy.intro.message")
            switch model.phase {
            case .loading, .empty:
                ConsentGroup(model: model, consents: AccountSamples.consents()).redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let overview):
                ConsentGroup(model: model, consents: overview.consents)
            case .failed(let problem):
                AccountFailure(problem: problem) { Task { await model.load() } }
            }
            PrivacyRights(onExport: { confirmsExport = true }, onObject: { objects = true })
            PrivacyProcessing()
            KiraListGroup(footer: "account.privacy.delete.footer") {
                KiraListRow(Text("account.privacy.delete"), leading: .icon(.trash)) { deletes = true }.danger()
            }
        }
        .onHelp { onOpen(.unavailable(.care)) }
        .task { await model.load() }
        .kiraDialog(isPresented: $confirmsExport) {
            KiraDialog(
                "account.export.title", message: "account.export.message", art: .illustration(.shield),
                primary: KiraButton("account.export.confirm") { Task { await model.exportData() } },
                secondary: KiraButton("account.cancel", variant: .secondary) {})
        }
        .kiraDialog(isPresented: $objects) {
            KiraDialog(
                "account.objection.title", message: "account.objection.message", art: .illustration(.shield),
                primary: KiraButton("account.objection.confirm") { openObjectionEmail() },
                secondary: KiraButton("account.cancel", variant: .secondary) {})
        }
        .kiraDialog(isPresented: Binding(get: { model.problem != nil }, set: { if !$0 { model.problem = nil } })) {
            KiraDialog(
                "account.failure.title", message: model.problem?.message ?? "problem.unknown", art: .failure,
                primary: KiraButton("account.close") {})
        }
        .fileExporter(
            isPresented: Binding(get: { model.export != nil }, set: { if !$0 { model.finishExport() } }),
            document: model.export.map { CSVDocument(data: $0.csv) }, contentType: .commaSeparatedText,
            defaultFilename: model.export?.fileName
        ) { _ in
            model.finishExport()
        }
        .kiraSheet(
            isPresented: $deletes, title: "account.delete.title", subtitle: "account.delete.subtitle", top: 124
        ) {
            DeleteAccountSheet(
                service: service, settings: settings, email: model.phase.value?.email ?? "",
                onDeleted: onSignedOut, onClose: { deletes = false })
        }
    }

    private func openObjectionEmail() {
        if let url = URL(string: "mailto:privasi@kira.id?subject=Keberatan%20atas%20Keputusan%20Otomatis") {
            openURL(url)
        }
    }
}
