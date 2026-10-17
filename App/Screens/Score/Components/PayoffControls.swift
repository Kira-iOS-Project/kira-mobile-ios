/**
 The two inputs of Rencana Pelunasan: the method (Snowball or Avalanche) and the extra payment,
 digits only with "Rp" before and ",00" after; and the "Gimana Ngitungnya?" accordion (SKR-03b),
 whose open state belongs to the screen and is never sent.
 */
import Domain
import Features
import SwiftUI

/** The method's segmented control and the extra payment's field. */
struct PayoffControls: View {
    let model: PayoffModel
    let maximum: Int

    private static let options: [KiraSegmented<PayoffMethod>.Option] = [
        .init(id: .snowball, title: "payoff.method.snowball"),
        .init(id: .avalanche, title: "payoff.method.avalanche"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraSegmented("payoff.method.label", options: Self.options, selection: method)
            KiraField("payoff.extra.label", text: extra)
                .prefix("onboarding.quiz.currency")
                .suffix("onboarding.quiz.cents")
                .hint("payoff.extra.hint \(RupiahFormatStyle().format(Decimal(maximum)))")
                .error(errorText)
                .keyboardType(.numberPad)
        }
    }

    private var method: Binding<PayoffMethod> {
        Binding(get: { model.method }, set: { chosen in Task { await model.choose(chosen) } })
    }

    private var extra: Binding<String> {
        Binding(get: { model.extraText }, set: { typed in Task { await model.setExtra(typed) } })
    }

    private var errorText: LocalizedStringResource? {
        guard model.exceedsMaximum else { return nil }
        return "payoff.extra.tooHigh \(RupiahFormatStyle().format(Decimal(maximum)))"
    }
}

/** "Gimana Ngitungnya?": how the plan is worked out, for the method on screen. */
struct PayoffHowAccordion: View {
    @Bindable var model: PayoffModel
    let method: PayoffMethod

    var body: some View {
        KiraAccordion(
            "payoff.how.title", subtitle: "payoff.how.subtitle", icon: .calculator, isExpanded: $model.isHowOpen
        ) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                Text(methodRule)
                Text("payoff.how.common")
            }
            .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var methodRule: LocalizedStringResource {
        switch method {
        case .snowball: "payoff.how.snowball"
        case .avalanche: "payoff.how.avalanche"
        }
    }
}
