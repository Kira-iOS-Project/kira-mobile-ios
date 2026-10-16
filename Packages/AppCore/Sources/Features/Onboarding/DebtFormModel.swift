import Domain
import Foundation
import Observation

/**
 Tambah Rincian Utang (ONB-11b): the sheet that adds a debt, or changes one when opened from its
 row. Amounts are digits only (",00" beside the box); the tenor is optional.
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
    /** "Sisa Tenor (opsional)", in months. */
    package var tenor: String { didSet { regroup(\.tenor, oldValue) } }
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
            remainingTenorMonths: AmountInput.value(of: tenor))
    }

    private func regroup(_ field: ReferenceWritableKeyPath<DebtFormModel, String>, _ oldValue: String) {
        let grouped = field == \.tenor ? DigitCode.digits(in: self[keyPath: field], length: 3) : AmountInput.grouped(self[keyPath: field])
        if grouped != self[keyPath: field] { self[keyPath: field] = grouped }
        if showsMissing, grouped != oldValue { showsMissing = false }
    }
}
