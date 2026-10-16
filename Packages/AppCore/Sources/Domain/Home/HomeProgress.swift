/** BRD-02's "Langkah Awal": which first steps are done. Wallets do not exist yet, so they never count. */
package struct FirstStepsChecklist: Equatable, Sendable {
    /** The health check is answered. */
    package let healthCheck: Bool
    /** A first transaction is recorded. */
    package let firstTransaction: Bool
    /** A payday is set. */
    package let paydaySet: Bool

    /** The checklist with every step given. */
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
    /** What is paid off of the debt accounts so far. */
    package let paidOff: Int
    /** What the debt accounts started at. */
    package let total: Int
    /** What is left to pay. */
    package let remaining: Int
    /** Paid off as a share of the total, in whole percent. */
    package let percent: Int

    /** The progress with every field given. */
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
        /** A week of essential spending. */
        case oneWeek = "one_week"
        /** A month of essential spending. */
        case oneMonth = "one_month"
    }

    /** Which target is current. */
    package let kind: Kind
    /** The emergency fund today. */
    package let current: Int
    /** The fund the target asks for. */
    package let target: Int

    /** The target with every field given. */
    package init(kind: Kind, current: Int, target: Int) {
        self.kind = kind
        self.current = current
        self.target = target
    }
}

/** The line beside the Kira Score on Beranda ("+4 poin", "dari cek awal", "titik awal"). */
package enum ScoreTrend: Equatable, Sendable {
    /** The score rose by this many points. */
    case rise(Int)
    /** The score fell by this many points. */
    case fall(Int)
    /** The score did not move. */
    case unchanged
    /** Rentan, framed as where every plan starts. */
    case startingPoint
    /** The score of the first health check. */
    case firstCheck
    /** Nothing to say. */
    case none

    /** The line for a score in `band` that moved by `delta` (nil: no earlier period to compare). */
    package init(band: ScoreBand, delta: Int?, isInitial: Bool) {
        switch delta {
        case .some(let delta) where delta > 0: self = .rise(delta)
        case .some(let delta) where delta < 0: self = .fall(-delta)
        case .some: self = .unchanged
        case nil where band == .vulnerable: self = .startingPoint
        case nil where isInitial: self = .firstCheck
        case nil: self = .none
        }
    }
}
