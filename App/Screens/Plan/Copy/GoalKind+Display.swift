/** Each goal kind as Tujuan Baru's tiles draw it (REN-02): its name, its line, and its icon. */
import Domain
import SwiftUI

extension GoalKind {
    /** "Dana Darurat", "DP Rumah", … */
    var title: LocalizedStringResource {
        switch self {
        case .emergencyFund: "plan.kind.emergencyFund"
        case .houseDownPayment: "plan.kind.houseDownPayment"
        case .education: "plan.kind.education"
        case .wedding: "plan.kind.wedding"
        case .retirement: "plan.kind.retirement"
        case .vehicle: "plan.kind.vehicle"
        case .goods: "plan.kind.goods"
        case .other: "plan.kind.other"
        }
    }

    /** The tile's line under the name ("Untuk hal tak terduga"). */
    var subtitle: LocalizedStringResource {
        switch self {
        case .emergencyFund: "plan.kind.emergencyFund.subtitle"
        case .houseDownPayment: "plan.kind.houseDownPayment.subtitle"
        case .education: "plan.kind.education.subtitle"
        case .wedding: "plan.kind.wedding.subtitle"
        case .retirement: "plan.kind.retirement.subtitle"
        case .vehicle: "plan.kind.vehicle.subtitle"
        case .goods: "plan.kind.goods.subtitle"
        case .other: "plan.kind.other.subtitle"
        }
    }

    /** The CategoryIcon the boards give the kind. */
    var category: KiraCategory {
        switch self {
        case .emergencyFund: .emergency
        case .houseDownPayment: .home
        case .education: .education
        case .wedding: .wedding
        case .retirement: .retirement
        case .vehicle: .transport
        case .goods: .goods
        case .other: .other
        }
    }
}
