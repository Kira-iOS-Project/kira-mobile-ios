/**
 The design system's text styles (tokens.json: type). Display styles are Plus Jakarta Sans scaled
 from the iOS text style named beside them; text styles are the iOS ones, so Dynamic Type works
 everywhere. CSS weight 750 maps to ExtraBold (.heavy) and 650 to Semibold: SwiftUI names no weight
 between them. The overline is Caption 2, 11 pt, as the design system sets it.
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
    /** t-overline: the eyebrow above a card title, in capitals (11, Bold). */
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
        case .overline: .caption2.weight(.bold)
        case .formula: .system(.footnote, design: .monospaced).weight(.medium)
        case .hand: KiraFont.hand(19, relativeTo: .body)
        case .handSmall: KiraFont.hand(16, relativeTo: .subheadline)
        }
    }

    /** The CSS line height in points at the default text size. */
    var lineHeight: CGFloat {
        switch self {
        case .score: 64
        case .amountXL: 46
        case .largeTitle: 41
        case .title, .amount: 25
        case .headline, .body, .hand: 22
        case .callout, .formula: 20
        case .footnote: 18
        case .caption: 16
        case .overline: 13
        case .handSmall: 19
        }
    }

    /** The font's own line height in ems: Plus Jakarta Sans 1.26, Kalam 1.59, SF Pro 1.19. */
    var naturalLine: CGFloat {
        switch self {
        case .score, .amountXL, .largeTitle, .title, .amount: 1.26
        case .hand, .handSmall: 1.59
        case .headline, .body, .callout, .footnote, .caption, .overline, .formula: 1.19
        }
    }

    /** The iOS text style the style scales with. */
    var textStyle: Font.TextStyle {
        switch self {
        case .score, .amountXL, .largeTitle: .largeTitle
        case .title, .amount: .title3
        case .headline: .headline
        case .body, .hand: .body
        case .callout, .handSmall: .subheadline
        case .footnote, .formula: .footnote
        case .caption: .caption
        case .overline: .caption2
        }
    }

    /** The font size in points at the default text size. */
    var pointSize: CGFloat {
        switch self {
        case .score: 64
        case .amountXL: 40
        case .largeTitle: 34
        case .title, .amount: 20
        case .hand: 19
        case .headline, .body: 17
        case .handSmall: 16
        case .callout: 15
        case .footnote, .formula: 13
        case .caption: 12
        case .overline: 11
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
        case .overline: 0.88
        case .headline, .body, .callout, .footnote, .formula, .hand, .handSmall: 0
        }
    }
}

extension View {
    /**
     Sets one of Kira's text styles: its font, its letter spacing, its line height, and capitals
     for the overline.
     */
    func kiraFont(_ style: KiraTextStyle) -> some View {
        font(style.font)
            .tracking(style.tracking)
            .textCase(style == .overline ? .uppercase : nil)
            .kiraLineHeight(
                style.lineHeight, size: style.pointSize, natural: style.naturalLine, relativeTo: style.textStyle
            )
            .kiraSmallType(style == .overline)
    }
}
