import Domain
import Foundation
import Observation

/**
 Tambah Rincian Utang (ONB-11b): the sheet that adds a debt, or changes one when opened from its
 row. Amounts are digits only (",00" beside the box); the tenor, the yearly interest and the due day
 are optional. A rate above 300 percent or a day outside 1 to 31 is left out rather than sent.
 */
@MainActor @Observable
package final class DebtFormModel {
    /** The kind chosen. */
    package var kind: DebtKind
    /** "Nama Utang". */
    package var name: String
    /** "Sisa Utang", grouped as typed. */
    package var remaining: String { didSet { regroup(\.remaining, oldValue) } }
    /** "Cicilan per Bulan", grouped as typed. */
    package var instalment: String { didSet { regroup(\.instalment, oldValue) } }
    /** "Sisa Tenor (Opsional)", in months. */
    package var tenor: String { didSet { regroup(\.tenor, oldValue) } }
    /** "Bunga per Tahun (opsional)", in percent with a decimal comma. */
    package var interest: String { didSet { regroup(\.interest, oldValue) } }
    /** "Tanggal Jatuh Tempo (opsional)", the day of the month. */
    package var dueDay: String { didSet { regroup(\.dueDay, oldValue) } }
    /** Whether the last save was refused for a missing name or amount. */
    package private(set) var showsMissing = false
    /** The debt being changed, nil when adding. */
    package let editing: DebtEntry?

    /** A form for a new debt of `kind`, or for changing `entry`. */
    package init(kind: DebtKind = .paylater, editing entry: DebtEntry? = nil) {
        editing = entry
        self.kind = entry?.kind ?? kind
        name = entry?.name ?? ""
        remaining = AmountInput.text(for: entry?.remaining)
        instalment = AmountInput.text(for: entry?.monthlyInstalment)
        tenor = entry?.remainingTenorMonths.map(String.init) ?? ""
        interest = PercentInput.text(for: entry?.annualInterestRate)
        dueDay = entry?.dueDay.map(String.init) ?? ""
    }

    /** The debt as filled in, or nil (with `showsMissing` set) when the name or an amount is missing. */
    package func entry() -> DebtEntry? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let left = AmountInput.value(of: remaining),
            let monthly = AmountInput.value(of: instalment)
        else {
            showsMissing = true
            return nil
        }
        return DebtEntry(
            id: editing?.id ?? UUID(), kind: kind, name: trimmed, remaining: left, monthlyInstalment: monthly,
            remainingTenorMonths: AmountInput.value(of: tenor), annualInterestRate: PercentInput.value(of: interest),
            dueDay: Int(dueDay).flatMap { (1...31).contains($0) ? $0 : nil })
    }

    private func regroup(_ field: ReferenceWritableKeyPath<DebtFormModel, String>, _ oldValue: String) {
        let text = self[keyPath: field]
        let grouped: String
        if field == \.tenor {
            grouped = DigitCode.digits(in: text, length: 3)
        } else if field == \.dueDay {
            grouped = DigitCode.digits(in: text, length: 2)
        } else if field == \.interest {
            grouped = PercentInput.cleaned(text)
        } else {
            grouped = AmountInput.grouped(text)
        }
        if grouped != self[keyPath: field] { self[keyPath: field] = grouped }
        if showsMissing, grouped != oldValue { showsMissing = false }
    }
}
