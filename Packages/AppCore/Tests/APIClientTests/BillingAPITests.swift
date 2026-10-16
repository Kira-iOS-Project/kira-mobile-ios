/** The billing calls: plans, the simulated checkout, the subscription, invoices and gifts. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let plansJSON = #"""
    {"plans":[{"id":"free","monthlyPrice":0,"yearlyPrice":0,"yearlySaving":0,"aiMessages":30,"receipts":10,\#
    "voiceSeconds":0,"voiceAndImport":false},{"id":"plus","monthlyPrice":29000,"yearlyPrice":290000,\#
    "yearlySaving":58000,"aiMessages":300,"receipts":150,"voiceSeconds":10800,"voiceAndImport":true}],\#
    "current":{"plan":"free","period":null}}
    """#

private let subscriptionJSON = #"""
    {"id":"s-1","plan":"plus","period":"monthly","source":"purchase","price":29000,"paymentMethod":"qris",\#
    "currentPeriodStart":"2026-10-16T05:00:00.000Z","renewsOn":"2026-11-16","reminderOn":"2026-11-13",\#
    "cancelAtPeriodEnd":false,"usage":{"aiMessages":{"used":3,"limit":300},"receipts":{"used":0,"limit":150},\#
    "voiceSeconds":{"used":0,"limit":10800},"resetsOn":"2026-11-16"}}
    """#

private let invoicesJSON = #"""
    {"items":[{"id":"i-1","plan":"plus","period":"yearly","amount":290000,"paymentMethod":"app_store",\#
    "periodStart":"2026-10-16","createdAt":"2026-10-16T05:00:00.000Z"}]}
    """#

private struct CheckoutBody: Decodable { let plan: String, period: String, paymentMethod: String }
private struct GiftBody: Decodable { let months: Int, paymentMethod: String }

@Suite("BillingAPI")
struct BillingAPITests {
    @Test("lists the plans and the current one")
    func listsPlans() async throws {
        let catalog = try await KiraAPI.canned(json: plansJSON).api.listPlans()
        #expect(catalog.current == .free && catalog.currentPeriod == nil && catalog.plans.count == 2)
        let plus = try #require(catalog.plans.last)
        #expect(plus.id == .plus && plus.monthlyPrice == 29_000 && plus.yearlyPrice == 290_000)
        #expect(plus.yearlySaving == 58_000 && plus.aiMessages == 300 && plus.receipts == 150)
        #expect(plus.voiceSeconds == 10_800 && plus.voiceAndImport)
    }

    @Test("checks out a paid plan and reads the subscription")
    func checksOut() async throws {
        let (api, transport) = KiraAPI.canned(json: subscriptionJSON)
        let subscription = try await api.checkout(plan: .plus, period: .monthly, paymentMethod: .qris)
        #expect(subscription.plan == .plus && subscription.period == .monthly && subscription.source == .purchase)
        #expect(subscription.price == 29_000 && subscription.paymentMethod == .qris && !subscription.cancelAtPeriodEnd)
        #expect(subscription.renewsOn == "2026-11-16" && subscription.reminderOn == "2026-11-13")
        #expect(subscription.currentPeriodStart == Date(timeIntervalSince1970: 1_792_126_800))
        #expect(subscription.id == "s-1" && subscription.usage.aiMessages.limit == 300)
        let body = try #require(await transport.request).decoded(CheckoutBody.self)
        #expect(body.plan == "plus" && body.period == "monthly" && body.paymentMethod == "qris")
    }

    @Test("refuses to buy Gratis without a request")
    func refusesFree() async {
        let (api, transport) = KiraAPI.canned(json: subscriptionJSON)
        await #expect(throws: AppProblem(code: "VALIDATION_FAILED")) {
            _ = try await api.checkout(plan: .free, period: .yearly, paymentMethod: .appStore)
        }
        #expect(await transport.request == nil)
    }

    @Test("reads, cancels and changes the subscription")
    func managesSubscription() async throws {
        let (api, transport) = KiraAPI.canned(json: subscriptionJSON)
        #expect(try await api.getSubscription().id == "s-1")
        #expect(try await api.cancelSubscription().id == "s-1")
        #expect(try await api.changePaymentMethod(.appStore).id == "s-1")
        let request = try #require(await transport.request)
        #expect(request.method == .put && request.text.contains("app_store"))
    }

    @Test("lists invoices")
    func listsInvoices() async throws {
        let invoices = try await KiraAPI.canned(json: invoicesJSON).api.listInvoices()
        let invoice = try #require(invoices.first)
        #expect(invoice.id == "i-1" && invoice.plan == .plus && invoice.period == .yearly)
        #expect(invoice.amount == 290_000 && invoice.paymentMethod == .appStore && invoice.periodStart == "2026-10-16")
        #expect(invoice.createdAt == Date(timeIntervalSince1970: 1_792_126_800))
    }

    @Test("gifts one, three or six months of Plus, sent as the spec's integer", arguments: GiftLengthDTO.allCases)
    func gifts(length: GiftLengthDTO) async throws {
        let months = length.rawValue
        let (api, transport) = KiraAPI.canned(
            status: 201, json: #"{"id":"g-1","months":\#(months),"amount":\#(29_000 * months)}"#)
        let gift = try await api.giftMonths(length, paymentMethod: .qris)
        #expect(gift == GiftDTO(id: "g-1", months: months, amount: 29_000 * months))
        let body = try #require(await transport.request).decoded(GiftBody.self)
        #expect(body.months == months && body.paymentMethod == "qris")
    }

    @Test("throws every problem the billing routes answer")
    func problems() async {
        await expectProblems([401]) { _ = try await $0.listPlans() }
        await expectProblems([401, 422]) {
            _ = try await $0.checkout(plan: .young, period: .monthly, paymentMethod: .qris)
        }
        await expectProblems([401, 404]) { _ = try await $0.getSubscription() }
        await expectProblems([401, 404, 409]) { _ = try await $0.cancelSubscription() }
        await expectProblems([401, 404, 422]) { _ = try await $0.changePaymentMethod(.qris) }
        await expectProblems([401]) { _ = try await $0.listInvoices() }
        await expectProblems([401, 422]) { _ = try await $0.giftMonths(.oneMonth, paymentMethod: .qris) }
    }
}
