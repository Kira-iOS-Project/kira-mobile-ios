/**
 Amount (design system): rupiah in full with two decimals and tabular figures, "Rp1.840.000,00".
 From md up, "Rp" and ",00" are smaller and muted so the whole rupiah reads first. It never wraps:
 put a big amount on its own line with its words in a small label above. Income and spending are
 told apart by the sign (`.signed()`) and a label, never by green and red. Every balance can be
 hidden (`.masked(_:)`): "Rp ••••••", read by VoiceOver as "Nominal disembunyikan".
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
    }

    private let value: Decimal
    private let size: Size
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
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(value, format: style.part(.sign))
            Text(value, format: style.part(.symbol)).minor(minorFont, minorColor)
                .padding(.trailing, symbolGap)
            Text(value, format: style.part(.integer)).tracking(tracking)
            Text(value, format: style.part(.fraction)).minor(minorFont, minorColor)
        }
        .font(mainFont)
        .foregroundStyle(mainColor)
        /** One line always; at the largest text sizes a long amount shrinks to fit instead. */
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isMasked ? Text("ds.amount.hidden") : spoken)
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

    /** The space after "Rp": none at small, a little from medium up, a word space before the mask. */
    private var symbolGap: CGFloat {
        if isMasked { return mainSize * 0.25 }
        return size == .small ? 0 : mainSize * 0.14
    }

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
     "Rp" and ",00" at 0.55 of the amount, as the design system draws them, but never under
     13 pt, and scaled like Title 3: Apple's audit reports smaller text, and these sizes scaled
     like Large Title, as only partly following Dynamic Type.
     */
    private var minorFont: Font? {
        if size == .small { return nil }
        return KiraFont.display(max(13, mainSize * 0.55), .bold, relativeTo: .title3)
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
