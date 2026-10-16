/** The six steps of the health check, in order ("Cek Kesehatan · N dari 6"). */
package enum HealthCheckStep: Int, CaseIterable, Hashable, Sendable {
    /** Penghasilan and Tanggal Gajian. */
    case income = 1
    /** Pengeluaran Pokok. */
    case expenses
    /** Utang. */
    case debts
    /** Tabungan & Dana Darurat. */
    case savings
    /** Aset. */
    case assets
    /** Tanggungan dan Proteksi. */
    case protection

    /** How many steps there are. */
    package static let total = allCases.count

    /** The step's number, from 1. */
    package var number: Int { rawValue }

    /** The step after this one, nil after the last. */
    package var next: HealthCheckStep? { HealthCheckStep(rawValue: rawValue + 1) }
}
