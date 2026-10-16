/** "Apa yang Sedang Kamu Hadapi?": the backend's `SCHOLARSHIP_SITUATION` values, in the form's order. */
package enum ScholarshipSituation: String, CaseIterable, Codable, Sendable {
    /** Cicilan Menumpuk. */
    case instalmentsPilingUp = "instalments_piling_up"
    /** Ditagih Pinjol. */
    case chasedByLender = "chased_by_lender"
    /** Penghasilan Berhenti. */
    case incomeStopped = "income_stopped"
    /** Biaya Berobat. */
    case medicalCosts = "medical_costs"
    /** Lainnya. */
    case otherHardship = "other_hardship"
}
