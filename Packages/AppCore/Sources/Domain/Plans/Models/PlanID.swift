/** Kira Gratis, Kira Muda and Kira Plus: the backend's `PLAN` values. */
package enum PlanID: String, CaseIterable, Codable, Sendable {
    /** Kira Gratis, Rp0,00. */
    case free
    /** Kira Muda, Rp15.000,00 a month. */
    case young
    /** Kira Plus, Rp29.000,00 a month. */
    case plus
}
