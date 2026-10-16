/** One of the six indicators of a score report, with its points and what was measured. */
package struct ScoreIndicator: Hashable, Sendable {
    /** Which indicator. */
    package let key: IndicatorKey
    /** The sub-score it counts towards. */
    package let group: IndicatorGroup
    /** Its points, 0–100. */
    package let points: Int
    /** Its band, which a rule may set apart from the points. */
    package let band: ScoreBand
    /** What the engine measured. */
    package let measure: IndicatorMeasure

    /** An indicator with every field given. */
    package init(key: IndicatorKey, group: IndicatorGroup, points: Int, band: ScoreBand, measure: IndicatorMeasure) {
        self.key = key
        self.group = group
        self.points = points
        self.band = band
        self.measure = measure
    }
}
