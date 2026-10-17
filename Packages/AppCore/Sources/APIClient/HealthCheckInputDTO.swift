/** The six-step health-check quiz's answers, sent with `saveHealthCheck(_:)` (ONB-10 to ONB-12). */

/** Jenis utang; paylater, online loans and credit cards count as consumer debt. */
package enum DebtKindDTO: String, CaseIterable, Sendable {
    /** Paylater. */
    case paylater
    /** Pinjol. */
    case onlineLoan = "online_loan"
    /** Kartu kredit. */
    case creditCard = "credit_card"
    /** Cicilan kendaraan. */
    case vehicle
    /** KPR. */
    case mortgage
    /** Pinjaman keluarga. */
    case familyLoan = "family_loan"
}

/** Status pernikahan: sets the emergency-fund target, 6× single, 9× married. */
package enum MaritalStatusDTO: String, CaseIterable, Sendable {
    /** Belum menikah. */
    case single
    /** Menikah. */
    case married
}

/** Perlindungan yang kamu punya. */
package enum ProtectionDTO: String, CaseIterable, Sendable {
    /** BPJS Kesehatan. */
    case bpjsHealth = "bpjs_health"
    /** BPJS Ketenagakerjaan. */
    case bpjsEmployment = "bpjs_employment"
    /** Asuransi jiwa. */
    case lifeInsurance = "life_insurance"
    /** Asuransi kesehatan swasta. */
    case privateHealth = "private_health"
}

/** One debt from Kuis Utang. */
package struct HealthCheckDebtDTO: Hashable, Sendable {
    /** Its kind. */
    package var kind: DebtKindDTO
    /** Its name ("Paylater A"). */
    package var name: String
    /** What is left to pay. */
    package var remaining: Int
    /** The monthly instalment. */
    package var monthlyInstalment: Int
    /** Months left; nil when unknown. */
    package var remainingTenorMonths: Int?
    /** The interest a year in percent; nil when unknown. */
    package var annualInterestRate: Double?
    /** The day of the month the instalment is due; nil when unknown. */
    package var dueDay: Int?

    /** A debt as entered. */
    package init(
        kind: DebtKindDTO, name: String, remaining: Int, monthlyInstalment: Int, remainingTenorMonths: Int?,
        annualInterestRate: Double? = nil, dueDay: Int? = nil
    ) {
        self.kind = kind
        self.name = name
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
        self.remainingTenorMonths = remainingTenorMonths
        self.annualInterestRate = annualInterestRate
        self.dueDay = dueDay
    }
}

/** The quiz's answers, filled step by step; a skipped amount stays nil and scores 0. */
package struct HealthCheckInputDTO: Hashable, Sendable {
    /** Penghasilan bersih per bulan. */
    package var netMonthlyIncome: Int?
    /** Tanggal gajian. */
    package var payday = PaydayDTO(day: nil, endOfMonth: false)
    /** Pengeluaran pokok per bulan. */
    package var essentialMonthlyExpenses: Int?
    /** Every debt, or none. */
    package var debts: [HealthCheckDebtDTO] = []
    /** Dana darurat. */
    package var emergencyFund: Int?
    /** Tabungan per bulan. */
    package var monthlySavings: Int?
    /** Tabungan dan investasi lain. */
    package var otherAssets: Int?
    /** Kendaraan dan properti. */
    package var propertyAssets: Int?
    /** Tanggungan: 0 to 3, where 3 means "3 Orang atau Lebih". */
    package var dependents = 0
    /** Status pernikahan; nil when skipped. */
    package var maritalStatus: MaritalStatusDTO?
    /** The protections held. */
    package var protections: [ProtectionDTO] = []

    /** Empty answers: every amount skipped. */
    package init() {}

    /** The request body. */
    func body() throws -> Components.Schemas.HealthCheck {
        Components.Schemas.HealthCheck(
            netMonthlyIncome: netMonthlyIncome,
            payday: .init(day: payday.day, endOfMonth: payday.endOfMonth),
            essentialMonthlyExpenses: essentialMonthlyExpenses,
            debts: try debts.map {
                .init(
                    kind: try bridged($0.kind), name: $0.name, remaining: $0.remaining,
                    monthlyInstalment: $0.monthlyInstalment, remainingTenorMonths: $0.remainingTenorMonths,
                    annualInterestRate: $0.annualInterestRate, dueDay: $0.dueDay)
            },
            emergencyFund: emergencyFund, monthlySavings: monthlySavings, otherAssets: otherAssets,
            propertyAssets: propertyAssets, dependents: dependents, maritalStatus: try bridged(maritalStatus),
            protections: try protections.map { try bridged($0) })
    }
}
