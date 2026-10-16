/**
 The three bands of the Kira Score (design system: BandPill, bandOf). A band is a starting point,
 never a grade: the vulnerable band (Rentan on screen) is the first step, so its colour is a muted
 brick, never an alarm red.
 */

/**
 The band of a score, in its order on the scale: vulnerable 0–39, coping 40–79 and healthy 80–100
 (Rentan, Bertahan and Sehat on screen).
 */
package enum ScoreBand: String, CaseIterable, Sendable {
    /** 0–39: where every plan starts. */
    case vulnerable
    /** 40–79: holding on. */
    case coping
    /** 80–100: healthy. */
    case healthy

    /** The band a score falls in; scores outside 0...100 are clamped first. */
    package init(score: Int) {
        switch min(max(score, 0), 100) {
        case 80...: self = .healthy
        case 40...: self = .coping
        default: self = .vulnerable
        }
    }

    /** The share of the 0–100 scale the band takes on a meter: 40, 40 and 20 points. */
    package var span: Int {
        switch self {
        case .vulnerable, .coping: 40
        case .healthy: 20
        }
    }
}
