/** The order a payoff plan pays in (SKR-03). */
package enum PayoffMethod: String, CaseIterable, Hashable, Sendable {
    /** Snowball: the smallest balance first. */
    case snowball
    /** Avalanche: the highest interest first. */
    case avalanche

    /** The other method, which the plan is compared with. */
    package var other: PayoffMethod {
        switch self {
        case .snowball: .avalanche
        case .avalanche: .snowball
        }
    }
}
