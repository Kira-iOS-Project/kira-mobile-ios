import Domain
import SwiftUI

extension WalletType {
    var titleKey: LocalizedStringResource {
        switch self {
        case .bank: "wallet.type.bank"
        case .ewallet: "wallet.type.ewallet"
        case .cash: "wallet.type.cash"
        case .creditCard: "wallet.type.creditCard"
        case .paylater: "wallet.type.paylater"
        case .onlineLoan: "wallet.type.onlineLoan"
        case .vehicle: "wallet.type.vehicle"
        case .mortgage: "wallet.type.mortgage"
        case .familyLoan: "wallet.type.familyLoan"
        case .other: "wallet.type.other"
        }
    }

    var category: KiraCategory {
        switch self {
        case .bank: .bank
        case .ewallet: .ewallet
        case .cash: .cash
        case .creditCard: .card
        case .paylater: .paylater
        case .onlineLoan: .onlineLoan
        case .vehicle: .transport
        case .mortgage: .home
        case .familyLoan: .other
        case .other: .other
        }
    }
}
