/** One sub-score of a report: Tabung, Utang or Lindungi with its points and band. */
package struct GroupScore: Hashable, Sendable {
    /** Which sub-score. */
    package let group: IndicatorGroup
    /** Its points, 0–100. */
    package let points: Int
    /** Its band. */
    package let band: ScoreBand

    /** A sub-score with every field given. */
    package init(group: IndicatorGroup, points: Int, band: ScoreBand) {
        self.group = group
        self.points = points
        self.band = band
    }
}
