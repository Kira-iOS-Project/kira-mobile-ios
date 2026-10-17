/**
 The risk profile the server computes from the five answers of Kenali Profil Risikomu (REN-06),
 by the raw value `PUT /risk-profile` sends: Konservatif, Moderat or Agresif, low to high.
 */
package enum RiskProfile: String, CaseIterable, Hashable, Sendable {
    /** Konservatif. */
    case conservative
    /** Moderat. */
    case moderate
    /** Agresif. */
    case aggressive
}
