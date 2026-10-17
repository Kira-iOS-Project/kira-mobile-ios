import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LivePortfolioService")
struct LivePortfolioServiceTests {
    @Test("GET /assets becomes the portfolio; POST and PATCH /assets send the form and return the asset")
    func calls() async throws {
        let (api, transport) = KiraAPI.routed([
            "GET /api/assets": ok(portfolioJSON),
            "POST /api/assets": ok(assetJSON, status: 201),
            "PATCH /api/assets/\(assetId)": ok(assetJSON),
        ])
        let service = LivePortfolioService(api: api)
        let portfolio = try await service.portfolio()
        #expect(portfolio.assets.map(\.assetClass) == [.gold] && portfolio.total == 2_400_000)
        #expect(portfolio.debtToAsset == DebtToAssetImpact(percent: 32, points: 80, band: .healthy))
        let input = AssetInput(assetClass: .gold, name: "Emas Batangan", value: 2_400_000, valuedOn: day)
        #expect(try await service.addAsset(input).id == assetId)
        #expect(try await service.updateAsset(id: assetId, input).name == "Emas Batangan")
        let sent = await transport.sent
        #expect(sent.map(\.route) == ["GET /api/assets", "POST /api/assets", "PATCH /api/assets/\(assetId)"])
        #expect(sent[1].json["assetClass"] == .string("gold") && sent[1].json["valuedOn"] == .string("2026-10-01"))
        #expect(sent[2].json["value"] == .number(2_400_000))
    }

    @Test("a plan without Portofolio and a gone asset are thrown as their problems")
    func failures() async {
        let (api, _) = KiraAPI.routed([
            "GET /api/assets": problem("PLAN_FEATURE_UNAVAILABLE", status: 403),
            "PATCH /api/assets/gone": problem("ASSET_NOT_FOUND", status: 404),
        ])
        let service = LivePortfolioService(api: api)
        await #expect(throws: AppProblem.self) { try await service.portfolio() }
        let input = AssetInput(assetClass: .gold, name: "E", value: 1, valuedOn: day)
        await #expect(throws: AppProblem.self) { try await service.updateAsset(id: "gone", input) }
    }
}

private let day = CalendarDay(year: 2026, month: 10, day: 1)
private let assetId = "0b9c1a52-6f1e-4c2a-9a55-2f1d1c3e4b5a"
private let assetJSON =
    #"{"id":"\#(assetId)","assetClass":"gold","name":"Emas Batangan","value":2400000,"#
    + #""valuedOn":"2026-10-01"}"#
private let portfolioJSON =
    #"{"assets":[\#(assetJSON)],"total":2400000,"updatedOn":"2026-10-01","#
    + #""debtToAsset":{"percent":32,"points":80,"band":"healthy"}}"#
