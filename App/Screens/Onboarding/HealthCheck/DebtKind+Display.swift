/** How each kind of debt shows on the quiz: its chip's name and its category tile (ONB-11). */
import Domain
import SwiftUI

extension DebtKind {
    /** The chip's name ("Paylater", "Cicilan Kendaraan"). */
    var title: LocalizedStringResource {
        switch self {
        case .paylater: "onboarding.debt.kind.paylater"
        case .onlineLoan: "onboarding.debt.kind.onlineLoan"
        case .creditCard: "onboarding.debt.kind.creditCard"
        case .vehicle: "onboarding.debt.kind.vehicle"
        case .mortgage: "onboarding.debt.kind.mortgage"
        case .familyLoan: "onboarding.debt.kind.familyLoan"
        }
    }

    /** The tile the board puts on its chip and row. */
    var category: KiraCategory {
        switch self {
        case .paylater: .paylater
        case .onlineLoan: .onlineLoan
        case .creditCard: .card
        case .vehicle: .transport
        case .mortgage: .home
        case .familyLoan: .cash
        }
    }
}
