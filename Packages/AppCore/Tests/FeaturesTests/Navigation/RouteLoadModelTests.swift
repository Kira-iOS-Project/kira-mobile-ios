import APIClient
import Testing

@testable import Features

@MainActor
@Suite("RouteLoadModel")
struct RouteLoadModelTests {
    private struct Plain: Error {}

    /** Answers its calls in turn: each value, nil, or an error. */
    private actor Answers {
        private var queue: [Result<Int?, any Error>]
        private(set) var calls = 0

        init(_ queue: [Result<Int?, any Error>]) { self.queue = queue }

        func next() throws -> Int? {
            calls += 1
            return try queue.removeFirst().get()
        }
    }

    @Test("loads once as the screen shows, and keeps the value when it comes back")
    func loadsOnce() async {
        let answers = Answers([.success(7)])
        let model = RouteLoadModel { try await answers.next() }
        #expect(model.phase.value == nil)
        await model.loadIfNeeded()
        await model.loadIfNeeded()
        #expect(model.phase.value == 7)
        #expect(await answers.calls == 1)
    }

    @Test("nothing to show is empty; a problem shows until Coba Lagi loads again")
    func emptyAndFailed() async {
        let empty = RouteLoadModel<Int> { nil }
        await empty.load()
        guard case .empty = empty.phase else {
            Issue.record("not empty")
            return
        }
        let answers = Answers([.failure(AppProblem(code: "INTERNAL_ERROR")), .failure(Plain()), .success(3)])
        let model = RouteLoadModel { try await answers.next() }
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("not failed")
            return
        }
        #expect(problem.code == "INTERNAL_ERROR")
        await model.load()
        guard case .failed(let generic) = model.phase else {
            Issue.record("not failed")
            return
        }
        #expect(generic == AppProblem())
        await model.load()
        #expect(model.phase.value == 3)
    }
}
