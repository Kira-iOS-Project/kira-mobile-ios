import Domain
import Testing

@testable import Features

@Suite("ScoreRoutes")
struct ScoreRoutesTests {
    @Test(
        "a step opens the indicator it improves, the debt plan, or the emergency mode not built yet",
        arguments: [
            (ScoreStepKind.payOffDebt, AppRoute.debtPlan),
            (.seekRelief, .unavailable(.debtEmergency)),
            (.buildEmergencyFund, .indicator(.emergencyFund)),
            (.addProtection, .indicator(.protection)),
            (.raiseSavings, .indicator(.savingsRatio)),
            (.lowerInstalments, .indicator(.instalmentRatio)),
            (.lowerDebtToAsset, .indicator(.debtToAsset)),
        ])
    func step(kind: ScoreStepKind, route: AppRoute) {
        #expect(ScoreStep(kind: kind, estimatedGain: 1).route == route)
    }

    @Test(
        "the next rung saves toward a goal, follows the payoff plan, or checks protection again",
        arguments: [
            (IndicatorKey.emergencyFund, AppRoute.unavailable(.plan)), (.savingsRatio, .unavailable(.plan)),
            (.instalmentRatio, .debtPlan), (.consumerDebt, .debtPlan),
            (.debtToAsset, .debtPlan), (.protection, .healthCheck),
        ])
    func nextRung(key: IndicatorKey, route: AppRoute) {
        #expect(key.nextRungRoute == route)
    }
}
