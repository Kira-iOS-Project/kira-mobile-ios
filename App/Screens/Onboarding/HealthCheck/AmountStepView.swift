/**
 The health-check steps that ask for amounts, all in the pattern of KuisPenghasilan: step 1
 Penghasilan (with Tanggal Gajian), and the steps the owner added to the canvas's three: 2
 Pengeluaran Pokok, 4 Tabungan & Dana Darurat, 5 Aset. Each has the privacy promise and
 "Lewati", which leaves the step empty.
 */
import Features
import SwiftUI

struct AmountStepView: View {
    let step: HealthCheckStep
    let flow: OnboardingFlowModel
    @Bindable var model: HealthCheckModel

    var body: some View {
        QuizStepLayout(step: step, title: title, flow: flow) {
            QuizQuestion(text: question)
            fields
            KiraNotice(.privacy, message: "onboarding.quiz.privacy")
        } actions: {
            QuizActions {
                model.skip(step)
                flow.next(after: step)
            } onNext: {
                flow.next(after: step)
            }
        }
    }

    @ViewBuilder private var fields: some View {
        switch step {
        case .income:
            QuizAmountField(label: "onboarding.income.field", hint: "onboarding.income.hint", text: $model.income)
            PaydayField(payday: $model.payday)
        case .expenses:
            QuizAmountField(label: "onboarding.expenses.field", hint: "onboarding.expenses.hint", text: $model.expenses)
        case .savings:
            QuizAmountField(label: "onboarding.savings.fund", hint: "onboarding.savings.fund.hint", text: $model.emergencyFund)
            QuizAmountField(label: "onboarding.savings.monthly", hint: "onboarding.savings.monthly.hint", text: $model.monthlySavings)
        case .assets:
            QuizAmountField(label: "onboarding.assets.other", hint: "onboarding.assets.other.hint", text: $model.otherAssets)
            QuizAmountField(label: "onboarding.assets.property", hint: "onboarding.assets.property.hint", text: $model.propertyAssets)
        case .debts, .protection:
            EmptyView()
        }
    }

    private var title: LocalizedStringResource {
        switch step {
        case .income: "onboarding.income.title"
        case .expenses: "onboarding.expenses.title"
        case .savings: "onboarding.savings.title"
        case .assets: "onboarding.assets.title"
        case .debts, .protection: "onboarding.income.title"
        }
    }

    private var question: LocalizedStringResource {
        switch step {
        case .income: "onboarding.income.question"
        case .expenses: "onboarding.expenses.question"
        case .savings: "onboarding.savings.question"
        case .assets: "onboarding.assets.question"
        case .debts, .protection: "onboarding.income.question"
        }
    }
}
