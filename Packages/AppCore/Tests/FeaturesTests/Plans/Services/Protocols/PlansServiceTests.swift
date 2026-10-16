import APIClient
import Testing

@testable import Features

@Suite("plansProblem")
struct PlansServiceTests {
    private struct Offline: Error {}

    @Test("keeps the API's problem and turns anything else into the generic one")
    func mapping() {
        #expect(plansProblem(problem("SUBSCRIPTION_NOT_FOUND")).code == "SUBSCRIPTION_NOT_FOUND")
        #expect(plansProblem(Offline()) == AppProblem())
    }
}
