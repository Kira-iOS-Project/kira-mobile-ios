import APIClient
import Domain

@testable import Features

/** Tambah and Ubah Tagihan's writes, recording each draft and failing the calls a test names. */
actor FakeBillEditorService: BillEditorService {
    enum Call: Hashable, Sendable {
        case create, update, delete
    }

    /** The calls that fail, and with what; each failure is used once. */
    var failing: [Call: [any Error]] = [:]
    private(set) var created: [BillDraft] = []
    private(set) var updated: [String: BillDraft] = [:]
    private(set) var deleted: [String] = []

    func configure(_ change: @Sendable (isolated FakeBillEditorService) -> Void) { change(self) }

    func createBill(_ draft: BillDraft) throws -> String {
        try check(.create)
        created.append(draft)
        return "bill-\(created.count)"
    }

    func updateBill(id: String, _ draft: BillDraft) throws -> String {
        try check(.update)
        updated[id] = draft
        return id
    }

    func deleteBill(id: String) throws {
        try check(.delete)
        deleted.append(id)
    }

    private func check(_ call: Call) throws {
        guard var errors = failing[call], !errors.isEmpty else { return }
        let error = errors.removeFirst()
        failing[call] = errors
        throw error
    }
}
