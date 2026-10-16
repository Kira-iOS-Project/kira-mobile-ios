/** Mode Darurat Utang: turning it on for the account. */
extension KiraAPI {
    /** Turns the mode on; idempotent, the server keeps the first time (`PUT /api/care/debt-emergency`). */
    package func activateDebtEmergency() async throws {
        try await client.activateDebtEmergency().done()
    }
}

extension Operations.ActivateDebtEmergency.Output {
    func done() throws {
        switch self {
        case .ok: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
