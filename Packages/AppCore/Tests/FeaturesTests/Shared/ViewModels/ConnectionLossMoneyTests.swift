import APIClient
import Domain
import Testing

@testable import Features

/**
 Dompet (UNG-01) and Budget (KIR-38) with the server unreachable, through their live services and
 the generated client: each shows the connection message, never the generic problem (Rule 12).
 */
@MainActor
@Suite("Connection loss on Dompet and Budget")
struct ConnectionLossMoneyTests {
    private static func lost<Value>(_ phase: ScreenPhase<Value>) -> Bool {
        guard case .failed(let problem) = phase else { return false }
        return problem.isConnectionLoss
    }

    @Test("Dompet and Budget show the connection message when the server cannot be reached")
    func screens() async {
        let wallets = WalletsModel(service: LiveWalletService(api: .down))
        await wallets.load()
        #expect(Self.lost(wallets.phase))

        let budget = BudgetModel(service: LiveBudgetService(api: .down))
        await budget.load()
        #expect(Self.lost(budget.phase))
    }
}
