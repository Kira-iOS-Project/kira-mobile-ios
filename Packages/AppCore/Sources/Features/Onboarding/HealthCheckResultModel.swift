import Domain
import Observation

/**
 Hasil Cek Kesehatan (ONB-13, ONB-13b): the first Kira Score with its plant, the three sub-scores
 in the order Tabung, Utang, Lindungi, up to three priority steps and the working of the formula.
 Every number comes from the engine's report.
 */
@MainActor @Observable
package final class HealthCheckResultModel {
    /** The report from the health check. */
    package let report: ScoreReport
    /** Whether "Gimana Ngitungnya?" is open; closed at first. */
    package var isFormulaOpen = false
    private let onContinue: () -> Void

    /** A result showing `report`; `onContinue` runs for "Amankan Akunku". */
    package init(report: ScoreReport, onContinue: @escaping () -> Void) {
        self.report = report
        self.onContinue = onContinue
    }

    /** The sub-scores in the board's order, those the report has. */
    package var groups: [GroupScore] {
        IndicatorGroup.allCases.compactMap { report.group($0) }
    }

    /** At most three steps, numbered from 1. */
    package var steps: [(number: Int, step: ScoreStep)] {
        report.steps.prefix(3).enumerated().map { (number: $0.offset + 1, step: $0.element) }
    }

    /** The working behind the score. */
    package var formula: ScoreFormula { ScoreFormula(report) }

    /** Points still needed for the next band; nil in the top band or when consumer debt caps it. */
    package var pointsToNextBand: Int? {
        report.cappedByConsumerDebt ? nil : report.band.pointsToNext(from: report.score)
    }

    /** "Amankan Akunku". */
    package func continueToLock() {
        onContinue()
    }
}
