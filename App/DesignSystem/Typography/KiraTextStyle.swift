/**
 The design system's text styles (tokens.json: type). Display styles are Plus Jakarta Sans scaled
 from the iOS text style named beside them; text styles are the iOS ones, so Dynamic Type works
 everywhere. CSS weight 750 maps to ExtraBold (.heavy) and 650 to Semibold: SwiftUI names no weight
 between them. Nothing uses Caption 2 (11 pt): iOS never shrinks it below 11 pt, which Apple's
 accessibility audit reports as partial Dynamic Type support, so the overline (and the dock's
 "Catat") use Caption 1, 12 pt.
 */
import SwiftUI

/** One of Kira's text styles; apply it with `.kiraFont(_:)`. */
enum KiraTextStyle: CaseIterable {
    /** t-score: the Kira Score number, once per screen (64, ExtraBold). */
    case score
    /** t-amount-xl: the money left on the home hero card (40, ExtraBold). */
    case amountXL
    /** t-large-title: a large screen title (34). */
    case largeTitle
    /** t-title: card and section titles (20, Bold). */
    case title
    /** t-amount: totals on draft and summary cards (20, Bold). */
    case amount
    /** t-headline: button labels, indicator names, row titles (17, Semibold). */
    case headline
    /** t-body: chat text and main sentences (17). */
    case body
    /** t-callout: explanations inside cards (15). */
    case callout
    /** t-footnote: metadata, transaction categories, scale labels (13, Medium). */
    case footnote
    /** t-caption: required labels under numbers (12, Medium). */
    case caption
    /** t-overline: the eyebrow above a card title, in capitals (Bold; 12, see the file comment). */
    case overline
    /** t-formula: the formula in a "Gimana Ngitungnya?" panel (13, monospaced). */
    case formula
    /** t-hand: Kira's handwritten note (Kalam 19). */
    case hand
    /** t-hand-sm: a small note under an illustration (Kalam 16). */
    case handSmall

    /** The font, scaled with Dynamic Type; numbers are tabular in the numeric styles. */
    var font: Font {
        switch self {
        case .score: KiraFont.display(64, .heavy, relativeTo: .largeTitle).monospacedDigit()
        case .amountXL: KiraFont.display(40, .heavy, relativeTo: .largeTitle).monospacedDigit()
        case .largeTitle: KiraFont.display(34, .heavy, relativeTo: .largeTitle)
        case .title: KiraFont.display(20, .bold, relativeTo: .title3)
        case .amount: KiraFont.display(20, .bold, relativeTo: .title3).monospacedDigit()
        case .headline: .headline
        case .body: .body
        case .callout: .subheadline
        case .footnote: .footnote.weight(.medium)
        case .caption: .caption.weight(.medium)
        case .overline: .caption.weight(.bold)
        case .formula: .system(.footnote, design: .monospaced).weight(.medium)
        case .hand: KiraFont.hand(19, relativeTo: .body)
        case .handSmall: KiraFont.hand(16, relativeTo: .subheadline)
        }
    }

    /** Letter spacing in points, from the style's em value at its nominal size. */
    var tracking: CGFloat {
        switch self {
        case .score: -1.92
        case .amountXL: -1.2
        case .largeTitle: -0.68
        case .title, .amount: -0.2
        case .caption: 0.12
        case .overline: 0.96
        case .headline, .body, .callout, .footnote, .formula, .hand, .handSmall: 0
        }
    }
}

extension View {
    /** Sets one of Kira's text styles: its font, its letter spacing, and capitals for the overline. */
    func kiraFont(_ style: KiraTextStyle) -> some View {
        font(style.font)
            .tracking(style.tracking)
            .textCase(style == .overline ? .uppercase : nil)
    }
}
