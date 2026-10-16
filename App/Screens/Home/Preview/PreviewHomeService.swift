/**
 Beranda's API answered with the canvas's sample data, so the screen runs in previews and in the
 app before the integrator wires the generated client.
 */
import Domain
import Features
import SwiftUI

nonisolated struct PreviewHomeService: HomeService {
    let overview: HomeOverview

    init(_ overview: HomeOverview = .sampleOverview) {
        self.overview = overview
    }

    func home() throws -> HomeOverview { overview }

    func setHideBalances(_: Bool) throws {}
}

#if DEBUG
    #Preview("Beranda") {
        NavigationStack { HomeScreen(service: PreviewHomeService()) { _ in } }
    }

    #Preview("Pengguna Baru") {
        NavigationStack { HomeScreen(service: PreviewHomeService(.sampleFirstSteps)) { _ in } }
    }

    #Preview("Keluar dari Utang") {
        NavigationStack { HomeScreen(service: PreviewHomeService(.sampleDebtPlan)) { _ in } }
    }
#endif
