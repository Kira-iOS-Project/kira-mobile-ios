/**
 Cek Legalitas on the canvas's sample: two entries of OJK's July 2026 list, matched by name, for
 previews and `-KiraScreen`; any other name is not on the list.
 */
import Domain
import Features
import Foundation

struct PreviewLegalityService: LegalityService {
    private static let lenders = [
        LicensedLender(
            company: "PT Kredit Pintar Indonesia", app: "Kredit Pintar", license: "KEP-83/D.05/2019",
            licensedOn: CalendarDay(year: 2019, month: 9, day: 30), isSharia: false,
            website: URL(string: "https://www.kreditpintar.com/")),
        LicensedLender(
            company: "PT Dana Syariah Indonesia", app: "DANA SYARIAH", license: "KEP-10/D.05/2021",
            licensedOn: CalendarDay(year: 2021, month: 2, day: 23), isSharia: true,
            website: URL(string: "http://danasyariah.id")),
    ]

    func search(_ query: String) -> LegalitySearch {
        var results: [LicensedLender] = []
        for lender in Self.lenders where "\(lender.app) \(lender.company)".localizedCaseInsensitiveContains(query) {
            results.append(lender)
        }
        return LegalitySearch(
            results: results, asOf: CalendarDay(year: 2026, month: 7, day: 31), source: LegalityLinks.ojk,
            listed: 94)
    }
}
