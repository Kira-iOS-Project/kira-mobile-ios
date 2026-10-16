/** The words of Kira Peduli's quick replies and of the check-in's delays. */
import Domain
import Features
import Foundation

extension CareChoice {
    /** The chip's label, which is also the person's reply in the chat. */
    var title: LocalizedStringResource {
        switch self {
        case .safe: "care.choice.safe"
        case .unsafe: "care.choice.unsafe"
        case .talkFirst: "care.choice.talkFirst"
        case .better: "care.choice.better"
        case .stillHeavy: "care.choice.stillHeavy"
        case .talkAboutDebt: "care.choice.talkAboutDebt"
        }
    }
}

extension CheckInDelay {
    /** Besok, Lusa, Tiga Hari Lagi. */
    var title: LocalizedStringResource {
        switch self {
        case .tomorrow: "care.checkIn.tomorrow"
        case .dayAfterTomorrow: "care.checkIn.dayAfterTomorrow"
        case .threeDays: "care.checkIn.threeDays"
        }
    }

    /** "dalam 24 jam". */
    var subtitle: LocalizedStringResource { "care.checkIn.withinHours \(hours)" }
}
