import Domain
import Testing

@Suite("GoalKind")
struct GoalKindTests {
    @Test("names each kind as POST /goals does")
    func rawValues() {
        #expect(GoalKind.allCases.map(\.rawValue) == [
            "emergency_fund", "house_dp", "education", "wedding", "retirement", "vehicle", "goods", "other",
        ])
    }
}
