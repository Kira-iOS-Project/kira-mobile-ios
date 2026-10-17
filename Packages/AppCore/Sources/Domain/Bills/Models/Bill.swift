/**
 A recurring bill or a debt's instalment (Tagihan & Cicilan, UNG-06; Tambah and Ubah Tagihan,
 UNG-07): what it is called, how much and when it is due each month, whether the amount is only an
 estimate, the debt an instalment pays into, and whether this period's is paid already.
 */
package struct Bill: Identifiable, Hashable, Sendable {
    /** The bill's id. */
    package let id: String
    /** "Listrik Token". */
    package let name: String
    /** A bill, or a debt's instalment (which opens Detail Utang). */
    package let kind: BillKind
    /** The ledger's expense category key ("bills", "household", "paylater_instalment"…). */
    package let category: String
    /** Whole rupiah each time it is due. */
    package let amount: Int
    /** "Perkiraan": the amount changes from month to month (electricity tokens). */
    package let isEstimate: Bool
    /** Sekali, tiap bulan or tiap tahun. */
    package let repeats: BillRepeat
    /** The first day it was due, as Tambah Tagihan set it. */
    package let dueOn: CalendarDay
    /** The day of the month it is due, 1 to 31 ("Tiap Tanggal 20"). */
    package let dueDay: Int
    /** The next day it is due. */
    package let nextDueOn: CalendarDay
    /** The debt an instalment pays into; nil for a bill. */
    package let debtId: String?
    /** Instalments still to pay ("14 Bulan Lagi"); nil when open-ended. */
    package let remainingInstalments: Int?
    /** Whether this period's is paid already ("Oktober Sudah Dibayar"). */
    package let paidThisPeriod: Bool

    /** A bill with the given parts. */
    package init(
        id: String, name: String, kind: BillKind, category: String, amount: Int, isEstimate: Bool = false,
        repeats: BillRepeat = .monthly, dueOn: CalendarDay, dueDay: Int, nextDueOn: CalendarDay,
        debtId: String? = nil, remainingInstalments: Int? = nil, paidThisPeriod: Bool = false
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.category = category
        self.amount = amount
        self.isEstimate = isEstimate
        self.repeats = repeats
        self.dueOn = dueOn
        self.dueDay = dueDay
        self.nextDueOn = nextDueOn
        self.debtId = debtId
        self.remainingInstalments = remainingInstalments
        self.paidThisPeriod = paidThisPeriod
    }
}

/** What a recurring payment is. */
package enum BillKind: String, Hashable, Sendable {
    /** A bill: electricity, internet, insurance. */
    case bill
    /** A debt's instalment, linked to its debt account. */
    case instalment
}

/** How often a bill comes back. */
package enum BillRepeat: String, CaseIterable, Hashable, Sendable {
    /** Sekali. */
    case once
    /** Tiap bulan. */
    case monthly
    /** Tiap tahun. */
    case yearly
}

/** The groups of Tagihan & Cicilan, nearest first. */
package enum BillGroup: String, CaseIterable, Hashable, Sendable {
    /** "7 Hari ke Depan". */
    case nextSevenDays = "next7Days"
    /** "Bulan Ini". */
    case thisMonth
    /** "Bulan Depan". */
    case nextMonth
    /** A yearly bill due after next month. */
    case later
}

/** One group of bills, sorted by their next due day. */
package struct BillSection: Hashable, Sendable {
    /** Which due window. */
    package let group: BillGroup
    /** Its bills, by next due day. */
    package let bills: [Bill]

    /** A group with its bills. */
    package init(group: BillGroup, bills: [Bill]) {
        self.group = group
        self.bills = bills
    }
}

/** `GET /bills`: how many recurring bills, what they cost a month, and the groups. */
package struct BillOverview: Hashable, Sendable {
    /** "6 tagihan berulang". */
    package let count: Int
    /** Whole rupiah a month, instalments included. */
    package let monthlyTotal: Int
    /** The non-empty groups, nearest first. */
    package let sections: [BillSection]

    /** An overview with the given parts. */
    package init(count: Int, monthlyTotal: Int, sections: [BillSection]) {
        self.count = count
        self.monthlyTotal = monthlyTotal
        self.sections = sections
    }
}
