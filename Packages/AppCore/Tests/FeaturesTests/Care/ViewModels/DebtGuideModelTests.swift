import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("DebtGuideModel")
struct DebtGuideModelTests {
    @Test("the shipped links work before the contacts load")
    func shippedLinks() {
        let model = DebtGuideModel(guide: .harshCollection, care: FakeCareService())
        #expect(model.guide == .harshCollection)
        #expect(model.phase.value == nil)
        #expect(model.destination(.callOJK) == .link(URL(string: "tel:157")!))
        #expect(model.destination(.whatsAppOJK) == .link(URL(string: "https://wa.me/6281157157157")!))
        #expect(model.destination(.reportToSatgas) == .link(URL(string: "https://sipasti.ojk.go.id")!))
        #expect(model.destination(.openLapsSjk) == .link(URL(string: "https://lapssjk.id")!))
        #expect(model.destination(.negotiationScript) == .route(.negotiationScript))
    }

    @Test("the server's numbers replace the shipped ones once loaded")
    func serverLinks() async {
        let ojk = CareContact(key: .ojk157, name: "OJK", phone: "1500157")
        let list = CareContactList(verifiedOn: CalendarDay(year: 2026, month: 11, day: 1), contacts: [ojk])
        let model = DebtGuideModel(guide: .illegalLender, care: FakeCareService(result: .success(list)))
        await model.load()
        #expect(model.phase.value == list)
        #expect(model.destination(.callOJK) == .link(URL(string: "tel:1500157")!))
        #expect(model.destination(.whatsAppOJK) == nil)
        #expect(model.destination(.reportToSatgas) == .link(URL(string: "https://sipasti.ojk.go.id")!))
    }

    @Test("an unreachable server keeps the guide on the shipped contacts")
    func failure() async {
        let model = DebtGuideModel(guide: .payoffOffer, care: FakeCareService(result: .failure(AppProblem())))
        await model.load()
        #expect(model.phase.value == .shipped)
    }
}
