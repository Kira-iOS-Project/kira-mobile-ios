import APIClient
import Domain
import Observation

/**
 Data & Privasi (AKN-04): the consents (core locked on; Kira AI and Ringkasan Mingguan take effect
 at once), Unduh Datamu (a CSV saved on the device) and the way to Hapus Akun.
 */
@MainActor
@Observable
package final class PrivacyModel {
    /** The consents and the email, once loaded. */
    package private(set) var phase: ScreenPhase<PrivacyOverview> = .loading
    /** A consent or an export the API refused. */
    package var problem: AppProblem?
    /** A consent is being saved. */
    package private(set) var isSaving = false
    /** The CSV is being fetched. */
    package private(set) var isExporting = false
    /** The CSV to hand to the file exporter, until it is saved or dismissed. */
    package private(set) var export: DataExport?
    private let service: any AccountService

    /** A model that reads and writes through `service`. */
    package init(service: any AccountService) {
        self.service = service
    }

    /** Loads the consents and the account's email (shown in Hapus Akun). */
    package func load() async {
        do {
            async let consents = service.consents()
            async let profile = service.profile()
            phase = .loaded(PrivacyOverview(consents: try await consents, email: try await profile.email))
        } catch {
            phase = .failed(accountProblem(error))
        }
    }

    /** Kira AI Membaca Chat dan Struk. */
    package func setAIProcessing(_ isOn: Bool) async {
        guard let overview = phase.value else { return }
        await save(aiProcessing: isOn, weeklySummary: overview.consents.isGranted(.weeklySummary), in: overview)
    }

    /** Ringkasan Mingguan. */
    package func setWeeklySummary(_ isOn: Bool) async {
        guard let overview = phase.value else { return }
        await save(aiProcessing: overview.consents.isGranted(.aiProcessing), weeklySummary: isOn, in: overview)
    }

    /** Unduh: fetches the CSV for the file exporter. */
    package func exportData() async {
        isExporting = true
        do {
            export = try await service.exportData()
        } catch {
            problem = accountProblem(error)
        }
        isExporting = false
    }

    /** The file exporter closed, saved or not. */
    package func finishExport() {
        export = nil
    }

    private func save(aiProcessing: Bool, weeklySummary: Bool, in overview: PrivacyOverview) async {
        isSaving = true
        do {
            let consents = try await service.updateConsents(aiProcessing: aiProcessing, weeklySummary: weeklySummary)
            phase = .loaded(PrivacyOverview(consents: consents, email: overview.email))
        } catch {
            problem = accountProblem(error)
        }
        isSaving = false
    }
}

/** What Data & Privasi shows: the consents, and the address the export is emailed to. */
package struct PrivacyOverview: Equatable, Sendable {
    /** The decisions per purpose. */
    package let consents: ConsentSettings
    /** The account's address. */
    package let email: String
}
