/**
 Cek Legalitas's answer under the field: the lenders on OJK's licensed list matching the name, each
 opening its website; or, with no match, that the name is not on that list as of its date, which is
 not the same as illegal (Kira decides nothing); or the problem, with Coba Lagi.
 */
import Domain
import Features
import SwiftUI

struct LegalitySearchResults: View {
    let model: LegalityCheckModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        switch model.phase {
        case .idle: EmptyView()
        case .searching:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space2)
                .accessibilityLabel(Text("plan.risk.legality.searching"))
        case .answered(let query, let search) where search.results.isEmpty:
            KiraNotice(
                .warning, title: "plan.risk.legality.notFound.title \(query)",
                message: "plan.risk.legality.notFound.body \(asOf(search)) \(search.listed)")
        case .answered(_, let search):
            KiraListGroup(
                "plan.risk.legality.found \(search.results.count)",
                footer: "plan.risk.legality.source \(asOf(search)) \(search.listed)"
            ) {
                ForEach(search.results, id: \.license) { lender in
                    KiraListRow(Text(lender.app), leading: .icon(.shield), trailing: .external) {
                        if let website = lender.website { openURL(website) }
                    }
                    .subtitle(Text(subtitle(lender)))
                    .accessibilityHint(Text("debtEmergency.opensBrowser"))
                }
            }
        case .failed(let problem):
            KiraNotice(.info, title: "plan.risk.legality.failed", message: problem.failureMessage)
                .link("plan.risk.legality.retry") { Task { await model.search() } }
        }
    }

    private func asOf(_ search: LegalitySearch) -> String {
        search.asOf.date.formatted(.kiraDate)
    }

    /** "PT Kredit Pintar Indonesia · Berizin sejak 30 September 2019", Syariah named. */
    private func subtitle(_ lender: LicensedLender) -> LocalizedStringResource {
        let since = lender.licensedOn.date.formatted(.kiraDate)
        return lender.isSharia
            ? "plan.risk.legality.lender.sharia \(lender.company) \(since)"
            : "plan.risk.legality.lender \(lender.company) \(since)"
    }
}
