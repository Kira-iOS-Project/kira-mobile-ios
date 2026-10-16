import APIClient
import Domain
import Foundation
import Observation

/**
 Impor Mutasi (CAT-11, 11b): the person picks one CSV file, it is read and checked on the device,
 and "Lanjut Tinjau" sends the parsed rows (account numbers masked, a category suggested each).
 The file is read where it lies and never copied, so nothing of it stays behind.
 */
@MainActor
@Observable
package final class StatementImportModel {
    /** Where the first step is. */
    package enum Phase: Hashable, Sendable {
        /** No file yet: the picker. */
        case choosing
        /** A file passed every check: its card and "Lanjut Tinjau". */
        case read(StatementFile)
        /** A file failed a check: the reason and "Pilih File Lain". */
        case invalid(BankStatementError)
    }

    /** A file that was read, with what its card shows. */
    package struct StatementFile: Hashable, Sendable {
        /** The file's name, as the picker gave it. */
        package let name: String
        /** The file's size in bytes. */
        package let byteCount: Int
        /** The rows that passed every check. */
        package let statement: BankStatement
    }

    /** Where the step is. */
    package private(set) var phase = Phase.choosing
    /** Whether the rows are being sent. */
    package private(set) var isUploading = false
    /** Why sending the rows failed, shown under the file until the next try. */
    package private(set) var uploadProblem: AppProblem?
    /** The stored import once the rows are sent; the review screen opens on it. */
    package var preview: ImportPreview?

    private let service: any HistoryService

    /** The first step, waiting for a file. */
    package init(service: any HistoryService) {
        self.service = service
    }

    /** Reads the file the picker returned, inside its security scope. */
    package func choose(fileAt url: URL) {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer { if isScoped { url.stopAccessingSecurityScopedResource() } }
        do {
            read(try Data(contentsOf: url), fileName: url.lastPathComponent)
        } catch {
            phase = .invalid(.notText)
        }
    }

    /** Checks the file's contents. */
    package func read(_ data: Data, fileName: String) {
        uploadProblem = nil
        do {
            let statement = try BankStatementParser.parse(data)
            phase = .read(StatementFile(name: fileName, byteCount: data.count, statement: statement))
        } catch {
            phase = .invalid(error)
        }
    }

    /** The picker could not hand a file over. */
    package func pickerFailed() {
        phase = .invalid(.notText)
    }

    /** Sends the parsed rows and opens the review on the stored import. */
    package func continueToReview() async {
        guard case .read(let file) = phase, !isUploading else { return }
        isUploading = true
        defer { isUploading = false }
        uploadProblem = nil
        do {
            preview = try await service.upload(
                ImportUpload(statement: file.statement, fileName: file.name, fileSize: file.byteCount))
        } catch {
            uploadProblem = historyProblem(error)
        }
    }
}
