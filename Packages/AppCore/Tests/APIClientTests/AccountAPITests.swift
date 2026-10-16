/** The account calls: the person, settings, consents, export and deletion. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let accountUsageJSON = #"""
    {"aiMessages":{"used":3,"limit":30},"receipts":{"used":0,"limit":10},\#
    "voiceSeconds":{"used":0,"limit":0},"resetsOn":"2026-11-01"}
    """#

private let meJSON = #"""
    {"id":"u-1","email":"dinda@email.com","displayName":"Dinda","focus":"track_spending",\#
    "payday":{"day":25,"endOfMonth":false},"hideBalances":false,"debtEmergencyActive":false,"consented":true,\#
    "healthCheckCompleted":true,"plan":{"id":"plus","source":"scholarship","renewsOn":"2027-01-16"},\#
    "usage":\#(accountUsageJSON),"period":{"start":"2026-09-25","end":"2026-10-24",\#
    "nextPayday":"2026-10-25","daysUntilPayday":9},\#
    "lastCategories":{"expense":"coffee","income":null},"debtAccountCount":2,\#
    "aiEnabled":true,"weeklySummaryEnabled":false,"debtEmergencyActive":false}
    """#

private let consentsJSON = #"""
    {"policyVersion":"2026-10-15","items":[\#
    {"purpose":"core","granted":true,"decidedAt":"2026-10-16T05:00:00.000Z"},\#
    {"purpose":"weekly_summary","granted":false,"decidedAt":null}]}
    """#

private struct MeUpdateBody: Decodable {
    struct PaydayBody: Decodable { let day: Int?, endOfMonth: Bool }
    let focus: String?
    let payday: PaydayBody?
}

private struct HiddenBody: Decodable { let hideBalances: Bool }

private struct ConsentsBody: Decodable { let aiProcessing: Bool, weeklySummary: Bool }
private struct DeletionBody: Decodable { let confirmation: String }

@Suite("AccountAPI")
struct AccountAPITests {
    @Test("reads the person with their plan, usage, period and last categories")
    func readsMe() async throws {
        let (api, transport) = KiraAPI.canned(json: meJSON)
        let profile = try await api.getMe()
        #expect(profile.displayName == "Dinda" && profile.plan == CurrentPlanDTO(id: .plus))
        #expect(profile.period.daysUntilPayday == 9)
        #expect(profile.usage.aiMessages.used == 3 && profile.lastExpenseCategory == .coffee)
        #expect(profile.lastIncomeCategory == nil && profile.debtAccountCount == 2)
        #expect(profile.id == "u-1" && profile.email == "dinda@email.com" && !profile.hideBalances)
        #expect(profile.consented && profile.healthCheckCompleted && profile.aiEnabled && !profile.weeklySummaryEnabled)
        #expect(try #require(await transport.request).path.hasSuffix("me"))
    }

    @Test("sends only the settings that change")
    func updatesMe() async throws {
        let (api, transport) = KiraAPI.canned(json: meJSON)
        _ = try await api.updateMe([
            .focus(.debtFree), .hideBalances(true), .payday(PaydayDTO(day: nil, endOfMonth: true)),
        ])
        let request = try #require(await transport.request)
        let body = try request.decoded(MeUpdateBody.self)
        #expect(request.method == .patch && body.focus == "debt_free")
        #expect(try request.decoded(HiddenBody.self).hideBalances)
        #expect(body.payday?.endOfMonth == true && body.payday?.day == nil)

        let (onlyFocus, sent) = KiraAPI.canned(json: meJSON)
        _ = try await onlyFocus.updateMe([.focus(.trackSpending)])
        let sentRequest = try #require(await sent.request)
        #expect(throws: DecodingError.self) { try sentRequest.decoded(HiddenBody.self) }
    }

    @Test("reads and records consents")
    func consents() async throws {
        let (api, transport) = KiraAPI.canned(json: consentsJSON)
        let read = try await api.getConsents()
        #expect(read.items.count == 2 && read.items[0].purpose == .core)
        #expect(read.items[1] == ConsentDTO(purpose: .weeklySummary, granted: false))
        let saved = try await api.updateConsents(aiProcessing: true, weeklySummary: false)
        #expect(saved == read)
        let body = try #require(await transport.request).decoded(ConsentsBody.self)
        #expect(body.aiProcessing && !body.weeklySummary)
    }

    @Test("downloads the CSV export")
    func exports() async throws {
        let csv = "tanggal,jam,jenis\n2026-10-15,12.41,pengeluaran\n"
        let (api, _) = KiraAPI.canned(json: csv, contentType: "text/csv")
        #expect(try await api.exportData() == Data(csv.utf8))
    }

    @Test("emails the export and deletes the account")
    func emailsAndDeletes() async throws {
        let (mailer, mailed) = KiraAPI.canned(status: 202)
        try await mailer.emailDataExport()
        #expect(try #require(await mailed.request).path.hasSuffix("export/email"))
        let (api, transport) = KiraAPI.canned(status: 204)
        try await api.deleteAccount(confirmation: "hapus")
        #expect(try #require(await transport.request).decoded(DeletionBody.self).confirmation == "hapus")
    }

    @Test("throws every problem the account routes answer")
    func problems() async {
        await expectProblems([401]) { _ = try await $0.getMe() }
        await expectProblems([401, 422]) { _ = try await $0.updateMe([]) }
        await expectProblems([401]) { _ = try await $0.getConsents() }
        await expectProblems([401, 422]) { _ = try await $0.updateConsents(aiProcessing: true, weeklySummary: true) }
        await expectProblems([401]) { _ = try await $0.exportData() }
        await expectProblems([401, 429, 503]) { try await $0.emailDataExport() }
        await expectProblems([401, 422]) { try await $0.deleteAccount(confirmation: "x") }
    }
}
