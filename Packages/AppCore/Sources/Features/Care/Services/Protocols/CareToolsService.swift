import Domain

/**
 The calls behind Kira Peduli's tools: Naskah Pengajuan Keringanan (PED-09) and Rencana
 Keselamatanku (PED-10). Latihan Menenangkan Diri (PED-11) needs none. Kira Peduli's own calls (the
 contacts) are `CareService`'s. Every call throws an `AppProblem` when the API refuses it.
 */
package protocol CareToolsService: Sendable {
    /** `GET /me`: the name the script greets with ("Dinda"). */
    func displayName() async throws -> String
    /** `GET /debts`: the lenders the script can be written to, from the health check's debts. */
    func debts() async throws -> [CareDebt]
    /** `GET /care/safety-plan`: the saved plan, or nil when none was saved (404 CARE_SAFETY_PLAN_NOT_FOUND). */
    func safetyPlan() async throws -> SafetyPlan?
    /** `PUT /care/safety-plan`: saves the whole plan and returns it as stored. */
    func saveSafetyPlan(_ plan: SafetyPlan) async throws -> SafetyPlan
}
