import Domain

/**
 Tambah and Ubah Tagihan's writes (tag Tagihan): a new bill, its new figures, and its deletion; each
 returns the bill's id or throws the problem the API answers with (404 `BILL_NOT_FOUND`, 404
 `BILL_DEBT_NOT_FOUND`, 422 `VALIDATION_FAILED`).
 */
extension KiraAPI {
    /** A new bill (`POST /api/bills`). */
    package func createBill(_ draft: BillDraft) async throws -> String {
        try await client.createBill(body: .json(.init(draft))).billId()
    }

    /**
     The bill of `id` with the draft's figures (`PATCH /api/bills/{id}`). Every field is sent; a
     cicilan's debt account goes with it, and a nil one is left out (the spec has no null to unlink).
     */
    package func updateBill(id: String, _ draft: BillDraft) async throws -> String {
        try await client.updateBill(path: .init(id: id), body: .json(.init(draft))).billId()
    }

    /** The bill of `id`, gone (`DELETE /api/bills/{id}`). */
    package func deleteBill(id: String) async throws {
        try await client.deleteBill(path: .init(id: id)).deleted()
    }
}

extension Components.Schemas.CreateBill {
    init(_ draft: BillDraft) {
        self.init(
            name: draft.name, amount: draft.amount,
            category: CategoryPayload(draft.category), repeats: RepeatsPayload(draft.repeats),
            dueOn: draft.dueOn.iso, debtId: draft.debtId)
    }
}

extension Components.Schemas.CreateBill.CategoryPayload {
    /** The form's tile as the API names it. */
    init(_ category: BillCategory) {
        switch category {
        case .bills: self = .bills
        case .entertainment: self = .entertainment
        case .health: self = .health
        case .other: self = .otherExpense
        }
    }
}

extension Components.Schemas.CreateBill.RepeatsPayload {
    /** How often, as the API names it. */
    init(_ repeats: BillRepeat) {
        switch repeats {
        case .once: self = .once
        case .monthly: self = .monthly
        case .yearly: self = .yearly
        }
    }
}

extension Components.Schemas.UpdateBill {
    init(_ draft: BillDraft) {
        self.init(
            name: draft.name, amount: draft.amount, category: CategoryPayload(rawValue: draft.category.rawValue),
            repeats: RepeatsPayload(rawValue: draft.repeats.rawValue), dueOn: draft.dueOn.iso, debtId: draft.debtId)
    }
}

extension Operations.CreateBill.Output {
    func billId() throws -> String {
        switch self {
        case .created(let response): return try response.body.json.id
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UpdateBill.Output {
    func billId() throws -> String {
        switch self {
        case .ok(let response): return try response.body.json.id
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.DeleteBill.Output {
    func deleted() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
