import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** 17 October 2026, 10:00 WIB. */
private let now = Date(timeIntervalSince1970: 1_792_220_400)

@MainActor
@Suite("AssetFormModel")
struct AssetFormModelTests {
    private let refused = AppProblem(code: ProblemCode.planFeatureUnavailable.rawValue)

    private func form(_ service: FakePortfolioService, id: String? = nil) -> AssetFormModel {
        AssetFormModel(service: service, assetId: id, now: { now })
    }

    private func fill(_ model: AssetFormModel) {
        model.select(.gold)
        model.name = "  Emas Batangan "
        model.valueText = "2.400.000"
    }

    @Test("Tambah Aset starts empty on today; Simpan names every missing field until each is fixed")
    func checks() async {
        let service = FakePortfolioService()
        let model = form(service)
        #expect(model.phase.value != nil && !model.isUpdate && model.assetClass == nil && model.value == nil)
        #expect(CalendarDay(model.valuedOn) == CalendarDay(now) && model.latestDay == now)
        #expect(AssetFormModel(service: service).latestDay.timeIntervalSinceNow < 1)
        await model.load()
        await model.save()
        #expect(model.issues == [.noClass, .noName, .noValue])
        #expect(model.issue(in: .assetClass) == .noClass && model.issue(in: .day) == nil)
        model.select(.gold)
        #expect(model.issue(in: .assetClass) == nil && model.issue(in: .name) == .noName)
        model.valuedOn = now.addingTimeInterval(86_400 * 2)
        await model.save()
        #expect(model.issue(in: .value) == .noValue && model.issue(in: .day) == .futureDay)
        #expect(await service.sent.isEmpty && !model.showsSaved)
    }

    @Test("a saved asset sends the trimmed name and whole rupiah, shows Aset Tersimpan, and Selesai closes")
    func saves() async throws {
        let service = FakePortfolioService()
        let model = form(service)
        fill(model)
        await model.save()
        #expect(model.showsSaved && !model.isSaving)
        let sent = try #require(await service.sent.first)
        #expect(sent.id == nil)
        let expected = AssetInput(
            assetClass: .gold, name: "Emas Batangan", value: 2_400_000, valuedOn: CalendarDay(now))
        #expect(sent.input == expected)
        model.finish()
        #expect(!model.showsSaved && model.isClosed)
    }

    @Test("a failed save keeps every field, and Coba Lagi sends them again")
    func retries() async {
        let service = FakePortfolioService(saves: [.failure(.connectionLost)])
        let model = form(service)
        fill(model)
        await model.save()
        #expect(model.failure == .connectionLost && !model.showsSaved && model.name == "  Emas Batangan ")
        await model.retry()
        #expect(model.failure == nil && model.showsSaved)
        #expect(await service.sent.count == 2)
    }

    @Test("a plan without Portofolio refuses the save: Lihat Paket instead of the failure dialog")
    func refusedSave() async {
        let model = form(FakePortfolioService(saves: [.failure(refused)]))
        fill(model)
        await model.save()
        #expect(model.needsPlan && model.failure == nil)
    }

    @Test("the update form fills in the asset and sends its id")
    func updates() async throws {
        let service = FakePortfolioService()
        let model = form(service, id: "gold")
        #expect(model.isUpdate && model.phase.value == nil)
        await model.load()
        #expect(model.assetClass == .gold && model.name == "Emas Batangan" && model.valueText == "2.400.000")
        #expect(CalendarDay(model.valuedOn) == FakePortfolioService.day)
        model.name = "Emas Antam"
        await model.load()
        #expect(model.name == "Emas Antam")
        await model.save()
        #expect(try #require(await service.sent.first).id == "gold")
    }

    @Test("an asset that is gone, a lost connection or a refused plan fails the update form")
    func loadFailures() async {
        let gone = form(FakePortfolioService(), id: "gone")
        await gone.load()
        guard case .failed(let problem) = gone.phase else { return #expect(Bool(false)) }
        #expect(problem.code == "ASSET_NOT_FOUND" && !gone.loadNeedsPlan)
        let lost = form(FakePortfolioService(portfolios: [.failure(.connectionLost)]), id: "gold")
        await lost.load()
        guard case .failed(let lostProblem) = lost.phase else { return #expect(Bool(false)) }
        #expect(lostProblem.isConnectionLoss)
        let plan = form(FakePortfolioService(portfolios: [.failure(refused)]), id: "gold")
        await plan.load()
        #expect(plan.loadNeedsPlan)
        #expect(!form(FakePortfolioService()).loadNeedsPlan)
    }
}
