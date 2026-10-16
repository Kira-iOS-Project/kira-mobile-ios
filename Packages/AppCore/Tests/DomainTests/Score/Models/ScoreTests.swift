/** Score clamps to the 0–100 scale and names its band. */
import Testing

@testable import Domain

@Suite("Score keeps a value on the 0–100 scale")
struct ScoreTests {
    @Test(
        "the value is clamped to 0...100",
        arguments: [(-5, 0), (0, 0), (66, 66), (100, 100), (140, 100)])
    func clamped(_ raw: Int, _ value: Int) {
        #expect(Score(raw).value == value)
    }

    @Test("the band and the fraction follow the clamped value")
    func bandAndFraction() {
        #expect(Score(66).band == .coping)
        #expect(Score(66).fraction == 0.66)
        #expect(Score(140).band == .healthy)
        #expect(Score(140).fraction == 1)
        #expect(Score(-1).fraction == 0)
    }
}
