/** The words of Menikah's budget: each row's name and each example budget's. */
import Domain
import Foundation

extension WeddingItemKind {
    /** "Venue / Gedung" … "Undangan". */
    var title: LocalizedStringResource {
        switch self {
        case .venue: "plan.wedding.venue"
        case .emcee: "plan.wedding.emcee"
        case .organizer: "plan.wedding.organizer"
        case .makeup: "plan.wedding.makeup"
        case .attire: "plan.wedding.attire"
        case .dowry: "plan.wedding.dowry"
        case .documentation: "plan.wedding.documentation"
        case .music: "plan.wedding.music"
        case .decoration: "plan.wedding.decoration"
        case .catering: "plan.wedding.catering"
        case .souvenir: "plan.wedding.souvenir"
        case .invitation: "plan.wedding.invitation"
        }
    }
}

extension WeddingPreset {
    /** Ekonomis, Standar, Sultan. */
    var title: LocalizedStringResource {
        switch self {
        case .economical: "plan.wedding.economical"
        case .standard: "plan.wedding.standard"
        case .lavish: "plan.wedding.lavish"
        }
    }
}
