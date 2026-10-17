// swiftlint:disable identifier_name - "to" reads as the board's "Jadi …"
/**
 What Hasil Simulasi suggests when a plan falls short (Rekomendasi), the asset classes it names
 for the goal's horizon (never products), and how a plan deposits.
 */
package enum GoalRecommendation: Equatable, Sendable {
    /** Naikkan Investasi: this monthly (or yearly) deposit reaches the target. */
    case raiseDeposit(to: Int)
    /** Pilih Return Lebih Tinggi: this yearly return, as a fraction (0.12), reaches it. */
    case raiseReturn(to: Double)
    /** Perpanjang Waktu: this many years, with the target inflated to then. */
    case extendYears(to: Int, target: Int)
    /** Perpanjang Waktu for Dana Darurat: this many months. */
    case extendMonths(to: Int)
}
// swiftlint:enable identifier_name

/** The asset classes the site lists by horizon (Kelas Aset untuk Jangka Ini). */
package enum GoalAssetClass: CaseIterable, Equatable, Sendable {
    /** Reksa Dana Pasar Uang. */
    case moneyMarket
    /** Deposito Jangka Pendek. */
    case shortTermDeposit
    /** Reksa Dana Pendapatan Tetap. */
    case fixedIncomeFund
    /** Obligasi Negara. */
    case governmentBond
    /** Saham. */
    case stocks
    /** Reksa Dana Indeks. */
    case indexFund
    /** Reksa Dana Campuran. */
    case balancedFund
    /** ETF. */
    case etf
    /** Emas. */
    case gold
    /** Kripto. */
    case crypto
    /** Dolar AS, a Dana Darurat home on the site. */
    case usDollar
}

/** When a deposit goes in: at the start of each period (the site's default) or at its end. */
package enum DepositTiming: Equatable, Sendable {
    /** Tambah Dana di Awal. */
    case start
    /** Tambah Dana di Akhir. */
    case end
}

/** How often a plan deposits, which is also how often it compounds. */
package enum DepositPeriod: Equatable, Sendable {
    /** Menabung Setiap Bulan: monthly compounding. */
    case month
    /** Menabung Setiap Tahun: yearly compounding (Pendidikan always). */
    case year
}
