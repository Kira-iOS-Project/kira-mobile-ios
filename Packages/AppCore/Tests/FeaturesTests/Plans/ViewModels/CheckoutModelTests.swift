import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("CheckoutModel")
struct CheckoutModelTests {
    /** 16 October 2026, 09.00 WIB. */
    private let now = Date(timeIntervalSince1970: 1_792_116_000)

    @Test("renews a month or a year on, at that period's price")
    func renewal() {
        let monthly = CheckoutModel(terms: PlansFixtures.plus, period: .monthly, service: FakePlansService(), now: now)
        #expect(monthly.renewsOn == CalendarDay(year: 2026, month: 11, day: 16))
        #expect(monthly.price == 29_000)
        let yearly = CheckoutModel(terms: PlansFixtures.plus, period: .yearly, service: FakePlansService(), now: now)
        #expect(yearly.renewsOn == CalendarDay(year: 2027, month: 10, day: 16))
        #expect(yearly.price == 290_000)
        let today = CheckoutModel(terms: PlansFixtures.young, period: .monthly, service: FakePlansService())
        #expect(today.renewsOn > CalendarDay(year: 2026, month: 1, day: 1))
    }

    @Test("pays with the picked method and keeps the new subscription")
    func pays() async {
        let service = FakePlansService()
        let model = CheckoutModel(terms: PlansFixtures.young, period: .yearly, service: service, now: now)
        model.paymentMethod = .appStore
        await model.pay()
        guard case .paid(let subscription) = model.phase else {
            Issue.record("expected paid")
            return
        }
        #expect(subscription == PlansFixtures.subscription())
        #expect(await service.log.calls == ["checkout young yearly app_store"])
    }

    @Test("sends one checkout when Bayar is tapped twice")
    func paysOnce() async {
        let service = FakePlansService()
        let model = CheckoutModel(terms: PlansFixtures.plus, period: .monthly, service: service, now: now)
        async let first: Void = model.pay()
        async let second: Void = model.pay()
        _ = await (first, second)
        await model.pay()
        #expect(await service.log.calls == ["checkout plus monthly qris"])
    }

    @Test("keeps the problem of a refused payment")
    func fails() async {
        let service = FakePlansService(changeResult: .failure(problem("VALIDATION_FAILED")))
        let model = CheckoutModel(terms: PlansFixtures.plus, period: .monthly, service: service, now: now)
        guard case .ready = model.phase else {
            Issue.record("expected ready")
            return
        }
        await model.pay()
        guard case .failed(let failure) = model.phase else {
            Issue.record("expected a failure")
            return
        }
        #expect(failure.code == "VALIDATION_FAILED")
    }
}
