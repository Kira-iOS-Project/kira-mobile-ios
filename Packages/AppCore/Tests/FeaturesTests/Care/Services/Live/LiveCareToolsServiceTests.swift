import APIClient
import Domain
import Foundation
import Testing

@testable import Features

private let planJSON = #"""
    {"warningSigns":"susah tidur","calmingThings":"jalan sore","people":[{"name":"Ibu","phone":"0812-3456"}],
    "professionals":[{"name":"Healing119","phone":"119 ekstensi 8"}],"safePlace":"rumah keluarga",
    "updatedAt":"2026-10-17T02:00:00.000Z"}
    """#

@Suite("LiveCareToolsService")
struct LiveCareToolsServiceTests {
    private func service(_ replies: [String: RoutedTransport.Reply]) -> (LiveCareToolsService, RoutedTransport) {
        let (api, transport) = KiraAPI.routed(replies)
        return (LiveCareToolsService(api: api), transport)
    }

    @Test("GET /me gives the name; GET /debts the lenders with their instalments")
    func debts() async throws {
        let debts = #"""
            {"debts":[{"id":"7c1e2d3f-0000-4000-8000-000000000001","name":"Paylater B","kind":"paylater",
            "remaining":1200000,"monthlyInstalment":230000}]}
            """#
        let (service, _) = service(["GET /api/me": ok(meJSON()), "GET /api/debts": ok(debts)])
        #expect(try await service.displayName() == "Dinda")
        #expect(
            try await service.debts() == [
                CareDebt(
                    id: "7c1e2d3f-0000-4000-8000-000000000001", name: "Paylater B", kind: .paylater,
                    remaining: 1_200_000, monthlyInstalment: 230_000)
            ])
    }

    @Test("an unknown debt kind is a problem, not a crash")
    func unknownKind() async {
        let debts = #"{"debts":[{"id":"x","name":"X","kind":"lottery","remaining":1,"monthlyInstalment":1}]}"#
        let (service, _) = service(["GET /api/debts": ok(debts)])
        await #expect(throws: (any Error).self) { try await service.debts() }
    }

    @Test("reads the plan; 404 CARE_SAFETY_PLAN_NOT_FOUND is no plan yet")
    func plan() async throws {
        let (service, _) = service(["GET /api/care/safety-plan": ok(planJSON)])
        let plan = try #require(try await service.safetyPlan())
        #expect(plan.people == [SafetyContact(name: "Ibu", phone: "0812-3456")])
        #expect(plan.professionals.first?.dialable == "119,8" && plan.updatedAt != nil)
        let (empty, _) = self.service([
            "GET /api/care/safety-plan": problem("CARE_SAFETY_PLAN_NOT_FOUND", status: 404)
        ])
        #expect(try await empty.safetyPlan() == nil)
    }

    @Test(
        "every other answer to GET reaches the screen as its problem",
        arguments: [("AUTH_UNAUTHENTICATED", 401), ("ROUTE_NOT_FOUND", 404)])
    func planProblems(code: String, status: Int) async {
        let (service, _) = service(["GET /api/care/safety-plan": problem(code, status: status)])
        await #expect(throws: AppProblem(type: AppProblem.typeBase + code, code: code, requestId: "r-1")) {
            try await service.safetyPlan()
        }
    }

    @Test("PUT sends the whole plan and returns it as stored")
    func save() async throws {
        let (service, transport) = service(["PUT /api/care/safety-plan": ok(planJSON)])
        let plan = SafetyPlan(
            warningSigns: "susah tidur", people: [SafetyContact(name: "Ibu", phone: "0812-3456")], safePlace: "rumah")
        let stored = try await service.saveSafetyPlan(plan)
        #expect(stored.calmingThings == "jalan sore")
        let sent = try #require(await transport.sent.first?.json)
        #expect(sent["warningSigns"] == .string("susah tidur") && sent["safePlace"] == .string("rumah"))
        #expect(sent["people"] == .array([.object(["name": .string("Ibu"), "phone": .string("0812-3456")])]))
        #expect(sent["professionals"] == .array([]) && sent["updatedAt"] == nil)
    }

    @Test(
        "a refused save reaches the screen as its problem",
        arguments: [("VALIDATION_FAILED", 422), ("AUTH_UNAUTHENTICATED", 401)])
    func saveProblems(code: String, status: Int) async {
        let (service, _) = service(["PUT /api/care/safety-plan": problem(code, status: status)])
        await #expect(throws: AppProblem.self) { try await service.saveSafetyPlan(.empty) }
    }

    @Test("an undocumented answer is a problem without a code", arguments: ["GET /api/debts", "PUT /api/care/safety-plan"])
    func undocumented(route: String) async {
        let (service, _) = service([route: RoutedTransport.Reply(status: 500, body: "{}", contentType: "application/json")])
        await #expect(throws: AppProblem()) {
            if route.hasPrefix("GET") { _ = try await service.debts() } else { _ = try await service.saveSafetyPlan(.empty) }
        }
        let (unauthorized, _) = self.service(["GET /api/debts": problem("AUTH_UNAUTHENTICATED", status: 401)])
        await #expect(throws: AppProblem.self) { try await unauthorized.debts() }
        let (plan, _) = self.service(["GET /api/care/safety-plan": RoutedTransport.Reply(status: 500, body: "{}")])
        await #expect(throws: AppProblem()) { try await plan.safetyPlan() }
    }
}
