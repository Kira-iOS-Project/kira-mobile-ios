/**
 The words of Kenali Profil Risikomu's five questions, as the boards KuisRisiko to KuisRisiko5
 write them: the title, the line under it and the four options in the board's order (the order
 the answers' indexes count). The fifth question's options are the ranges of the income.
 */
import Domain
import Foundation

extension RiskQuestion {
    /** The question. */
    var title: LocalizedStringResource {
        switch self {
        case .goal: "plan.risk.goal.title"
        case .drawdown: "plan.risk.drawdown.title"
        case .horizon: "plan.risk.horizon.title"
        case .experience: "plan.risk.experience.title"
        case .monthlyDeposit: "plan.risk.deposit.title"
        }
    }

    /**
     The line under the question. The fifth names the income; when the income is unknown it keeps
     only its second sentence (content not on a board: owner content review).
     */
    func subtitle(income: Int?) -> LocalizedStringResource {
        switch self {
        case .goal: "plan.risk.goal.subtitle"
        case .drawdown: "plan.risk.drawdown.subtitle"
        case .horizon: "plan.risk.horizon.subtitle"
        case .experience: "plan.risk.experience.subtitle"
        case .monthlyDeposit:
            if let income {
                "plan.risk.deposit.subtitle \(Decimal(income).formatted(.rupiah))"
            } else {
                "plan.risk.deposit.subtitleUnknown"
            }
        }
    }

    /** The four options, in the board's order. */
    func options(_ ranges: MonthlyDepositRanges) -> [LocalizedStringResource] {
        switch self {
        case .goal: ["plan.risk.goal.option1", "plan.risk.goal.option2", "plan.risk.goal.option3", "plan.risk.unsure"]
        case .drawdown:
            [
                "plan.risk.drawdown.option1", "plan.risk.drawdown.option2", "plan.risk.drawdown.option3",
                "plan.risk.unsure",
            ]
        case .horizon:
            [
                "plan.risk.horizon.option1", "plan.risk.horizon.option2", "plan.risk.horizon.option3",
                "plan.risk.horizon.option4",
            ]
        case .experience:
            [
                "plan.risk.experience.option1", "plan.risk.experience.option2", "plan.risk.experience.option3",
                "plan.risk.experience.option4",
            ]
        case .monthlyDeposit: Self.depositOptions(ranges)
        }
    }

    private static func depositOptions(_ ranges: MonthlyDepositRanges) -> [LocalizedStringResource] {
        let low = ranges.low.formatted(.rupiah)
        let middle = ranges.middle.formatted(.rupiah)
        let high = ranges.high.formatted(.rupiah)
        return [
            "plan.risk.deposit.upTo \(low)", "plan.risk.deposit.between \(low) \(middle)",
            "plan.risk.deposit.between \(middle) \(high)", "plan.risk.deposit.over \(high)",
        ]
    }
}
