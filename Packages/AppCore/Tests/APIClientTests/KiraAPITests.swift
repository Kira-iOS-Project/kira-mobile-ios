/** The client's construction, the enum bridge and the values several tags share. */
import Domain
import Foundation
import OpenAPIRuntime
import Testing

@testable import APIClient

@Suite("KiraAPI")
struct KiraAPITests {
    @Test("builds a client on the system transport by default")
    func defaultTransport() {
        let api = KiraAPI(serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"))
        #expect(type(of: api.client) == Client.self)
    }

    @Test("bridges a value between vocabularies with the same spelling")
    func bridgesValues() throws {
        let band: ScoreBand = try bridged(Components.Schemas.ScoreReport.BandPayload.coping)
        #expect(band == .coping)
        let none: ScoreBand? = try bridged(Components.Schemas.ScoreReport.BandPayload?.none)
        #expect(none == nil)
        let some: PlanID? = try bridged(Components.Schemas.Plan.IdPayload?.some(.plus))
        #expect(some == .plus)
    }

    @Test("surfaces a spelling the target does not know as the generic problem")
    func refusesUnknownSpelling() {
        #expect(throws: AppProblem()) {
            let _: ScoreBand = try bridged(PlanID.plus)
        }
    }

    @Test("reads usage and a payday period")
    func sharedValues() throws {
        let usage = Usage(
            .init(
                aiMessages: .init(used: 3, limit: 30), receipts: .init(used: 0, limit: 10),
                voiceSeconds: .init(used: 0, limit: 0), resetsOn: "2026-11-01"))
        #expect(usage.aiMessages == UsageMeter(.init(used: 3, limit: 30)))
        #expect(usage.voiceSeconds.limit == 0 && usage.resetsOn == "2026-11-01")
        let period = PaydayPeriod(
            .init(start: "2026-09-25", end: "2026-10-24", nextPayday: "2026-10-25", daysUntilPayday: 9))
        #expect(period.nextPayday == "2026-10-25" && period.daysUntilPayday == 9)
    }
}
