/** Mode Darurat Utang's own call: turning the mode on for the account. */
package protocol DebtEmergencyService: Sendable {
    /** `PUT /care/debt-emergency`: idempotent, the server keeps the first time. */
    func activate() async throws
}
