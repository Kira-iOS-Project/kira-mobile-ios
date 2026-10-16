import Domain

/**
 What Kira Peduli's help screens need from the API (CONTRACT-KOM-PED.md, Care): the verified
 contacts. Each call throws an `AppProblem`. The other Kira Peduli calls live in their own
 protocols (`CheckInService`, `DebtEmergencyService`, `CareToolsService`), so each area's branch
 keeps to its own file.
 */
package protocol CareService: Sendable {
    /** `GET /care/contacts`: the contacts the team verifies every month. */
    func contacts() async throws -> CareContactList
}
