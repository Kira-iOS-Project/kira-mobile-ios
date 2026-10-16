import Foundation

/**
 Reads a receipt from the lines Vision recognised on the device (CAT-06): the store from its head,
 each item with its amount, discounts taken off the item above them, and the printed TOTAL. Lines
 after the total (payment, change) are not items. Account and card numbers are masked first.
 */
package enum ReceiptTextParser {
    /** The receipt's reading, or nil when no item with an amount was found. */
    package static func read(_ lines: [String]) -> ReceiptReading? {
        let lines = lines.map { SensitiveNumbers.masked($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        var receipt = ReceiptItems()
        for line in lines where receipt.total == nil {
            receipt.add(ReceiptLineKind.of(line))
        }
        guard !receipt.items.isEmpty else { return nil }
        return ReceiptReading(
            storeName: storeName(in: lines), printedAt: printedDate(in: lines), items: receipt.items,
            total: receipt.total ?? receipt.items.map(\.amount).reduce(0, +))
    }

    /** An item's name: a line printed in capitals is written in Title Case, any other as printed. */
    static func itemName(_ label: String) -> String {
        let words = label.split(separator: " ").map(String.init)
        guard label == label.uppercased() else { return words.joined(separator: " ") }
        return NameCasing.titleCased(words, keepsAcronyms: false)
    }

    /** The first of the three head lines that reads as a name: letters, no amount, no address. */
    static func storeName(in lines: [String]) -> String? {
        let name = lines.prefix(3).first { line in
            let lower = line.lowercased()
            guard line.filter(\.isLetter).count >= 3, case .text = ReceiptLineKind.of(line) else { return false }
            return !ReceiptWords.notStore.contains { lower.hasPrefix($0) }
        }
        return name.map { NameCasing.titleCased($0.split(separator: " ").map(String.init), keepsAcronyms: false) }
    }

    /** The printed date ("15-10-2026", "15/10/26") and the time on its line or any line ("12:58"). */
    static func printedDate(in lines: [String]) -> ReceiptDate? {
        let datePattern = /(?<day>\d{1,2})[\-\/.](?<month>\d{1,2})[\-\/.](?<year>\d{4}|\d{2})(?!\d)/
        let timePattern = /(?:^|\D)(?<hour>\d{1,2}):(?<minute>\d{2})(?!\d)/
        for line in lines {
            guard let date = line.firstMatch(of: datePattern), let day = Int(date.day), let month = Int(date.month),
                let rawYear = Int(date.year), (1...31).contains(day), (1...12).contains(month)
            else { continue }
            let year = rawYear < 100 ? 2000 + rawYear : rawYear
            let time = ([line] + lines).lazy.compactMap { $0.firstMatch(of: timePattern) }.first { match in
                (Int(match.hour) ?? 99) < 24 && (Int(match.minute) ?? 99) < 60
            }
            return ReceiptDate(
                day: day, month: month, year: year, hour: time.flatMap { Int($0.hour) },
                minute: time.flatMap { Int($0.minute) })
        }
        return nil
    }
}

/** The items read so far, the name waiting for its quantity line, and the total once found. */
struct ReceiptItems {
    private(set) var items: [ReceiptLine] = []
    private(set) var total: Int?
    private var pendingName: String?

    mutating func add(_ kind: ReceiptLineKind) {
        switch kind {
        case .priced(let label, let amount):
            addPriced(label, amount)
            pendingName = nil
        case .quantity(let amount):
            if let pendingName { items.append(ReceiptLine(name: ReceiptTextParser.itemName(pendingName), amount: amount)) }
            pendingName = nil
        case .text(let text):
            pendingName = text
        case .blank:
            break
        }
    }

    private mutating func addPriced(_ label: String, _ amount: Int) {
        if ReceiptWords.label(label, isIn: ReceiptWords.subtotals) || ReceiptWords.label(label, isIn: ReceiptWords.payments) {
            return
        }
        if ReceiptWords.label(label, isIn: ReceiptWords.totals) {
            total = amount
        } else if ReceiptWords.label(label, isIn: ReceiptWords.discounts) {
            if !items.isEmpty { items[items.count - 1].amount -= abs(amount) }
        } else {
            items.append(ReceiptLine(name: ReceiptTextParser.itemName(label), amount: amount))
        }
    }
}
