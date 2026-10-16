/** The catalog keys of the plans' vocabulary: payment methods (plan names are in Shared/PlanID+Display). */
import Domain
import SwiftUI

extension PaymentMethod {
    /** "QRIS", "App Store". */
    var title: LocalizedStringResource {
        switch self {
        case .qris: "plans.method.qris"
        case .appStore: "plans.method.appStore"
        }
    }

    /** The line under the method's name. */
    var detail: LocalizedStringResource {
        switch self {
        case .qris: "plans.method.qris.detail"
        case .appStore: "plans.method.appStore.detail"
        }
    }
}

/** QRIS and App Store as check rows: Bayar and Metode Pembayaran. */
struct PaymentMethodRows: View {
    let title: LocalizedStringResource
    @Binding var selection: PaymentMethod

    var body: some View {
        KiraListGroup(title) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                KiraListRow(
                    Text(method.title), leading: .icon(.card), trailing: .check(selection == method),
                    action: { selection = method }
                )
                .subtitle(Text(method.detail))
            }
        }
    }
}

extension FormatStyle where Self == Date.FormatStyle {
    /** "15 November 2026": dates in full (CONTRACT.md visual rules). */
    static var plansFullDay: Self { .dateTime.day().month(.wide).year() }
    /** "15 November": the day a monthly plan renews. */
    static var plansDayMonth: Self { .dateTime.day().month(.wide) }
    /** "Oktober 2026": the month an invoice pays for. */
    static var plansMonthYear: Self { .dateTime.month(.wide).year() }
    /** "12.10": a time, written before "WIB". */
    static var plansTime: Self { .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits) }
}
