import Foundation
import Testing

@testable import Features

@MainActor
@Suite("CreditReportModel")
struct CreditReportModelTests {
    @Test("the static guide is loaded at once, on iDebKu OJK's own address")
    func loadedOnIDebKu() throws {
        let model = CreditReportModel()
        let site = try #require(model.phase.value)
        #expect(site.absoluteString == "https://idebku.ojk.go.id")
        #expect(model.presentedSite == nil)
    }

    @Test("Buka iDebKu OJK shows the site in the browser, and closing it returns to the guide")
    func opensAndClosesTheSite() throws {
        let model = CreditReportModel()
        model.openSite()
        #expect(model.presentedSite == URL(string: "https://idebku.ojk.go.id"))
        model.closeSite()
        #expect(model.presentedSite == nil)
    }

    @Test("without a site the guide is empty and the button opens nothing")
    func emptyWithoutASite() {
        let model = CreditReportModel(site: nil)
        guard case .empty = model.phase else {
            Issue.record("expected empty, got \(model.phase)")
            return
        }
        model.openSite()
        #expect(model.presentedSite == nil)
    }
}
