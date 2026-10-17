import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Hapus Tujuan on Detail Tujuan: asked first, deleted once, closed on "Tujuan Dihapus". */
@MainActor
@Suite("GoalDetailModel delete")
struct GoalDetailModelDeleteTests {
    private let service = FakeGoalService()

    @Test("asks first; the confirmation deletes once and closing Tujuan Dihapus leaves the screen")
    func deletes() async {
        let model = GoalDetailModel(id: "goal-1", service: service)
        model.requestDelete()
        #expect(model.deleteDialog == .confirm && model.shownDeleteDialog == .confirm)
        #expect(await service.deleted.isEmpty)
        async let first: Void = model.confirmDelete()
        async let second: Void = model.confirmDelete()
        _ = await (first, second)
        #expect(await service.deleted == ["goal-1"])
        #expect(model.deleteDialog == .deleted && !model.isClosed)
        model.deleteDialogClosed()
        #expect(model.isClosed && model.deleteDialog == nil && model.shownDeleteDialog == .deleted)
    }

    @Test("Batal closes the question and keeps the goal and the screen")
    func cancels() async {
        let model = GoalDetailModel(id: "goal-1", service: service)
        model.requestDelete()
        model.deleteDialogClosed()
        #expect(model.deleteDialog == nil && !model.isClosed)
        #expect(await service.deleted.isEmpty)
    }

    @Test("a refused or lost delete shows its problem and Coba Lagi deletes; a gone goal counts as deleted")
    func fails() async {
        await service.configure { $0.failing[.delete] = URLError(.notConnectedToInternet) }
        let model = GoalDetailModel(id: "goal-1", service: service)
        await model.confirmDelete()
        #expect(model.deleteDialog == .failed(AppProblem(URLError(.notConnectedToInternet))))
        model.deleteDialogClosed()
        #expect(!model.isClosed)
        await service.configure { $0.failing[.delete] = AppProblem(code: "GOAL_NOT_FOUND", requestId: "r") }
        await model.confirmDelete()
        #expect(model.deleteDialog == .deleted)
    }
}
