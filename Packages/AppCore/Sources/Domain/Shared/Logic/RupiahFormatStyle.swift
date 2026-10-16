/**
 Kira writes money one way: in full, with two decimals, "Rp10.000,00" (the design system's
 formatRupiah). The format is a product rule, not a regional preference: Kira shows Indonesian
 money to Indonesian readers, so it groups with "." and writes the cents after ",", whatever region
 the device is set to. Views format with it as with any FormatStyle: `Text(amount, format: .rupiah)`.
 */
import Foundation

/** Writes a rupiah amount in full with two decimals: `Rp10.000,00`, `−Rp1.250.000,00`. */
package struct RupiahFormatStyle: FormatStyle {
    /** The piece of the written amount the style returns, for views that size the pieces apart. */
    package enum Part: Codable, Hashable, Sendable {
        /** The whole amount: `−Rp10.000,00`, or `Rp ••••••` while hidden. */
        case whole
        /** The sign alone: `−`, `+` or nothing. */
        case sign
        /** The currency symbol: `Rp`. */
        case symbol
        /** The whole rupiah, grouped with dots: `10.000`, or the mask while hidden. */
        case integer
        /** The decimal comma and the two cents digits: `,00`. */
        case fraction
    }

    /** When the amount carries a sign. */
    package enum SignDisplay: Codable, Hashable, Sendable {
        /** Only below zero: `−Rp10.000,00`. */
        case automatic
        /** Always, so money in and money out read apart: `+Rp10.000,00`, `−Rp10.000,00`. */
        case always
    }

    /** The symbol written before the digits. */
    package static let symbol = "Rp"
    /** What stands for the digits while balances are hidden. */
    package static let mask = "••••••"

    /** The piece the style returns; `.whole` unless set. */
    package var part = Part.whole
    /** When the sign shows; `.automatic` unless set. */
    package var signDisplay = SignDisplay.automatic
    /** Whether the digits are hidden, for "Sembunyikan saldo". */
    package var isMasked = false

    /** The whole amount, with a sign only below zero. */
    package init() {}

    /** The amount, rounded half away from zero to two decimals, written as `part` asks. */
    package func format(_ value: Decimal) -> String {
        if isMasked {
            switch part {
            case .whole: return "\(Self.symbol) \(Self.mask)"
            case .symbol: return Self.symbol
            case .integer: return Self.mask
            case .sign, .fraction: return ""
            }
        }
        let digits = Digits(value, signDisplay: signDisplay)
        switch part {
        case .whole: return digits.sign + Self.symbol + digits.integer + digits.fraction
        case .sign: return digits.sign
        case .symbol: return Self.symbol
        case .integer: return digits.integer
        case .fraction: return digits.fraction
        }
    }

    /** The same style, returning one piece of the amount. */
    package func part(_ part: Part) -> Self {
        var style = self
        style.part = part
        return style
    }

    /** The same style, showing the sign as asked. */
    package func sign(_ display: SignDisplay) -> Self {
        var style = self
        style.signDisplay = display
        return style
    }

    /** The same style, with the digits hidden when `isMasked` is true. */
    package func masked(_ isMasked: Bool = true) -> Self {
        var style = self
        style.isMasked = isMasked
        return style
    }
}

extension FormatStyle where Self == RupiahFormatStyle {
    /** Rupiah in full with two decimals: `Text(amount, format: .rupiah)` shows `Rp10.000,00`. */
    package static var rupiah: RupiahFormatStyle { RupiahFormatStyle() }
}

/** The written pieces of one amount. */
private struct Digits {
    let sign: String
    let integer: String
    let fraction: String

    init(_ value: Decimal, signDisplay: RupiahFormatStyle.SignDisplay) {
        var exact = value
        var rounded = Decimal()
        NSDecimalRound(&rounded, &exact, 2, .plain)
        if rounded < 0 {
            sign = "\u{2212}"
        } else {
            sign = signDisplay == .always ? "+" : ""
        }
        /** Decimal's description is locale-free ("1234.5"), so it is split, never parsed. */
        let pieces = rounded.magnitude.description.split(separator: ".", omittingEmptySubsequences: false)
        integer = Self.grouped(pieces[0])
        let cents = pieces.count > 1 ? pieces[1] : ""
        fraction = "," + (cents + "00").prefix(2)
    }

    /** Digits grouped by three from the right with dots: "1250000" becomes "1.250.000". */
    private static func grouped(_ digits: Substring) -> String {
        var out = ""
        for (index, digit) in digits.enumerated() {
            if index > 0, (digits.count - index).isMultiple(of: 3) {
                out.append(".")
            }
            out.append(digit)
        }
        return out
    }
}
