import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("StatementImportModel")
struct StatementImportModelTests {
    private let service = FakeHistoryService()

    @Test("reads a picked file and shows its card")
    func readsFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("mutasi-\(UUID().uuidString).csv")
        try Data(StatementTemplate.text.utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let model = StatementImportModel(service: service)
        model.choose(fileAt: url)
        guard case .read(let file) = model.phase else {
            Issue.record("expected read")
            return
        }
        #expect(file.name == url.lastPathComponent)
        #expect(file.byteCount == StatementTemplate.text.utf8.count)
        #expect(file.statement.rows.count == 3)
    }

    @Test("says why a file cannot be read")
    func refuses() {
        let model = StatementImportModel(service: service)
        model.choose(fileAt: URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString).csv"))
        #expect(model.phase == .invalid(.notText))
        model.read(Data("a,b,c\n".utf8), fileName: "x.csv")
        #expect(model.phase == .invalid(.wrongHeader))
        model.pickerFailed()
        #expect(model.phase == .invalid(.notText))
    }

    @Test("sends the parsed rows and opens the review; a refusal shows its problem")
    func upload() async throws {
        let model = StatementImportModel(service: service)
        await model.continueToReview()
        #expect(await service.uploads.isEmpty)
        model.read(Data(StatementTemplate.text.utf8), fileName: "mutasi-september.csv")
        await service.configure { $0.failing = [.upload] }
        await model.continueToReview()
        #expect(model.uploadProblem == FakeHistoryService.problem)
        #expect(model.preview == nil && !model.isUploading)
        await service.configure { $0.failing = [] }
        await model.continueToReview()
        #expect(model.uploadProblem == nil)
        #expect(model.preview == Sample.preview)
        let upload = try #require(await service.uploads.last)
        #expect(upload.fileName == "mutasi-september.csv" && upload.rows.count == 3)
    }
}

@MainActor
@Suite("ImportReviewModel")
struct ImportReviewModelTests {
    private let service = FakeHistoryService()

    private func model(_ preview: ImportPreview = Sample.preview) -> ImportReviewModel {
        ImportReviewModel(preview: preview, fileName: "mutasi-september.csv", service: service)
    }

    @Test("leaves likely duplicates unchecked and the rest checked")
    func split() {
        let model = model()
        #expect(model.duplicates.map(\.id) == ["r1"])
        #expect(model.ready.map(\.id) == ["r2", "r3"])
        #expect(model.checkedCount == 2)
        #expect(!model.isChecked(Sample.preview.rows[0]))
        #expect(model.fileName == "mutasi-september.csv")
    }

    @Test("folds the ready rows after five until opened")
    func folding() {
        let rows = (1...8).map { Sample.row("x\($0)", "Kopi", 1_000, .coffee, duplicate: false) }
        let model = model(ImportPreview(id: "imp", dateFrom: Sample.today, dateTo: Sample.today, rows: rows))
        #expect(model.visibleReady.count == ImportReviewModel.readyPreviewCount)
        #expect(model.hiddenReady.map(\.id) == ["x6", "x7", "x8"])
        model.showAllReady()
        #expect(model.visibleReady.count == 8 && model.hiddenReady.isEmpty)
    }

    @Test("checks rows, changes categories, and saves the checked rows with them")
    func save() async throws {
        let model = model()
        let duplicate = Sample.preview.rows[0]
        model.toggle(duplicate)
        model.toggle(Sample.preview.rows[2])
        model.editingRowId = duplicate.id
        #expect(model.editingRow == duplicate)
        model.setCategory(.food, for: duplicate)
        #expect(model.category(of: duplicate) == .food)
        await model.save()
        #expect(
            await service.commits == [
                [ImportCommitRow(id: "r1", category: .food), ImportCommitRow(id: "r2", category: .shopping)]
            ])
        #expect(model.dialog == .saved(ImportCommitResult(savedCount: 2, skippedCount: 1)))
        model.dialogClosed()
        #expect(model.isFinished && model.dialog == nil)
    }

    @Test("a failed save offers Coba Lagi; nothing checked sends nothing")
    func failure() async {
        await service.configure { $0.failing = [.commit] }
        let model = model()
        await model.save()
        #expect(model.dialog == .failed && model.shownDialog == .failed)
        model.dialogClosed()
        #expect(!model.isFinished)
        for row in model.ready { model.toggle(row) }
        await model.save()
        #expect(await service.commits.count == 1)
    }
}
