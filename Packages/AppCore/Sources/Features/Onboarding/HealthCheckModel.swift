import Domain
import Observation

/**
 The six-step health check (ONB-10 to ONB-12 and the steps between). Amounts are typed as digits
 and grouped as typed; "Lewati" or "Isi Nanti" leaves a step's answers empty. "Lihat Hasilku" sends
 every answer and hands the first Kira Score on.
 */
@MainActor @Observable
package final class HealthCheckModel {
    /** Step 1: "Penghasilan bersih". */
    package var income = "" { didSet { if let grouped = regrouped(income) { income = grouped } } }
    /** Step 1: "Tanggal Gajian". */
    package var payday = Payday(day: Payday.defaultDay)
    /** Step 2: "Pengeluaran pokok". */
    package var expenses = "" { didSet { if let grouped = regrouped(expenses) { expenses = grouped } } }
    /** Step 3. */
    package let debts = DebtAnswersModel()
    /** Step 4: "Dana darurat". */
    package var emergencyFund = "" { didSet { if let grouped = regrouped(emergencyFund) { emergencyFund = grouped } } }
    /** Step 4: "Menabung per bulan". */
    package var monthlySavings = "" {
        didSet { if let grouped = regrouped(monthlySavings) { monthlySavings = grouped } }
    }
    /** Step 5: "Aset lain". */
    package var otherAssets = "" { didSet { if let grouped = regrouped(otherAssets) { otherAssets = grouped } } }
    /** Step 5: "Kendaraan dan properti". */
    package var propertyAssets = "" {
        didSet { if let grouped = regrouped(propertyAssets) { propertyAssets = grouped } }
    }
    /** Step 6. */
    package let protection = ProtectionAnswersModel()
    /** Editing, sending or failed. */
    package private(set) var phase = SubmitPhase.editing
    private let service: any OnboardingService
    private let onScored: (ScoreReport) -> Void

    /** A quiz that sends its answers through `service` and hands the report to `onScored`. */
    package init(service: any OnboardingService, onScored: @escaping (ScoreReport) -> Void) {
        self.service = service
        self.onScored = onScored
    }

    /** "Lewati" or "Isi Nanti": empties the answers of `step`. */
    package func skip(_ step: HealthCheckStep) {
        switch step {
        case .income: income = ""
        case .expenses: expenses = ""
        case .debts: debts.clear()
        case .savings: (emergencyFund, monthlySavings) = ("", "")
        case .assets: (otherAssets, propertyAssets) = ("", "")
        case .protection: break
        }
    }

    /** Every answer, as the API takes them. */
    package var answers: HealthCheckAnswers {
        var answers = HealthCheckAnswers()
        answers.netMonthlyIncome = AmountInput.value(of: income)
        answers.payday = payday
        answers.essentialMonthlyExpenses = AmountInput.value(of: expenses)
        answers.debts = debts.entries
        answers.emergencyFund = AmountInput.value(of: emergencyFund)
        answers.monthlySavings = AmountInput.value(of: monthlySavings)
        answers.otherAssets = AmountInput.value(of: otherAssets)
        answers.propertyAssets = AmountInput.value(of: propertyAssets)
        answers.dependents = min(max(protection.dependents, 0), ProtectionAnswersModel.maximumDependents)
        answers.maritalStatus = protection.maritalStatus
        answers.protections = protection.protections
        return answers
    }

    /** "Lihat Hasilku": sends the answers; the engine on the server computes the score. */
    package func submit() async {
        guard !phase.isSubmitting else { return }
        phase = .submitting
        do {
            let report = try await service.submitHealthCheck(answers)
            phase = .editing
            onScored(report)
        } catch {
            phase = .failure(error)
        }
    }

    /** `text` grouped, or nil when it already is, so assigning it back ends the observers. */
    private func regrouped(_ text: String) -> String? {
        let grouped = AmountInput.grouped(text)
        return grouped == text ? nil : grouped
    }
}
