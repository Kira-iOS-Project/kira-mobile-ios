/** GET, POST and PATCH /assets through a canned transport. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("PortfolioAPI")
struct PortfolioAPITests {
    private let input = AssetInput(
        assetClass: .mutualFund, name: "Reksa Dana Pasar Uang", value: 3_000_000,
        valuedOn: CalendarDay(year: 2026, month: 10, day: 1))

    @Test("reads a portfolio before the health check: no update day and no indicator")
    func readsEmpty() async throws {
        let (api, transport) = KiraAPI.canned(
            json: #"{"assets":[],"total":0,"updatedOn":null,"debtToAsset":null}"#)
        let portfolio = try await api.listAssets()
        #expect(portfolio.assets.isEmpty && portfolio.updatedOn == nil && portfolio.debtToAsset == nil)
        let sent = try #require(await transport.request)
        #expect(sent.method == .get && sent.path.hasSuffix("/assets"))
    }

    @Test("sends every figure of the form, on create and on update")
    func sends() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: assetJSON)
        let created = try await api.createAsset(input)
        #expect(created.assetClass == .mutualFund && created.valuedOn == CalendarDay(year: 2026, month: 10, day: 1))
        let body = try #require(await transport.request).decoded(SentAsset.self)
        #expect(
            body
                == SentAsset(
                    assetClass: "mutual_fund", name: "Reksa Dana Pasar Uang", value: 3_000_000, valuedOn: "2026-10-01"))
        let (patch, patched) = KiraAPI.canned(json: assetJSON)
        _ = try await patch.updateAsset(id: "a1", input)
        let request = try #require(await patched.request)
        #expect(request.method == .patch && request.path.hasSuffix("/assets/a1"))
        #expect(try request.decoded(SentAsset.self).name == "Reksa Dana Pasar Uang")
    }

    @Test("a day it cannot read is a problem without a code")
    func badDays() async {
        let (portfolio, _) = KiraAPI.canned(
            json: #"{"assets":[],"total":0,"updatedOn":"1 Oktober","debtToAsset":null}"#)
        await #expect(throws: AppProblem()) { try await portfolio.listAssets() }
        let badAsset = assetJSON.replacingOccurrences(of: "2026-10-01", with: "kemarin")
        let (asset, _) = KiraAPI.canned(status: 201, json: badAsset)
        await #expect(throws: AppProblem()) { try await asset.createAsset(input) }
    }

    @Test(
        "throws the problem of a failure",
        arguments: failureCases("listAssets", statuses: [401, 403]) { _ = try await $0.listAssets() }
            + failureCases("createAsset", statuses: [401, 403, 422]) { api in
                _ = try await api.createAsset(sampleInput)
            }
            + failureCases("updateAsset", statuses: [401, 403, 404, 422]) { api in
                _ = try await api.updateAsset(id: "a1", sampleInput)
            })
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem) {
            try await failure.call(api)
        }
    }
}

/** The body of POST and PATCH /assets. */
private struct SentAsset: Decodable, Equatable {
    let assetClass: String
    let name: String
    let value: Int
    let valuedOn: String
}

private let sampleInput = AssetInput(
    assetClass: .gold, name: "Emas", value: 1, valuedOn: CalendarDay(year: 2026, month: 10, day: 1))

private let assetJSON =
    #"{"id":"a1","assetClass":"mutual_fund","name":"Reksa Dana Pasar Uang","value":3000000,"valuedOn":"2026-10-01"}"#
