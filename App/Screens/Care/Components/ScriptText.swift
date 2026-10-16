/**
 The negotiation script's fixed template (`care.script.body`), filled on the device. On screen the
 contract number shows masked and both coloured phrases are links the screen catches; the copied
 text is plain and carries the full contract number, or "[nomor kontrak]" while none is typed. The
 values come from `NegotiationScript.fill(for:)`, so the screen and the clipboard read one script.
 */
import Domain
import Foundation
import SwiftUI

enum ScriptText {
    /** The link a coloured phrase opens; the screen catches it, nothing leaves the app. */
    static let reasonLink = URL(string: "kira-script:reason")
    static let contractLink = URL(string: "kira-script:contract")

    private static let contractMarker = "\u{E001}"
    private static let reasonMarker = "\u{E002}"

    /** The script as the screen shows it, its two phrases coloured and tappable. */
    static func shown(_ fill: NegotiationScript.Fill) -> AttributedString {
        var text = AttributedString(body(fill, contract: contractMarker, reason: reasonMarker))
        let contract = fill.contract ?? String(localized: "care.script.contractPlaceholder")
        replace(contractMarker, in: &text, with: contract, link: contractLink)
        replace(reasonMarker, in: &text, with: fill.reason, link: reasonLink)
        return text
    }

    /** The script as it is copied: plain, with the full contract number or the gap the person sees. */
    static func copied(_ fill: NegotiationScript.Fill) -> String {
        body(fill, contract: fill.contract ?? String(localized: "care.script.contractGap"), reason: fill.reason)
    }

    private static func body(_ fill: NegotiationScript.Fill, contract: String, reason: String) -> String {
        let name = fill.name ?? String(localized: "care.script.nameGap")
        let instalment = RupiahFormatStyle().format(Decimal(fill.instalment))
        let affordable = RupiahFormatStyle().format(Decimal(fill.affordable))
        return String(localized: "care.script.body \(name) \(contract) \(instalment) \(reason) \(affordable)")
    }

    private static func replace(_ marker: String, in text: inout AttributedString, with phrase: String, link: URL?) {
        guard let range = text.range(of: marker) else { return }
        var run = AttributedString(phrase)
        run.foregroundColor = .coping
        run.backgroundColor = .copingSoft
        run.font = .subheadline.weight(.semibold)
        run.link = link
        text.replaceSubrange(range, with: run)
    }
}
