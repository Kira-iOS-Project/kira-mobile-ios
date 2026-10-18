import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** OJK's list in a test: answers what the test sets and records each query. */
private actor FakeLegalityService: LegalityService {
    var answer: Result<LegalitySearch, any Error> = .success(
        LegalitySearch(results: [], asOf: CalendarDay(year: 2026, month: 7, day: 31), listed: 94))
    private(set) var queries: [String] = []

    func set(_ answer: Result<LegalitySearch, any Error>) { self.answer = answer }

    func search(_ query: String) throws -> LegalitySearch {
        queries.append(query)
        return try answer.get()
    }
}

@MainActor
@Suite("LegalityCheckModel")
struct LegalityCheckModelTests {
    private let service = FakeLegalityService()

    @Test("searches the trimmed words once, and a change of the words clears the answer")
    func searches() async {
        let model = LegalityCheckModel(service: service)
        model.query = "  julo "
        async let first: Void = model.search()
        async let second: Void = model.search()
        _ = await (first, second)
        #expect(await service.queries == ["julo"])
        guard case .answered(let query, let search) = model.phase else {
            Issue.record("no answer")
            return
        }
        #expect(query == "julo" && search.results.isEmpty && search.listed == 94)
        #expect(model.showsResult)
        model.resultClosed()
        #expect(!model.showsResult)
        model.query = "  julo "
        #expect(model.phase != .idle)
        model.query = "julo teknologi"
        #expect(model.phase == .idle)
    }

    @Test("fewer than two characters sends nothing")
    func tooShort() async {
        let model = LegalityCheckModel(service: service)
        model.query = " a "
        #expect(!model.canSearch)
        await model.search()
        let queries = await service.queries
        #expect(model.phase == .idle && queries.isEmpty)
    }

    @Test("a failed search shows its problem, a lost connection as such")
    func fails() async {
        await service.set(.failure(URLError(.notConnectedToInternet)))
        let model = LegalityCheckModel(service: service)
        model.query = "danamas"
        await model.search()
        #expect(model.phase == .failed(AppProblem(URLError(.notConnectedToInternet))))
        #expect(model.showsResult)
    }
}
