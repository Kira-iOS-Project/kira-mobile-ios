/**
 The inputs of Rencana Pelunasan, as the board lays them: "Metode" with Snowball or Avalanche and
 the method's one line, and "Tambahan Bayar per Bulan" in rupiah (grouped while typed) with the
 cicilan minimum under it; and "Gimana Ngitungnya?" (SKR-03b), whose open state belongs to the
 screen and is never sent.
 */
import Domain
import Features
import SwiftUI

/** The method's segmented control and the extra payment's field. */
struct PayoffControls: View {
    let model: PayoffModel
    let simulation: PayoffSimulation

    private static let options: [KiraSegmented<PayoffMethod>.Option] = [
        .init(id: .snowball, title: "payoff.method.snowball"),
        .init(id: .avalanche, title: "payoff.method.avalanche"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space5) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                Text("payoff.method.title").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
                KiraSegmented("payoff.method.label", options: Self.options, selection: method)
                note(PayoffCopy.methodLine(model.method))
            }
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                KiraField("payoff.extra.label", text: extra)
                    .prefix("onboarding.quiz.currency")
                    .suffix("onboarding.quiz.cents")
                    .amount()
                    .error(errorText)
                    .keyboardType(.numberPad)
                Slider(value: slider, in: model.sliderRange, step: Double(PayoffModel.sliderStep)) {
                    Text("payoff.extra.slider")
                }
                .tint(.pandan)
                .disabled(!model.canSlide)
                .padding(.horizontal, KiraSpacing.space1)
                .accessibilityValue(Text(PayoffCopy.rupiah(model.extraPayment)))
                note("payoff.extra.hint \(PayoffCopy.rupiah(simulation.minimumInstalments))")
            }
        }
    }

    private func note(_ text: LocalizedStringResource) -> some View {
        Text(text).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            .padding(.horizontal, KiraSpacing.space1)
    }

    private var method: Binding<PayoffMethod> {
        Binding(get: { model.method }, set: { chosen in Task { await model.choose(chosen) } })
    }

    private var extra: Binding<String> {
        Binding(get: { model.extraText }, set: { typed in Task { await model.setExtra(typed) } })
    }

    /** The slider moves the same amount the field holds, in steps of Rp10.000,00. */
    private var slider: Binding<Double> {
        Binding(
            get: { model.sliderValue },
            set: { value in Task { await model.setExtra(String(Int(value))) } })
    }

    private var errorText: LocalizedStringResource? {
        guard model.exceedsMaximum else { return nil }
        return "payoff.extra.tooHigh \(PayoffCopy.rupiah(simulation.maxExtraPayment))"
    }
}

/** "Gimana Ngitungnya?": where the extra goes, the first account's sum, and what happens after. */
struct PayoffHowAccordion: View {
    @Bindable var model: PayoffModel
    let simulation: PayoffSimulation

    var body: some View {
        KiraAccordion(
            "payoff.how.title", subtitle: "payoff.how.subtitle", icon: .calculator, isExpanded: $model.isHowOpen
        ) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                Text(PayoffCopy.howRule(simulation.method)).font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.ink)
                if let first = simulation.firstAccount {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(PayoffCopy.formula(simulation, first: first), id: \.key) { line in
                            Text(line)
                        }
                    }
                    .kiraFont(.formula).foregroundStyle(.ink)
                    .padding(.horizontal, KiraSpacing.space3)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.surface, in: RoundedRectangle(cornerRadius: KiraRadius.small))
                    .overlay(RoundedRectangle(cornerRadius: KiraRadius.small).strokeBorder(.hairline))
                }
                Text("payoff.how.after").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
