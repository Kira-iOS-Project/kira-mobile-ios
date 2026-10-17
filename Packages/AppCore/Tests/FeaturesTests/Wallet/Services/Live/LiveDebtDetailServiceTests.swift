import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveDebtDetailService")
struct LiveDebtDetailServiceTests {
    private let route = "GET /api/debts/d-1"
    private let debtJSON = #"""
        {"id":"d-1","name":"Paylater A","kind":"paylater","remaining":420000,"totalAmount":1260000,\#
        "paidAmount":840000,"instalmentsPaid":4,"instalmentsTotal":6,"monthlyInstalment":210000,\#
        "dueDate":"2026-11-05",\#
        "payments":[{"id":"6f1c2b9e-0000-4000-8000-000000000001","number":4,"amount":210000,\#
        "paidOn":"2026-10-05","onTime":true}],\#
        "nextStep":{"priority":1,"priorityOf":3,"extraAmount":200000,"payOn":"2026-10-25","monthsEarlier":1,\#
        "scoreBefore":61,"scoreAfter":64}}
        """#

    @Test("GET /debts/{id} becomes the Domain's debt with its payments, due day and next step")
    func debt() async throws {
        let (api, transport) = KiraAPI.routed([route: ok(debtJSON)])
        let debt = try await LiveDebtDetailService(api: api).debt(id: "d-1")
        #expect(await transport.sent.count == 1)
        #expect(debt.id == "d-1" && debt.name == "Paylater A" && debt.kind == .paylater)
        #expect(debt.remaining == 420_000 && debt.totalAmount == 1_260_000 && debt.paidAmount == 840_000)
        #expect(debt.instalmentsPaid == 4 && debt.instalmentsTotal == 6 && debt.monthlyInstalment == 210_000)
        #expect(debt.dueDate == CalendarDay(year: 2026, month: 11, day: 5))
        let payment = try #require(debt.payments.first)
        #expect(payment.number == 4 && payment.amount == 210_000 && payment.onTime)
        #expect(payment.paidOn == CalendarDay(year: 2026, month: 10, day: 5))
        let step = try #require(debt.nextStep)
        #expect(step.priority == 1 && step.priorityOf == 3 && step.extraAmount == 200_000)
        #expect(step.payOn == CalendarDay(year: 2026, month: 10, day: 25))
        #expect(step.scoreBefore == 61 && step.scoreAfter == 64)
    }

    @Test("a debt without a due day, payments or next step reads its nulls as nil")
    func bare() async throws {
        let json =
            debtJSON
            .replacingOccurrences(of: #""dueDate":"2026-11-05""#, with: #""dueDate":null"#)
            .replacingOccurrences(
                of: #""instalmentsPaid":4,"instalmentsTotal":6"#,
                with: #""instalmentsPaid":null,"instalmentsTotal":null"#
            )
            .replacingOccurrences(of: #""payOn":"2026-10-25""#, with: #""payOn":null"#)
        let (api, _) = KiraAPI.routed([route: ok(json)])
        let debt = try await LiveDebtDetailService(api: api).debt(id: "d-1")
        #expect(debt.dueDate == nil && debt.instalmentsPaid == nil && debt.instalmentsTotal == nil)
        #expect(debt.nextStep?.payOn == nil)
    }

    @Test("a debt with no next step reads it as nil")
    func noNextStep() async throws {
        let json = debtJSON.replacing(#/"nextStep":\{[^}]*\}/#, with: #""nextStep":null"#)
        let (api, _) = KiraAPI.routed([route: ok(json)])
        #expect(try await LiveDebtDetailService(api: api).debt(id: "d-1").nextStep == nil)
    }

    @Test("a day the app cannot read is a problem without a code", arguments: ["dueDate", "paidOn", "payOn"])
    func unreadableDay(field: String) async throws {
        let json = debtJSON.replacing(
            try Regex(#""\#(field)":"[0-9-]+""#), with: #""\#(field)":"not-a-date""#)
        let (api, _) = KiraAPI.routed([route: ok(json)])
        await expectProblem(nil) { _ = try await LiveDebtDetailService(api: api).debt(id: "d-1") }
    }

    @Test("a kind the app cannot read is a problem")
    func unreadableKind() async {
        let json = debtJSON.replacingOccurrences(of: #""kind":"paylater""#, with: #""kind":"unknown_kind""#)
        let (api, _) = KiraAPI.routed([route: ok(json)])
        await #expect(throws: (any Error).self) { _ = try await LiveDebtDetailService(api: api).debt(id: "d-1") }
    }

    @Test(
        "every refusal of GET /debts/{id} throws its problem",
        arguments: [
            ("AUTH_UNAUTHENTICATED", 401), ("PAYOFF_DEBT_NOT_FOUND", 404), ("VALIDATION_FAILED", 422),
            ("INTERNAL_ERROR", 500),
        ])
    func refused(code: String, status: Int) async {
        let (api, _) = KiraAPI.routed([route: problem(code, status: status)])
        await expectProblem(code) { _ = try await LiveDebtDetailService(api: api).debt(id: "d-1") }
    }
}

/** Runs `call` and checks it throws an `AppProblem` with `code` (nil: a problem without a code). */
private func expectProblem(_ code: String?, _ call: () async throws -> Void) async {
    do {
        try await call()
        Issue.record("expected a problem")
    } catch let problem as AppProblem {
        #expect(problem.code == code)
    } catch {
        Issue.record("expected an AppProblem, got \(error)")
    }
}
