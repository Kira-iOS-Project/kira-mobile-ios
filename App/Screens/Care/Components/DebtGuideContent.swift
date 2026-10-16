/**
 The words of each debt guide, as the boards write them: the nav bar, the pandan card (what to know,
 four points and its basis), the four steps and the closing notice. Static legal content reviewed
 by the Kira team, in the String Catalog.
 */
import Domain
import SwiftUI

struct DebtGuideContent {
    /** Whether the card's points are things to avoid (a cross) or things to have ready (a check). */
    enum Marker {
        case avoid, prepare
    }

    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let icon: KiraIconName
    let heading: LocalizedStringResource
    let lead: LocalizedStringResource
    let marker: Marker
    let points: [LocalizedStringResource]
    let basis: LocalizedStringResource
    let steps: [(title: LocalizedStringResource, detail: LocalizedStringResource)]
    let notice: LocalizedStringResource

    static func of(_ guide: DebtGuide) -> Self {
        switch guide {
        case .harshCollection: harshCollection
        case .illegalLender: illegalLender
        case .unresolvedComplaint: unresolvedComplaint
        case .payoffOffer: payoffOffer
        }
    }

    private static let harshCollection = Self(
        title: "debtGuide.harshCollection.title", subtitle: "debtGuide.harshCollection.subtitle", icon: .shield,
        heading: "debtGuide.harshCollection.heading", lead: "debtGuide.harshCollection.lead", marker: .avoid,
        points: [
            "debtGuide.harshCollection.point1", "debtGuide.harshCollection.point2",
            "debtGuide.harshCollection.point3", "debtGuide.harshCollection.point4",
        ],
        basis: "debtGuide.harshCollection.basis",
        steps: [
            ("debtGuide.harshCollection.step1", "debtGuide.harshCollection.step1.detail"),
            ("debtGuide.harshCollection.step2", "debtGuide.harshCollection.step2.detail"),
            ("debtGuide.harshCollection.step3", "debtGuide.harshCollection.step3.detail"),
            ("debtGuide.harshCollection.step4", "debtGuide.harshCollection.step4.detail"),
        ],
        notice: "debtGuide.harshCollection.notice")

    private static let illegalLender = Self(
        title: "debtGuide.illegalLender.title", subtitle: "debtGuide.illegalLender.subtitle", icon: .alert,
        heading: "debtGuide.illegalLender.heading", lead: "debtGuide.illegalLender.lead", marker: .avoid,
        points: [
            "debtGuide.illegalLender.point1", "debtGuide.illegalLender.point2",
            "debtGuide.illegalLender.point3", "debtGuide.illegalLender.point4",
        ],
        basis: "debtGuide.illegalLender.basis",
        steps: [
            ("debtGuide.illegalLender.step1", "debtGuide.illegalLender.step1.detail"),
            ("debtGuide.illegalLender.step2", "debtGuide.illegalLender.step2.detail"),
            ("debtGuide.illegalLender.step3", "debtGuide.illegalLender.step3.detail"),
            ("debtGuide.illegalLender.step4", "debtGuide.illegalLender.step4.detail"),
        ],
        notice: "debtGuide.illegalLender.notice")

    private static let unresolvedComplaint = Self(
        title: "debtGuide.unresolvedComplaint.title", subtitle: "debtGuide.unresolvedComplaint.subtitle", icon: .file,
        heading: "debtGuide.unresolvedComplaint.heading", lead: "debtGuide.unresolvedComplaint.lead",
        marker: .prepare,
        points: [
            "debtGuide.unresolvedComplaint.point1", "debtGuide.unresolvedComplaint.point2",
            "debtGuide.unresolvedComplaint.point3", "debtGuide.unresolvedComplaint.point4",
        ],
        basis: "debtGuide.unresolvedComplaint.basis",
        steps: [
            ("debtGuide.unresolvedComplaint.step1", "debtGuide.unresolvedComplaint.step1.detail"),
            ("debtGuide.unresolvedComplaint.step2", "debtGuide.unresolvedComplaint.step2.detail"),
            ("debtGuide.unresolvedComplaint.step3", "debtGuide.unresolvedComplaint.step3.detail"),
            ("debtGuide.unresolvedComplaint.step4", "debtGuide.unresolvedComplaint.step4.detail"),
        ],
        notice: "debtGuide.unresolvedComplaint.notice")

    private static let payoffOffer = Self(
        title: "debtGuide.payoffOffer.title", subtitle: "debtGuide.payoffOffer.subtitle", icon: .alert,
        heading: "debtGuide.payoffOffer.heading", lead: "debtGuide.payoffOffer.lead", marker: .avoid,
        points: [
            "debtGuide.payoffOffer.point1", "debtGuide.payoffOffer.point2",
            "debtGuide.payoffOffer.point3", "debtGuide.payoffOffer.point4",
        ],
        basis: "debtGuide.payoffOffer.basis",
        steps: [
            ("debtGuide.payoffOffer.step1", "debtGuide.payoffOffer.step1.detail"),
            ("debtGuide.payoffOffer.step2", "debtGuide.payoffOffer.step2.detail"),
            ("debtGuide.payoffOffer.step3", "debtGuide.payoffOffer.step3.detail"),
            ("debtGuide.payoffOffer.step4", "debtGuide.payoffOffer.step4.detail"),
        ],
        notice: "debtGuide.payoffOffer.notice")
}

extension DebtGuideAction {
    /** The button's label and icon, as the boards draw it. */
    var label: (title: LocalizedStringResource, icon: KiraIconName) {
        switch self {
        case .callOJK: ("debtGuide.action.callOJK", .phone)
        case .whatsAppOJK: ("debtGuide.action.whatsAppOJK", .chat)
        case .reportToSatgas: ("debtGuide.action.reportToSatgas", .flag)
        case .openLapsSjk: ("debtGuide.action.openLapsSjk", .external)
        case .negotiationScript: ("debtGuide.action.negotiationScript", .calendar)
        }
    }
}
