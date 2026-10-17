import APIClient

/** Mode Darurat Utang's call over the API client. */
package struct LiveDebtEmergencyService: DebtEmergencyService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `PUT /care/debt-emergency`. */
    package func activate() async throws {
        try await api.activateDebtEmergency()
    }
}
