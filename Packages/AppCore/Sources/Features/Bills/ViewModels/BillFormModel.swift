import APIClient
import Domain
import Foundation
import Observation

/**
 Tambah Tagihan (UNG-07) and Ubah Tagihan (UNG-07c): Nama, Jumlah, Kategori, Ulangi, Tanggal, and
 Ini Cicilan Utang with the debt account it pays. Nama, Jumlah and Tanggal are required, and a
 cicilan needs its account; Simpan waits for them. A save sends once at a time; a refusal or a lost
 connection is kept in `failure` for Belum Berhasil Menyimpan, the form untouched, and Coba Lagi
 sends the same action again. Ubah Tagihan also deletes (Hapus Tagihan Ini?).
 */
@MainActor @Observable
package final class BillFormModel {
    /** Which form this is. */
    package enum Mode: Hashable, Sendable {
        /** Tambah Tagihan, empty. */
        case create
        /** Ubah Tagihan, of the bill with this id. */
        case edit(id: String)
    }

    /** What the last save or delete was, for Coba Lagi. */
    private enum Action { case save, delete }

    /** The longest name the API takes. */
    package static let nameLimit = 60

    /** Tambah or Ubah Tagihan. */
    package let mode: Mode
    /** "Nama". */
    package var name: String
    /** "Jumlah", as typed (grouped while typing). */
    package var amount: String
    /** "Kategori". */
    package var category: BillCategory
    /** "Ulangi". */
    package var repeats: BillRepeat
    /** "Tanggal"; nil until one is chosen. */
    package var dueOn: CalendarDay?
    /** "Ini Cicilan Utang". */
    package var isInstalment: Bool
    /** The debt account a cicilan pays. */
    package var debtId: String?
    /** The debt accounts to link, from Dompet; empty until loaded or when there are none. */
    package private(set) var debts: [Wallet] = []
    /** True while a save or delete is on its way. */
    package private(set) var isWorking = false
    /** The problem of the last save or delete, for Belum Berhasil Menyimpan. */
    package var failure: AppProblem?
    /** True once saved: Tagihan Tersimpan on Tambah, back to Tagihan & Cicilan on Ubah. */
    package var saved = false
    /** True once deleted: back to Tagihan & Cicilan. */
    package private(set) var deleted = false

    private let editor: any BillEditorService
    private let wallets: any WalletService
    private var lastAction = Action.save

    /** A form in `mode`, opening with `values`. */
    package init(
        mode: Mode, values: BillFormValues = BillFormValues(), editor: any BillEditorService,
        wallets: any WalletService
    ) {
        self.mode = mode
        self.editor = editor
        self.wallets = wallets
        name = values.name
        amount = values.amount.map(String.init) ?? ""
        category = values.category
        repeats = values.repeats
        dueOn = values.dueOn
        isInstalment = values.debtId != nil
        debtId = values.debtId
    }

    /** What Simpan sends; nil while something required is missing or out of range. */
    package var draft: BillDraft? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= Self.nameLimit, let amount = AmountInput.value(of: amount),
            amount > 0, let dueOn, !isInstalment || debtId != nil
        else { return nil }
        return BillDraft(
            name: trimmed, amount: amount, category: category, repeats: repeats, dueOn: dueOn,
            debtId: isInstalment ? debtId : nil)
    }

    /** Whether Simpan is on. */
    package var canSave: Bool { draft != nil && !isWorking }

    /** The debt accounts from Dompet; none when they cannot load, so the toggle says so. */
    package func loadDebts() async {
        debts = (try? await wallets.overview().debts) ?? []
        if let debtId, !debts.contains(where: { $0.id == debtId }) { self.debtId = nil }
    }

    /** Simpan Tagihan or Simpan Perubahan. */
    package func save() async {
        guard let draft, !isWorking else { return }
        lastAction = .save
        await run {
            switch self.mode {
            case .create: _ = try await self.editor.createBill(draft)
            case .edit(let id): _ = try await self.editor.updateBill(id: id, draft)
            }
            self.saved = true
        }
    }

    /** Hapus on Hapus Tagihan Ini? (Ubah Tagihan only). */
    package func delete() async {
        guard case .edit(let id) = mode, !isWorking else { return }
        lastAction = .delete
        await run {
            try await self.editor.deleteBill(id: id)
            self.deleted = true
        }
    }

    /** Coba Lagi on Belum Berhasil Menyimpan: the same save or delete again. */
    package func retry() async {
        switch lastAction {
        case .save: await save()
        case .delete: await delete()
        }
    }

    private func run(_ work: @MainActor () async throws -> Void) async {
        isWorking = true
        failure = nil
        defer { isWorking = false }
        do {
            try await work()
        } catch {
            failure = AppProblem(error)
        }
    }
}

/** What a bill form opens with: empty and monthly, or the bill being changed. */
package struct BillFormValues: Hashable, Sendable {
    /** "Nama". */
    package var name = ""
    /** "Jumlah"; nil when empty. */
    package var amount: Int?
    /** "Kategori". */
    package var category = BillCategory.bills
    /** "Ulangi". */
    package var repeats = BillRepeat.monthly
    /** "Tanggal"; nil until chosen. */
    package var dueOn: CalendarDay?
    /** The debt account of a cicilan. */
    package var debtId: String?

    /** An empty Tambah Tagihan. */
    package init() {}

    /** Ubah Tagihan of a bill with these fields. */
    package init(
        name: String, amount: Int, category: BillCategory, repeats: BillRepeat, dueOn: CalendarDay,
        debtId: String? = nil
    ) {
        self.name = name
        self.amount = amount
        self.category = category
        self.repeats = repeats
        self.dueOn = dueOn
        self.debtId = debtId
    }
}
