// A score on Kira's 0–100 scale: the Kira Score itself, or the points of one of its six
// indicators. The score engine computes it; the app only places it on the scale and names its band.

/// A score from 0 to 100, clamped, with the band it falls in.
package struct Score: Hashable, Sendable {
    /// The score, from 0 to 100.
    package let value: Int

    /// A score of `value`, clamped to 0...100.
    package init(_ value: Int) {
        self.value = min(max(value, 0), 100)
    }

    /// The band the score falls in.
    package var band: ScoreBand { ScoreBand(score: value) }

    /// The score as a share of the scale, from 0 to 1, for bars and markers.
    package var fraction: Double { Double(value) / 100 }
}
