/**
 The words of Hasil Kuis (REN-07) for each profile: its name and its sentence. The board writes
 Moderat's; Konservatif's and Agresif's follow its length and structure, describing risk tolerance
 only (content not on a board: owner content review).
 */
import Domain
import Foundation

extension RiskProfile {
    /** Konservatif, Moderat, Agresif. */
    var title: LocalizedStringResource {
        switch self {
        case .conservative: "plan.risk.profile.conservative"
        case .moderate: "plan.risk.profile.moderate"
        case .aggressive: "plan.risk.profile.aggressive"
        }
    }

    /** The sentence under the name; Konservatif's and Agresif's are content not on a board: owner content review. */
    var sentence: LocalizedStringResource {
        switch self {
        case .conservative: "plan.risk.profile.conservative.body"
        case .moderate: "plan.risk.profile.moderate.body"
        case .aggressive: "plan.risk.profile.aggressive.body"
        }
    }
}
