// ScoreBand: the three bands of the Kira Score and their share of the meter.
import Testing

@testable import Domain

@Suite("ScoreBand names the band of a Kira Score")
struct ScoreBandTests {
    @Test(
        "Rentan 0–39, Bertahan 40–79, Sehat 80–100, clamped outside the scale",
        arguments: [
            (-10, ScoreBand.rentan), (0, .rentan), (39, .rentan),
            (40, .bertahan), (66, .bertahan), (79, .bertahan),
            (80, .sehat), (100, .sehat), (120, .sehat),
        ])
    func band(_ score: Int, _ band: ScoreBand) {
        #expect(ScoreBand(score: score) == band)
    }

    @Test("the bands run left to right on the meter and share it 40, 40 and 20")
    func spans() {
        #expect(ScoreBand.allCases == [.rentan, .bertahan, .sehat])
        #expect(ScoreBand.allCases.map(\.span) == [40, 40, 20])
    }
}
