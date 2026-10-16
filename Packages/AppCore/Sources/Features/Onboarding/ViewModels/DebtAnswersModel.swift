import Domain
import Observation

/**
 Utang (ONB-11): debt kinds as chips, several allowed, and a row per debt under "Rinciannya".
 A chip that is not chosen yet opens the sheet for a debt of its kind; a chosen chip removes its
 debts. "Tidak Ada" clears every debt. A row opens the sheet to change that debt.
 */
@MainActor @Observable
package final class DebtAnswersModel {
    /** The debts added, in the order added. */
    package private(set) var entries: [DebtEntry] = []
    /** Whether "Tidak Ada" is chosen. */
    package private(set) var hasNoDebts = false
    /** Whether the Tambah Rincian Utang sheet is open. */
    package var isFormPresented = false
    /** The sheet's form; a new one each time the sheet opens. */
    package private(set) var form = DebtFormModel()

    /** No debts yet. */
    package init() {}

    /** Whether the chip of `kind` shows as chosen: a debt of that kind is in the list. */
    package func isSelected(_ kind: DebtKind) -> Bool {
        entries.contains { $0.kind == kind }
    }

    /** Taps the chip of `kind`. */
    package func toggle(_ kind: DebtKind) {
        if isSelected(kind) {
            entries.removeAll { $0.kind == kind }
        } else {
            open(DebtFormModel(kind: kind))
        }
    }

    /** Taps "Tidak Ada": clears every debt, or un-chooses it when chosen. */
    package func toggleNone() {
        hasNoDebts.toggle()
        if hasNoDebts { entries = [] }
    }

    /** "Tambah Utang Lain": a new debt of the last kind added, or paylater. */
    package func add() {
        open(DebtFormModel(kind: entries.last?.kind ?? .paylater))
    }

    /** A row: changes that debt. */
    package func edit(_ entry: DebtEntry) {
        open(DebtFormModel(editing: entry))
    }

    /** "Simpan Utang": adds or replaces the debt and closes the sheet, unless a field is missing. */
    package func saveForm() {
        guard let entry = form.entry() else { return }
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        hasNoDebts = false
        isFormPresented = false
    }

    /** "Isi Nanti": the step is skipped, so its debts go. */
    package func clear() {
        entries = []
        hasNoDebts = false
    }

    private func open(_ form: DebtFormModel) {
        self.form = form
        isFormPresented = true
    }
}
