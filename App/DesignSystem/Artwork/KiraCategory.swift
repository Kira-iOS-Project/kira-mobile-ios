/**
 The category tiles' names (index.d.ts CategoryName) with the soft tint of each tile and its name
 on screen. Wallets and debts (bank, ewallet, cash, card, paylater, onlineLoan), goals (emergency,
 home, education, wedding, retirement, goods) and asset classes (bank for deposits, mutualFunds,
 governmentBonds, gold, stocks, crypto) share the set; a tile never stands for a product or a brand.
 */
import SwiftUI

/** A category, wallet, goal or asset class with its illustrated tile. */
enum KiraCategory: String, CaseIterable {
    case food, transport, coffee, shopping, bills, salary, paylater, savings, protection, home
    case education, health, entertainment, wedding, retirement, bank, ewallet, cash, card
    case onlineLoan = "online-loan"
    case gold, stocks
    case mutualFunds = "mutual-funds"
    case crypto
    case governmentBonds = "government-bonds"
    case emergency, goods, other

    /** The tile's soft background (an art-*-light token). */
    var tint: Color {
        switch self {
        case .food, .savings, .wedding, .gold, .emergency: .artTurmericLight
        case .transport, .shopping, .salary, .retirement, .ewallet, .cash, .stocks, .governmentBonds, .other:
            .artGreenLight
        case .coffee, .home, .health, .card, .onlineLoan, .crypto, .goods: .artPeachLight
        case .bills, .paylater, .protection, .education, .entertainment, .bank, .mutualFunds: .artSkyLight
        }
    }

    /** The category's name on screen, Title Case. */
    var title: LocalizedStringResource {
        switch self {
        case .food: "ds.category.food"
        case .transport: "ds.category.transport"
        case .coffee: "ds.category.coffee"
        case .shopping: "ds.category.shopping"
        case .bills: "ds.category.bills"
        case .salary: "ds.category.salary"
        case .paylater: "ds.category.paylater"
        case .savings: "ds.category.savings"
        case .protection: "ds.category.protection"
        case .home: "ds.category.home"
        case .education: "ds.category.education"
        case .health: "ds.category.health"
        case .entertainment: "ds.category.entertainment"
        case .wedding: "ds.category.wedding"
        case .retirement: "ds.category.retirement"
        case .bank: "ds.category.bank"
        case .ewallet: "ds.category.ewallet"
        case .cash: "ds.category.cash"
        case .card: "ds.category.card"
        case .onlineLoan: "ds.category.onlineLoan"
        case .gold: "ds.category.gold"
        case .stocks: "ds.category.stocks"
        case .mutualFunds: "ds.category.mutualFunds"
        case .crypto: "ds.category.crypto"
        case .governmentBonds: "ds.category.governmentBonds"
        case .emergency: "ds.category.emergency"
        case .goods: "ds.category.goods"
        case .other: "ds.category.other"
        }
    }
}
