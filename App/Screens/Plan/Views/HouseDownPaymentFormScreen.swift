/**
 REN-02b, Tujuan Baru · DP Rumah (board TujuanDP): Mimpimu (when, the price today, DP and property
 inflation side by side, the automatic DP and Pokok KPR, what is saved), Strategi Investasimu, then
 Simulasi KPR (income, tenor, fixed and floating rates, the fixed period, NJOP-TKP). Hitung opens
 the result (REN-04c).
 */
import Domain
import Features
import SwiftUI

struct HouseDownPaymentFormScreen: View {
    @State private var model: HouseDownPaymentFormModel
    @State private var result: HouseDownPaymentResult?
    private let service: any GoalService
    private let onOpen: (AppRoute) -> Void

    init(
        service: any GoalService, model: HouseDownPaymentFormModel = HouseDownPaymentFormModel(),
        onOpen: @escaping (AppRoute) -> Void
    ) {
        self.service = service
        self.onOpen = onOpen
        _model = State(initialValue: model)
    }

    var body: some View {
        GoalFormFrame(
            goal: "plan.dp.goal", lead: "plan.dp.lead", category: .home, canCalculate: model.canCalculate,
            onCalculate: { result = model.result }, onHelp: { onOpen(.care) },
            content: {
                KiraSectionTitle("plan.goal.dream").padding(.top, KiraSpacing.space2)
                KiraField("plan.dp.years", text: $model.years).suffix("plan.goal.yearsAhead").keyboardType(.numberPad)
                KiraField("plan.dp.price", text: $model.price)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                HStack(alignment: .top, spacing: 10) {
                    KiraField("plan.dp.rate", text: $model.downPaymentRate).suffix("plan.dp.percent")
                        .hint("plan.dp.rate.hint").keyboardType(.decimalPad)
                    KiraField("plan.dp.inflation", text: $model.inflation).suffix("plan.goal.perYear")
                        .keyboardType(.decimalPad)
                }
                automatic
                KiraField("plan.dp.present", text: $model.present)
                    .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().keyboardType(.numberPad)
                GoalStrategyFields(deposit: $model.deposit, annualReturn: $model.annualReturn)
                MortgageFields(model: model)
            }
        )
        .navigationDestination(isPresented: showsResult) {
            if let result { HouseDownPaymentResultScreen(result: result, service: service, onOpen: onOpen) }
        }
    }

    private var showsResult: Binding<Bool> {
        Binding(get: { result != nil }, set: { if !$0 { result = nil } })
    }

    /** "Hitungan otomatis": DP Kamu Setara and Pokok KPR, as the price and the percent are typed. */
    private var automatic: some View {
        KiraListGroup {
            KiraListRow(Text("plan.dp.downPayment"), leading: .icon(.home))
                .amount(KiraAmount(Decimal(model.downPaymentNow ?? 0)))
            KiraListRow(Text("plan.dp.loan \(model.loanNow?.percent ?? 80)"), leading: .icon(.receipt))
                .amount(KiraAmount(Decimal(model.loanNow?.amount ?? 0)))
        }
        .accessibilityLabel(Text("plan.dp.automatic"))
    }
}

/** Simulasi KPR's inputs (TujuanDP): income, tenor, the two rates, the fixed period, NJOP-TKP. */
private struct MortgageFields: View {
    @Bindable var model: HouseDownPaymentFormModel

    var body: some View {
        KiraSectionTitle("plan.kpr.title", trailing: .note("plan.kpr.note")).padding(.top, KiraSpacing.space2)
        KiraField("plan.kpr.income", text: $model.income)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().hint("plan.kpr.income.hint")
            .keyboardType(.numberPad)
        GoalChoice(label: "plan.kpr.tenor", options: [10, 15, 20], selection: $model.tenorYears)
        HStack(alignment: .top, spacing: 10) {
            KiraField("plan.kpr.fixRate", text: $model.fixRate).suffix("plan.dp.percent").keyboardType(.decimalPad)
            KiraField("plan.kpr.floatRate", text: $model.floatRate).suffix("plan.dp.percent").keyboardType(.decimalPad)
        }
        GoalChoice(label: "plan.kpr.fixYears", options: [1, 3, 5], selection: $model.fixYears)
        KiraField("plan.kpr.njop", text: $model.njopTkp)
            .prefix("plan.goal.currency").suffix("plan.goal.cents").amount().hint("plan.kpr.njop.hint")
            .keyboardType(.numberPad)
    }
}

/** A board's segmented choice of years with its label shown above it ("Tenor KPR (Tahun)"). */
struct GoalChoice: View {
    let label: LocalizedStringResource
    let options: [Int]
    @Binding var selection: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
                .accessibilityHidden(true)
            KiraSegmented(
                label, options: options.map { .init(id: $0, title: "plan.goal.number \($0)") }, selection: $selection)
        }
    }
}
