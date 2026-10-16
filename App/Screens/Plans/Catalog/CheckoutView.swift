/**
 Bayar (AKN-06b, AKN-06e; boards BayarPaket, BayarPaketTahunan): the plan, its price and renewal,
 QRIS or App Store, and the prototype notice. Bayar is simulated; its dialog (AKN-06c, AKN-06f)
 leads to Langganan through `onDone`.
 */
import Domain
import Features
import SwiftUI

struct CheckoutView: View {
    @State private var model: CheckoutModel
    @State private var showsSuccess = false
    private let onDone: () -> Void
    @Environment(\.dismiss) private var dismiss

    init(terms: PlanTerms, period: BillingPeriod, service: any PlansService, onDone: @escaping () -> Void) {
        _model = State(initialValue: CheckoutModel(terms: terms, period: period, service: service))
        self.onDone = onDone
    }

    var body: some View {
        PlansScreenFrame {
            KiraNavBar(
                "checkout.title \(String(localized: model.terms.id.title))",
                leading: .back("checkout.back") { dismiss() })
            PlansHeader(
                "checkout.title \(String(localized: model.terms.id.title))",
                subtitle: lede)
            summary
            PaymentMethodRows(title: "checkout.method", selection: $model.paymentMethod)
            KiraNotice(.info, title: "plans.prototype", message: prototypeNote)
            if case .failed(let problem) = model.phase { PlansProblemNotice(problem: problem) }
            PlansButtonRow(
                secondary: KiraButton("checkout.cancel", variant: .secondary, size: .small) { dismiss() },
                primary: KiraButton("checkout.pay \(Decimal(model.price), format: .rupiah)", size: .small) {
                    Task { await model.pay() }
                }
            )
            .disabled(isPaying)
        }
        .onChange(of: isPaid) { _, paid in showsSuccess = paid }
        .kiraDialog(isPresented: $showsSuccess) { successDialog }
    }

    private var summary: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.terms.id.title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                renewal.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraAmount(Decimal(model.price))
        }
        .padding(KiraSpacing.space4)
        .kiraCard(.pandanSoft, border: .pandanLine)
        .accessibilityElement(children: .combine)
    }

    private var lede: LocalizedStringResource {
        switch model.period {
        case .monthly: "checkout.lede.monthly"
        case .yearly: "checkout.lede.yearly"
        }
    }

    private var prototypeNote: LocalizedStringResource {
        switch model.period {
        case .monthly: "checkout.prototype.monthly"
        case .yearly: "checkout.prototype.yearly"
        }
    }

    private var renewal: Text {
        switch model.period {
        case .monthly: Text("checkout.renews.monthly \(model.renewsOn.date, format: .plansDayMonth)")
        case .yearly: Text("checkout.renews.yearly \(model.renewsOn.date, format: .plansFullDay)")
        }
    }

    private var isPaying: Bool {
        if case .paying = model.phase { return true }
        return false
    }

    private var isPaid: Bool {
        if case .paid = model.phase { return true }
        return false
    }

    private var successDialog: KiraDialog {
        let name = String(localized: model.terms.id.title)
        let message: LocalizedStringResource =
            if case .paid(let subscription) = model.phase, model.period == .yearly {
                "checkout.success.yearly \(name) \(subscription.renewsOn.date, format: .plansFullDay)"
            } else {
                "checkout.success.monthly \(String(localized: model.terms.id.shortTitle))"
            }
        return KiraDialog(
            "checkout.success.title \(String(localized: model.terms.id.title))", message: message,
            art: .illustration(.bloom), primary: KiraButton("checkout.done", action: onDone))
    }
}
