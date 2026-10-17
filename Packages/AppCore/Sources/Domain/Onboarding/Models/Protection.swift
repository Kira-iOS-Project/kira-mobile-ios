/**
 Perlindungan yang Kamu Punya (ONB-12): the backend's `PROTECTION` values. Health cover is BPJS
 Kesehatan or private health insurance; income cover is BPJS Ketenagakerjaan or life insurance.
 */
package enum Protection: String, CaseIterable, Hashable, Sendable {
    /** BPJS Kesehatan. */
    case bpjsHealth = "bpjs_health"
    /** BPJS Ketenagakerjaan. */
    case bpjsEmployment = "bpjs_employment"
    /** Asuransi Jiwa. */
    case lifeInsurance = "life_insurance"
    /** Asuransi Kesehatan Swasta. */
    case privateHealth = "private_health"
}
