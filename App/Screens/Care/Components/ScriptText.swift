/**
 The negotiation script's fixed template (`care.script.body`), filled on the device. On screen the
 contract number shows masked and both coloured phrases are links the screen catches; the copied
 text is plain and carries the full contract number, or "[nomor kontrak]" while none is typed.
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
    static func shown(_ script: NegotiationScript) -> AttributedString {
        var text = AttributedString(body(script, contract: contractMarker, reason: reasonMarker))
        let contract = script.maskedContract ?? String(localized: "care.script.contractPlaceholder")
        replace(contractMarker, in: &text, with: contract, link: contractLink)
        replace(reasonMarker, in: &text, with: script.trimmedReason ?? script.reason, link: reasonLink)
        return text
    }

    /** The script as it is copied: plain, with the full contract number or the gap the person sees. */
    static func copied(_ script: NegotiationScript) -> String {
        let contract =
            script.contractCharacters.isEmpty
            ? String(localized: "care.script.contractGap") : script.contractNumber
        return body(script, contract: contract, reason: script.trimmedReason ?? script.reason)
    }

    private static func body(_ script: NegotiationScript, contract: String, reason: String) -> String {
        let instalment = RupiahFormatStyle().format(Decimal(script.currentInstalment ?? 0))
        let affordable = RupiahFormatStyle().format(Decimal(script.affordable ?? 0))
        return String(localized: "care.script.body \(script.name) \(contract) \(instalment) \(reason) \(affordable)")
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
