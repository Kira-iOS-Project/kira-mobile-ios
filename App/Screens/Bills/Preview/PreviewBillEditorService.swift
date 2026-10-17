/**
 Tambah and Ubah Tagihan on the preview: every save and delete lands after a short pause and nothing
 leaves the device, or, with `fails`, each one is refused as a lost connection (Belum Berhasil
 Menyimpan).
 */
import APIClient
import Domain
import Features

actor PreviewBillEditorService: BillEditorService {
    private let fails: Bool
    private var nextId = 1

    init(fails: Bool = false) {
        self.fails = fails
    }

    func createBill(_: BillDraft) async throws -> String {
        try await answer()
        defer { nextId += 1 }
        return "bill-\(nextId)"
    }

    func updateBill(id: String, _: BillDraft) async throws -> String {
        try await answer()
        return id
    }

    func deleteBill(id _: String) async throws {
        try await answer()
    }

    private func answer() async throws {
        try await Task.sleep(for: .milliseconds(180))
        if fails { throw AppProblem.connectionLost }
    }
}

extension BillFormValues {
    /** UbahTagihan's bill: Internet Rumah, Rp350.000,00 a month on the 22nd. */
    static let internet = BillFormValues(
        name: "Internet Rumah", amount: 350_000, category: .bills, repeats: .monthly,
        dueOn: CalendarDay(year: 2026, month: 10, day: 22))
}
