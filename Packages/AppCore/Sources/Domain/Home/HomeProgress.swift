/** BRD-02's "Langkah Awal": which first steps are done. Wallets do not exist yet, so they never count. */
package struct FirstStepsChecklist: Equatable, Sendable {
    package let healthCheck: Bool
    package let firstTransaction: Bool
    package let paydaySet: Bool

    package init(healthCheck: Bool, firstTransaction: Bool, paydaySet: Bool) {
        self.healthCheck = healthCheck
        self.firstTransaction = firstTransaction
        self.paydaySet = paydaySet
    }

    /** How many of the shown steps are done. */
    package var doneCount: Int {
        [healthCheck, firstTransaction, paydaySet].filter { $0 }.count
    }

    /** How many steps the list shows. */
    package var total: Int { 3 }
}

/** BRD-03's hero: how much of the debt is paid off. */
package struct DebtPlanProgress: Equatable, Sendable {
    package let paidOff: Int
    package let total: Int
    package let remaining: Int
    package let percent: Int

    package init(paidOff: Int, total: Int, remaining: Int, percent: Int) {
        self.paidOff = paidOff
        self.total = total
        self.remaining = remaining
        self.percent = percent
    }

    /** Whether any debt is paid off yet, which changes the encouragement under the amount. */
    package var hasPaidSome: Bool { paidOff > 0 }
}

/** BRD-03's micro target: an emergency fund for one week, then for one month, of essentials. */
package struct MicroTarget: Equatable, Sendable {
    /** How long the target lasts. */
    package enum Kind: String, CaseIterable, Sendable {
        case oneWeek = "one_week"
        case oneMonth = "one_month"
    }

    package let kind: Kind
    package let current: Int
    package let target: Int

    package init(kind: Kind, current: Int, target: Int) {
        self.kind = kind
        self.current = current
        self.target = target
    }
}

/** The line beside the Kira Score on Beranda ("+4 poin", "dari cek awal", "titik awal"). */
package enum ScoreTrend: Equatable, Sendable {
    /** The score rose by this many points. */
    case up(Int)
    /** The score fell by this many points. */
    case down(Int)
    /** The score did not move. */
    case unchanged
    /** Rentan, framed as where every plan starts. */
    case startingPoint
    /** The score of the first health check. */
    case firstCheck
    /** Nothing to say. */
    case none

    package init(band: ScoreBand, delta: Int?, isInitial: Bool) {
        switch delta {
        case .some(let delta) where delta > 0: self = .up(delta)
        case .some(let delta) where delta < 0: self = .down(-delta)
        case .some: self = .unchanged
        case nil where band == .vulnerable: self = .startingPoint
        case nil where isInitial: self = .firstCheck
        case nil: self = .none
        }
    }
}
