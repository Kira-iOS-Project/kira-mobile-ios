/** Tagihan & Cicilan on the board's bills, or with none, or failing, for previews and the launcher. */
import APIClient
import Domain
import Features

actor PreviewBillService: BillService {
    private let overview: BillOverview?

    /** The board's bills; nil makes every load fail as offline. */
    init(overview: BillOverview? = BillsPreviewData.board) {
        self.overview = overview
    }

    func bills() async throws -> BillOverview {
        try await Task.sleep(for: .milliseconds(180))
        guard let overview else { throw AppProblem(code: "CONNECTION_LOST") }
        return overview
    }
}
