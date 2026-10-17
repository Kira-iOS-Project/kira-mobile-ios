/**
 Cek Legalitas's answer. Each search ends in a dialog, so the outcome is read, not skimmed (the
 owner's call, 2026-10-18): one match names the lender and opens its site; several ask to match the
 company exactly; no match says the name is not on OJK's list, which is not the same as illegal
 (Kira decides nothing), and offers OJK 157; a failure offers Coba Lagi. The matches also stay
 listed under the field, each opening its website.
 */
import Domain
import Features
import SwiftUI

struct LegalitySearchResults: View {
    let model: LegalityCheckModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        switch model.phase {
        case .searching:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space2)
                .accessibilityLabel(Text("plan.risk.legality.searching"))
        case .answered(_, let search) where !search.results.isEmpty:
            KiraListGroup(
                "plan.risk.legality.found \(search.results.count)",
                footer: "plan.risk.legality.source \(LegalityCopy.asOf(search)) \(search.listed)"
            ) {
                ForEach(search.results, id: \.license) { lender in
                    KiraListRow(Text(lender.app), leading: .icon(.shield), trailing: .external) {
                        if let website = lender.website { openURL(website) }
                    }
                    .subtitle(Text(LegalityCopy.subtitle(lender)))
                    .accessibilityHint(Text("debtEmergency.opensBrowser"))
                }
            }
        case .idle, .answered, .failed: EmptyView()
        }
    }
}

extension View {
    /** The dialog of `model`'s last answer; `onContact` opens Kontak OJK 157. */
    func legalityResultDialog(_ model: LegalityCheckModel, onContact: @escaping () -> Void) -> some View {
        modifier(LegalityResultDialog(model: model, onContact: onContact))
    }
}

private struct LegalityResultDialog: ViewModifier {
    let model: LegalityCheckModel
    let onContact: () -> Void
    @Environment(\.openURL) private var openURL
    /** Hubungi OJK 157 was tapped: its sheet opens once the dialog is down, not under it. */
    @State private var opensContact = false

    func body(content: Content) -> some View {
        content.kiraDialog(
            isPresented: Binding(get: { model.showsResult }, set: { if !$0 { model.resultClosed() } }),
            onDismiss: openContactIfAsked, dialog: { dialog })
    }

    private func openContactIfAsked() {
        guard opensContact else { return }
        opensContact = false
        onContact()
    }

    private var dialog: KiraDialog {
        switch model.phase {
        case .answered(let query, let search):
            switch search.results.count {
            case 0:
                return KiraDialog(
                    "plan.risk.legality.notFound.title \(query)",
                    message: "plan.risk.legality.notFound.body \(LegalityCopy.asOf(search)) \(search.listed)",
                    art: .illustration(.umbrella),
                    primary: KiraButton("plan.risk.legality.contact") { opensContact = true },
                    secondary: KiraButton("plan.risk.legality.close", variant: .secondary) {})
            case 1:
                let lender = search.results[0]
                let since = LegalityCopy.since(lender)
                let asOf = LegalityCopy.asOf(search)
                return KiraDialog(
                    "plan.risk.legality.foundOne.title",
                    message: "plan.risk.legality.foundOne.body \(lender.app) \(lender.company) \(since) \(asOf)",
                    art: .illustration(.shield),
                    primary: KiraButton("plan.risk.legality.openSite") {
                        if let website = lender.website { openURL(website) }
                    },
                    secondary: KiraButton("plan.risk.legality.close", variant: .secondary) {})
            default:
                return KiraDialog(
                    "plan.risk.legality.foundMany.title \(search.results.count)",
                    message: "plan.risk.legality.foundMany.body",
                    art: .illustration(.shield),
                    primary: KiraButton("plan.risk.legality.seeList") {})
            }
        case .failed(let problem):
            return KiraDialog(
                "plan.risk.legality.failed", message: problem.failureMessage, art: .illustration(.umbrella),
                primary: KiraButton("plan.risk.legality.retry") { Task { await model.search() } },
                secondary: KiraButton("plan.risk.legality.close", variant: .secondary) {})
        case .idle, .searching:
            return KiraDialog(
                "plan.risk.legality.failed", message: "problem.unknown", art: .illustration(.umbrella),
                primary: KiraButton("plan.risk.legality.close") {})
        }
    }
}

/** How a search answer is worded. */
enum LegalityCopy {
    /** "31 Juli 2026": the last day OJK's list covers. */
    static func asOf(_ search: LegalitySearch) -> String {
        search.asOf.date.formatted(.kiraDate)
    }

    /** "13 Desember 2019": the day OJK licensed `lender`. */
    static func since(_ lender: LicensedLender) -> String {
        lender.licensedOn.date.formatted(.kiraDate)
    }

    /** "PT Kredit Pintar Indonesia · Berizin sejak 30 September 2019", Syariah named. */
    static func subtitle(_ lender: LicensedLender) -> LocalizedStringResource {
        lender.isSharia
            ? "plan.risk.legality.lender.sharia \(lender.company) \(since(lender))"
            : "plan.risk.legality.lender \(lender.company) \(since(lender))"
    }
}
