import Domain
import SwiftUI

struct DebtInstallmentRow: View {
    let installment: DebtInstallment

    var body: some View {
        KiraListRow(Text(installment.dueAt, format: .kiraDate), leading: .icon(.calendar)) {
            KiraTag(installment.status.titleKey, tone: installment.status.tagTone)
        }
        .amount(KiraAmount(Decimal(installment.amount), size: .small))
    }
}

struct DebtPaymentRow: View {
    let payment: DebtPayment

    var body: some View {
        KiraListRow(Text(payment.paidAt, format: .kiraDate), leading: .icon(.check)) {
            KiraTag(payment.timing.titleKey, tone: payment.timing.tagTone)
        }
        .amount(KiraAmount(Decimal(payment.amount), size: .small))
    }
}

extension DebtInstallment.Status {
    var titleKey: LocalizedStringResource {
        switch self {
        case .upcoming: "wallet.debt.status.upcoming"
        case .dueSoon: "wallet.debt.status.dueSoon"
        case .paid: "wallet.debt.status.paid"
        case .onTime: "wallet.debt.status.onTime"
        case .late: "wallet.debt.status.late"
        }
    }

    var tagTone: KiraTag.Tone {
        switch self {
        case .late: .vulnerable
        case .upcoming, .dueSoon: .turmeric
        case .onTime, .paid: .healthy
        }
    }
}

extension DebtPayment.Timing {
    var titleKey: LocalizedStringResource {
        switch self {
        case .onTime: "wallet.debt.status.onTime"
        case .late: "wallet.debt.status.late"
        }
    }

    var tagTone: KiraTag.Tone { self == .late ? .vulnerable : .healthy }
}
