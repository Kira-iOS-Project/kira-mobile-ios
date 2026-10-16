/** ScoreBand: the three bands of the Kira Score and their share of the meter. */
import Testing

@testable import Domain

@Suite("ScoreBand names the band of a Kira Score")
struct ScoreBandTests {
    @Test(
        "Vulnerable 0–39, Coping 40–79, Healthy 80–100, clamped outside the scale",
        arguments: [
            (-10, ScoreBand.vulnerable), (0, .vulnerable), (39, .vulnerable),
            (40, .coping), (66, .coping), (79, .coping),
            (80, .healthy), (100, .healthy), (120, .healthy),
        ])
    func band(_ score: Int, _ band: ScoreBand) {
        #expect(ScoreBand(score: score) == band)
    }

    @Test("the bands run left to right on the meter and share it 40, 40 and 20")
    func spans() {
        #expect(ScoreBand.allCases == [.vulnerable, .coping, .healthy])
        #expect(ScoreBand.allCases.map(\.span) == [40, 40, 20])
    }
}
