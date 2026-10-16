/**
 The vocabulary of amounts in Indonesian chat: digits with a unit ("25rb", "1,5jt", "30k"),
 number words ("dua puluh ribu", "sejuta", "satu setengah juta") and slang ("goceng", "gocap").
 Each token reads as a short list of atoms that `AmountReader` combines.
 */

/** One piece of an amount. */
enum AmountAtom: Equatable {
    /** A count: digits or a number word ("25", "1,5", "lima", "sebelas"). */
    case number(Double)
    /** "puluh" (×10) or "ratus" (×100) after a count. */
    case multiplier(Double)
    /** "belas": the count plus ten. */
    case teen
    /** "ribu", "juta", "miliar" and their short forms. */
    case scale(Double)
    /** "setengah": a half of the next scale, or of the scale before it ("sejuta setengah"). */
    case half
    /** A slang word that is a whole amount on its own ("goceng" is Rp5.000,00). */
    case whole(Double)
}

enum AmountWords {
    static let units: [String: Double] = [
        "satu": 1, "dua": 2, "tiga": 3, "empat": 4, "lima": 5, "enam": 6, "tujuh": 7, "delapan": 8,
        "sembilan": 9, "sepuluh": 10, "sebelas": 11,
    ]

    static let scales: [String: Double] = [
        "ribu": 1_000, "rebu": 1_000, "rb": 1_000, "k": 1_000, "juta": 1_000_000, "jt": 1_000_000,
        "miliar": 1_000_000_000, "milyar": 1_000_000_000,
    ]

    /**
     Chinese-Indonesian slang. "Gocap" and "cepek" were once Rp50 and Rp100; today they mean 50 and
     100 thousand, since those coins no longer buy anything.
     */
    static let slang: [String: Double] = [
        "seceng": 1_000, "ceceng": 1_000, "noceng": 2_000, "goceng": 5_000, "ceban": 10_000,
        "goban": 50_000, "gocap": 50_000, "cepek": 100_000,
    ]

    /** Words that may follow a slang amount without changing it: "cepek ceng". */
    static let slangTails: Set<String> = ["ceng", "rebu", "ribu"]

    /** The atoms of one lower-cased token, or none when the token is not part of an amount. */
    static func atoms(of token: String) -> [AmountAtom] {
        if let value = units[token] { return [.number(value)] }
        if let value = scales[token] { return [.scale(value)] }
        if let value = slang[token] { return [.whole(value)] }
        switch token {
        case "puluh": return [.multiplier(10)]
        case "ratus": return [.multiplier(100)]
        case "seratus": return [.number(1), .multiplier(100)]
        case "belas": return [.teen]
        case "setengah", "stgh": return [.half]
        case "seribu": return [.number(1), .scale(1_000)]
        case "sejuta": return [.number(1), .scale(1_000_000)]
        default: return digitAtoms(of: token)
        }
    }

    /** "25rb" is a count and a scale; "rp25.000" a count; "25" a count; "20rb-an" about 20rb. */
    private static func digitAtoms(of token: String) -> [AmountAtom] {
        let body = token.hasPrefix("rp") ? String(token.dropFirst(2)) : token
        let digits = String(body.prefix { $0.isASCIIDigit || $0 == "." || $0 == "," })
        guard let value = NumberText.value(of: digits) else { return [] }
        var unit = String(body.dropFirst(digits.count))
        if unit.hasSuffix("-an") { unit.removeLast(3) }
        if unit.isEmpty { return [.number(value)] }
        guard let scale = scales[unit] else { return [] }
        return [.number(value), .scale(scale)]
    }
}
