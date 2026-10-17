/**
 Riwayat Kira Score in the states the board's sample does not show: one month of data (no trend,
 no changes), none before the health check, or a load the API refused. The score and indicators
 answer as PreviewScoreService does.
 */
#if DEBUG
    import APIClient
    import Domain
    import Features

    struct StubScoreHistoryService: ScoreService {
        var history: ScoreHistory?
        var problem: AppProblem?

        init(history: ScoreHistory?) {
            self.history = history
        }

        init(problem: AppProblem) {
            self.problem = problem
        }

        func score() async throws -> ScoreReport? {
            try await PreviewScoreService().score()
        }

        func indicator(_ key: IndicatorKey) async throws -> IndicatorDetail {
            try await PreviewScoreService().indicator(key)
        }

        func history(_: ScoreHistoryRange) throws -> ScoreHistory? {
            if let problem { throw problem }
            return history
        }

        func includesHistory() -> Bool { true }
    }

    extension ScoreHistory {
        /** The first check only, October 2026: 66, Bertahan, with nothing to compare against yet. */
        static let oneMonth = ScoreHistory(
            score: 66, band: .coping, deltaFromPrevious: nil, previousMonth: nil,
            points: [ScoreHistoryPoint(month: CalendarDay(year: 2026, month: 10, day: 1), score: 66)],
            changes: [], unchangedCount: 6)
    }
#endif
