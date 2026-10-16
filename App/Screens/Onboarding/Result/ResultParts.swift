/** The priority steps and the formula of Hasil Cek Kesehatan (ONB-13, ONB-13b). */
import Domain
import Features
import SwiftUI

/** "Tiga Langkah Prioritas": numbered steps, the first in pandan, each with its points. */
struct ResultSteps: View {
    let model: HealthCheckResultModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraSectionTitle("onboarding.result.steps")
            VStack(spacing: 0) {
                ForEach(model.steps, id: \.number) { item in
                    StepRow(number: item.number, copy: ScoreStepCopy(step: item.step))
                        .overlay(alignment: .bottom) {
                            if item.number < model.steps.count { Rectangle().fill(.line).frame(height: 1) }
                        }
                }
            }
            .padding(.horizontal, KiraSpacing.space4)
            .kiraCard(.surfaceRaised, border: .hairline, cornerRadius: KiraRadius.large)
        }
    }
}

private struct StepRow: View {
    let number: Int
    let copy: ScoreStepCopy

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number, format: .number)
                .font(KiraFont.display(14, .heavy, relativeTo: .footnote))
                .foregroundStyle(number == 1 ? Color.onPandan : .ink)
                .frame(width: 28, height: 28)
                .kiraCard(
                    number == 1 ? .pandan : .surfaceMuted, border: number == 1 ? .pandan : .hairline, cornerRadius: 14
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                copy.title.font(.headline).kiraLineHeight(22, size: 17)
                copy.detail.font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                KiraTag(copy.gain, tone: .pandan, icon: .trendUp).padding(.top, 6)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.ink)
        .padding(.vertical, KiraSpacing.space4)
        .accessibilityElement(children: .combine)
    }
}

/** "Gimana Ngitungnya?": the average of the six indicators, worked out, and the bands and method. */
struct FormulaAccordion: View {
    @Bindable var model: HealthCheckResultModel

    var body: some View {
        let formula = model.formula
        KiraAccordion(
            "onboarding.result.formula.title", subtitle: "onboarding.result.formula.subtitle", icon: .calculator,
            isExpanded: $model.isFormulaOpen
        ) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                Text("onboarding.result.formula.lead").font(.subheadline).kiraLineHeight(20, size: 15)
                VStack(alignment: .leading, spacing: 0) {
                    Text("onboarding.result.formula.sum \(sum(formula)) \(formula.points.count)")
                    Text("onboarding.result.formula.total \(average(formula)) \(formula.rounded)")
                }
                .kiraFont(.formula)
                .foregroundStyle(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                .kiraCard(.surface, border: .hairline, cornerRadius: KiraRadius.small)
                Text("onboarding.result.formula.bands").onboardingNote()
            }
        }
    }

    /** "25 + 45 + 70 + 50 + 80 + 100". */
    private func sum(_ formula: ScoreFormula) -> String {
        formula.points.map(String.init).joined(separator: " + ")
    }

    /**
     "61,7": one decimal with a comma, as Kira writes every number whatever the device's region, so
     the style keeps its own locale (`Text(_:format:)` would put the screen's back).
     */
    private func average(_ formula: ScoreFormula) -> String {
        formula.average.formatted(.number.precision(.fractionLength(1)).locale(Locale(identifier: "id_ID")))
    }
}
