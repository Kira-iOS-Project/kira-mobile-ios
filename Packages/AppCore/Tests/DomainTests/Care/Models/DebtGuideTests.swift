import Testing

@testable import Domain

@Suite("DebtGuide")
struct DebtGuideTests {
    @Test(
        "each guide offers the board's buttons, top first",
        arguments: [
            (DebtGuide.harshCollection, [DebtGuideAction.callOJK, .whatsAppOJK]),
            (.illegalLender, [.reportToSatgas, .callOJK]),
            (.unresolvedComplaint, [.openLapsSjk, .callOJK]),
            (.payoffOffer, [.reportToSatgas, .negotiationScript]),
        ])
    func actions(guide: DebtGuide, expected: [DebtGuideAction]) {
        #expect(guide.actions == expected)
    }

    @Test("only Ditagih Kasar's notice links to the negotiation script")
    func noticeLink() {
        #expect(DebtGuide.harshCollection.noticeLink == .negotiationScript)
        #expect(DebtGuide.allCases.filter { $0.noticeLink != nil } == [.harshCollection])
    }
}
