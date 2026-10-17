/**
 Amount (design system): rupiah in full with two decimals and tabular figures, "Rp1.840.000,00".
 From md up, "Rp" and ",00" are smaller and muted so the whole rupiah reads first. It never wraps:
 put a big amount on its own line with its words in a small label above. Income and spending are
 told apart by the sign (`.signed()`) and a label, never by green and red. Every balance can be
 hidden (`.masked(_:)`): "Rp••••••", read by VoiceOver as "Nominal disembunyikan".
 */
import Domain
import SwiftUI

/** A rupiah amount, formatted by the Domain's RupiahFormatStyle. */
struct KiraAmount: View {
    /** The amount's size. */
    enum Size: CaseIterable {
        /** 17 pt, the body text's font: rows and bubbles. */
        case small
        /** 20 pt display (default): draft rows, summaries. */
        case medium
        /** 34 pt display: a card's total. */
        case large
        /** 42 pt display, ExtraBold: the money left on the hero card. */
        case extraLarge

        /** The next size down, or nil from small. */
        var smaller: Size? {
            switch self {
            case .small: nil
            case .medium: .small
            case .large: .medium
            case .extraLarge: .large
            }
        }
    }

    private let value: Decimal
    private var size: Size
    private var isMasked = false
    private var isSigned = false
    private var isMuted = false
    private var isInverse = false

    init(_ value: Decimal, size: Size = .medium) {
        self.value = value
        self.size = size
    }

    private var style: RupiahFormatStyle {
        RupiahFormatStyle.rupiah.sign(isSigned ? .always : .automatic).masked(isMasked)
    }

    var body: some View {
        /**
         One line always. A long amount that does not fit at its size steps down to the next size
         that holds it whole (Rp3.013.687.857,00 on a goal's result), drawn at that size rather than
         shrunk: Apple's audit reads shrunk text as clipped. Only past the smallest size does it shrink.
         */
        ViewThatFits(in: .horizontal) {
            line(size)
            if let smaller = size.smaller { line(smaller) }
            if let smallest = size.smaller?.smaller { line(smallest) }
            line(.small).minimumScaleFactor(0.4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isMasked ? Text("ds.amount.hidden") : spoken)
        .kiraSmallType(size == .medium)
    }

    /** The amount drawn at `size`, on one line. */
    private func line(_ size: Size) -> some View {
        let amount = copy { $0.size = size }
        return amount.composed
            .font(amount.mainFont)
            .foregroundStyle(amount.mainColor)
            .lineLimit(1)
            /** On the text and on the element: the audit reads the text inside an element too. */
            .kiraSmallType(size == .medium)
    }

    /**
     The amount as one Text, so it shrinks as a whole: sign, "Rp", the integer, ",00". The space
     after "Rp" and before ",00" (`.k-amount__cur` 0.14em, `.k-amount__dec` 0.03em, of their own
     size) is tracking on the glyph before it.
     */
    private var composed: Text {
        let symbol = style.part(.symbol).format(value)
        let integer = style.part(.integer).format(value)
        return Text(style.part(.sign).format(value))
            + spaced(symbol, tracking: 0, after: symbolGap).minor(minorFont, minorColor)
            + spaced(integer, tracking: tracking, after: tracking + fractionGap)
            + Text(style.part(.fraction).format(value)).minor(minorFont, minorColor)
    }

    /** `text` with `tracking` between its glyphs and `after` behind its last one. */
    private func spaced(_ text: String, tracking: CGFloat, after: CGFloat) -> Text {
        guard let last = text.last else { return Text(text) }
        return Text(String(text.dropLast())).tracking(tracking) + Text(String(last)).tracking(after)
    }

    /** What VoiceOver reads: the number in the reader's locale, then "rupiah" ("1.840.000 rupiah"). */
    private var spoken: Text {
        let number = Text(value, format: .number.precision(.fractionLength(0...2)))
        return Text("ds.amount.spoken \(number)")
    }

    private var mainSize: CGFloat {
        switch size {
        case .small: 17
        case .medium: 20
        case .large: 34
        case .extraLarge: 42
        }
    }

    /** The size of "Rp" and ",00": the amount's from small, 0.55 of it from medium up. */
    private var minorSize: CGFloat { size == .small ? mainSize : mainSize * 0.55 }

    /** The space after "Rp": none at small, 0.14 of its own size from medium up. */
    private var symbolGap: CGFloat { size == .small ? 0 : minorSize * 0.14 }

    /** The space before ",00": none at small, 0.03 of its own size from medium up. */
    private var fractionGap: CGFloat { size == .small ? 0 : minorSize * 0.03 }

    private var tracking: CGFloat {
        switch size {
        case .small: 0
        case .medium: -0.2
        case .large: -0.68
        case .extraLarge: -1.26
        }
    }

    private var mainFont: Font {
        switch size {
        case .small: .headline.monospacedDigit()
        case .medium: KiraFont.display(20, .heavy, relativeTo: .title3).monospacedDigit()
        case .large: KiraFont.display(34, .heavy, relativeTo: .largeTitle).monospacedDigit()
        case .extraLarge: KiraFont.display(42, .heavy, relativeTo: .largeTitle).monospacedDigit()
        }
    }

    /**
     "Rp" and ",00" at 0.55 of the amount, Bold, as `.k-amount__cur` and `.k-amount__dec` draw
     them (11, 18.7 and 23.1 pt), scaled like Title 3.
     */
    private var minorFont: Font? {
        if size == .small { return nil }
        return KiraFont.display(minorSize, .bold, relativeTo: .title3)
    }

    private var mainColor: Color {
        if isInverse { return .onHero }
        return isMuted ? .inkMuted : .ink
    }

    private var minorColor: Color? {
        if size == .small { return nil }
        return isInverse ? .onHeroMuted : .inkMuted
    }

    /** The same amount, hidden as "Rp ••••••" when `isMasked` is true. */
    func masked(_ isMasked: Bool = true) -> Self { copy { $0.isMasked = isMasked } }

    /** The same amount with its sign always shown: "+Rp25.000,00", "−Rp25.000,00". */
    func signed() -> Self { copy { $0.isSigned = true } }

    /** The same amount in ink-muted, for a secondary figure. */
    func muted() -> Self { copy { $0.isMuted = true } }

    /** The same amount in white, for the hero card. */
    func inverse() -> Self { copy { $0.isInverse = true } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var amount = self
        change(&amount)
        return amount
    }
}

extension Text {
    /** The smaller, muted "Rp" and ",00" of an amount from md up; unchanged at sm. */
    fileprivate func minor(_ font: Font?, _ color: Color?) -> Text {
        guard let font, let color else { return self }
        return self.font(font).foregroundStyle(color)
    }
}

#if DEBUG
    #Preview { GalleryAmounts().galleryPage() }
#endif
