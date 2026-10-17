import Domain

/** Where the score's steps and indicators lead. */
extension ScoreStep {
    /**
     Paying off goes to the payoff plan (not built yet) and seeking relief to Mode Darurat Utang;
     every other step opens the indicator it improves.
     */
    package var route: AppRoute {
        switch kind {
        case .payOffDebt: .unavailable(.debtPlan)
        case .seekRelief: .debtEmergency
        case .buildEmergencyFund: .indicator(.emergencyFund)
        case .addProtection: .indicator(.protection)
        case .raiseSavings: .indicator(.savingsRatio)
        case .lowerInstalments: .indicator(.instalmentRatio)
        case .lowerDebtToAsset: .indicator(.debtToAsset)
        }
    }
}

extension IndicatorKey {
    /**
     The primary button of the next-rung card: "Atur Setoran" opens a savings goal (Rencana, not
     built yet), "Lihat Rencana" the payoff plan, and protection asks for the health check again.
     */
    package var nextRungRoute: AppRoute {
        switch self {
        case .emergencyFund, .savingsRatio: .unavailable(.plan)
        case .instalmentRatio, .consumerDebt, .debtToAsset: .unavailable(.debtPlan)
        case .protection: .healthCheck
        }
    }
}
