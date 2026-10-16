import Domain

/** Beranda in one of its three layouts (BRD-01 to BRD-03), as `GET /api/home` sends it. */

/** Which Beranda to draw. */
package enum HomeVariantDTO: String, CaseIterable, Sendable {
    /** BerandaBaru: no transaction yet. */
    case firstSteps = "first_steps"
    /** Main: money left, next step, score, weekly summary. */
    case overview
    /** BerandaBebasUtang: the debt plan. */
    case debtPlan = "debt_plan"
}

/** Sisa uang this payday period. */
package struct HomeMoneyDTO: Hashable, Sendable {
    /** Income this period, or the answered income when none is recorded. */
    package let income: Int
    /** Spent this period. */
    package let spent: Int
    /** Left until payday, never below 0. */
    package let remaining: Int
    /** "Sekitar Rp… per hari". */
    package let perDay: Int
    /** Spent as a whole percent of income ("75% dari gaji"). */
    package let spentPercent: Int
}

/** The score card. */
package struct HomeScoreDTO: Hashable, Sendable {
    /** 0–100. */
    package let score: Int
    /** Its band. */
    package let band: ScoreBand
    /** Change since last period ("+4 poin"); nil for none. */
    package let delta: Int?
    /** From the first health check ("dari cek awal"). */
    package let isInitial: Bool
}

/** Langkah Awal on BerandaBaru. */
package struct HomeChecklistDTO: Hashable, Sendable {
    /** Cek Kesehatan done. */
    package let healthCheck: Bool
    /** Catat Transaksi Pertama done. */
    package let firstTransaction: Bool
    /** Tambah Dompet: always false until wallets exist. */
    package let walletAdded: Bool
    /** Atur Tanggal Gajian done. */
    package let paydaySet: Bool
}

/** Rencana bebas utang: how much of the debt is paid. */
package struct DebtPlanDTO: Hashable, Sendable {
    /** Paid off so far ("Sudah lunas Rp1.600.000,00"). */
    package let paidOff: Int
    /** All the debt there was. */
    package let total: Int
    /** "Total sisa". */
    package let remaining: Int
    /** Paid as a whole percent ("8% lunas"). */
    package let percent: Int
}

/** Target mikro: a week of essential spending first, then a month. */
package struct MicroTargetDTO: Hashable, Sendable {
    /** Which target. */
    package enum Kind: String, CaseIterable, Sendable {
        /** Dana 1 Minggu. */
        case oneWeek = "one_week"
        /** Dana 1 Bulan. */
        case oneMonth = "one_month"
    }

    /** Which target. */
    package let kind: Kind
    /** The emergency fund now. */
    package let current: Int
    /** The target amount. */
    package let target: Int
}

/** A run of dates, both included (`YYYY-MM-DD`). */
package struct DateRangeDTO: Hashable, Sendable {
    /** The first day. */
    package let first: String
    /** The last day. */
    package let last: String
}

/** A step's place in the engine's list ("1 dari 3"). */
package struct StepPositionDTO: Hashable, Sendable {
    /** Its place, from 1. */
    package let index: Int
    /** How many steps there are. */
    package let total: Int
}
