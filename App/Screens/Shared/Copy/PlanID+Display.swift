/**
 A plan's name as every screen writes it (Profil, Paket, Langganan, Beasiswa): "Kira Gratis",
 "Kira Muda", "Kira Plus", and the short form of "Fitur Plus".
 */
import Domain
import SwiftUI

extension PlanID {
    /** "Kira Gratis", "Kira Muda", "Kira Plus". */
    var title: LocalizedStringResource {
        switch self {
        case .free: "plans.name.free"
        case .young: "plans.name.young"
        case .plus: "plans.name.plus"
        }
    }

    /** "Muda" and "Plus", as in "Fitur Plus". */
    var shortTitle: LocalizedStringResource {
        switch self {
        case .free: "plans.short.free"
        case .young: "plans.short.young"
        case .plus: "plans.short.plus"
        }
    }
}
