import Foundation

/** The signed-in person: profile, settings, consents, data export and deletion. */
extension KiraAPI {
    /** The person, their plan, usage and payday period (`GET /api/me`). */
    package func getMe() async throws -> MeDTO {
        try await client.getMe().profile()
    }

    /** Changes the given settings and returns the person (`PATCH /api/me`). */
    package func updateMe(_ changes: [MeChangeDTO]) async throws -> MeDTO {
        var update = Components.Schemas.MeUpdate()
        for change in changes {
            switch change {
            case .focus(let focus): update.focus = try bridged(focus) as Components.Schemas.MeUpdate.FocusPayload
            case .hideBalances(let hidden): update.hideBalances = hidden
            case .payday(let payday): update.payday = .init(day: payday.day, endOfMonth: payday.endOfMonth)
            }
        }
        return try await client.updateMe(body: .json(update)).profile()
    }

    /** The consents in force (`GET /api/me/consents`). */
    package func getConsents() async throws -> ConsentsDTO {
        try await client.getConsents().consents()
    }

    /** Records the two optional consents (`PUT /api/me/consents`); the first call completes sign-up. */
    package func updateConsents(aiProcessing: Bool, weeklySummary: Bool) async throws -> ConsentsDTO {
        let body = Components.Schemas.ConsentsUpdate(aiProcessing: aiProcessing, weeklySummary: weeklySummary)
        return try await client.updateConsents(body: .json(body)).consents()
    }

    /** The transactions as a CSV file, Indonesian header row (`GET /api/me/export`). */
    package func exportData() async throws -> Data {
        try await client.exportData().csv()
    }

    /** Emails the same CSV to the account's address (`POST /api/me/export/email`). */
    package func emailDataExport() async throws {
        try await client.emailDataExport().done()
    }

    /** Deletes the account for good (`POST /api/me/deletion`); `confirmation` must read HAPUS. */
    package func deleteAccount(confirmation: String) async throws {
        try await client.deleteAccount(body: .json(.init(confirmation: confirmation))).done()
    }
}
