/** Current and after-payoff Kira Score values from the engine's simulation. */
package struct DebtScoreEstimate: Hashable, Sendable {
    package let current: Int
    package let afterPayoff: Int

    package init(current: Int, afterPayoff: Int) {
        self.current = current
        self.afterPayoff = afterPayoff
    }
}
