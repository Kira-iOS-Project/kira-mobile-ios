/**
 The three bands of the Kira Score (design system: BandPill, bandOf). A band is a starting point,
 never a grade: Rentan is the first step, so its colour is a muted brick, never an alarm red.
 */

/** The band of a score: Rentan 0–39, Bertahan 40–79, Sehat 80–100, in that order on the scale. */
package enum ScoreBand: String, CaseIterable, Sendable {
    /** 0–39: where every plan starts. */
    case rentan
    /** 40–79: holding on. */
    case bertahan
    /** 80–100: healthy. */
    case sehat

    /** The band a score falls in; scores outside 0...100 are clamped first. */
    package init(score: Int) {
        switch min(max(score, 0), 100) {
        case 80...: self = .sehat
        case 40...: self = .bertahan
        default: self = .rentan
        }
    }

    /** The share of the 0–100 scale the band takes on a meter: 40, 40 and 20 points. */
    package var span: Int {
        switch self {
        case .rentan, .bertahan: 40
        case .sehat: 20
        }
    }
}
