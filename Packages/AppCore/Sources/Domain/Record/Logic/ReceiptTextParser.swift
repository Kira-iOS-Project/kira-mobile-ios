import Foundation

/**
 Reads a receipt from the lines Vision recognised on the device (CAT-06): the store from its head,
 each item with its amount, discounts taken off the item above them, and the printed TOTAL. Lines
 after the total (payment, change) are not items. Account and card numbers in the names, the only
 text that leaves the device, are masked.
 */
package enum ReceiptTextParser {
    /**
     The receipt's reading, or nil when neither an item nor a printed total was found. A total
     without items still reads, with no items, so the scan never fails on a receipt whose total OCR saw.
     */
    package static func read(_ lines: [String]) -> ReceiptReading? {
        let lines = lines.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var receipt = ReceiptItems()
        for line in lines where receipt.total == nil {
            receipt.add(ReceiptLineKind.of(line))
        }
        guard !receipt.items.isEmpty || receipt.total != nil else { return nil }
        return ReceiptReading(
            storeName: storeName(in: lines), printedAt: printedDate(in: lines), items: receipt.items,
            total: receipt.total ?? receipt.items.map(\.amount).reduce(0, +))
    }

    /** An item's name: a line printed in capitals is written in Title Case, any other as printed. */
    static func itemName(_ label: String) -> String {
        let label = SensitiveNumbers.masked(label)
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
        return name.map { itemName($0.uppercased()) }
    }

    /** The printed date ("15-10-2026", "15/10/26") and the time on its line or any line ("12:58"). */
    static func printedDate(in lines: [String]) -> ReceiptDate? {
        let timePattern = /(?:^|\D)(?<hour>\d{1,2}):(?<minute>\d{2})(?!\d)/
        for line in lines {
            guard let date = day(in: line) else { continue }
            let time = ([line] + lines).lazy.compactMap { $0.firstMatch(of: timePattern) }.first { match in
                Int(match.hour).map { $0 < 24 } == true && Int(match.minute).map { $0 < 60 } == true
            }
            return ReceiptDate(
                day: date.day, month: date.month, year: date.year, hour: time.flatMap { Int($0.hour) },
                minute: time.flatMap { Int($0.minute) })
        }
        return nil
    }

    /** The day, month and four-digit year of a printed date on `line`, when it is a real one. */
    private static func day(in line: String) -> ReceiptDate? {
        let pattern = /(?<day>\d{1,2})[\-\/.](?<month>\d{1,2})[\-\/.](?<year>\d{4}|\d{2})(?!\d)/
        guard let date = line.firstMatch(of: pattern), let day = Int(date.day), let month = Int(date.month),
            let year = Int(date.year), (1...31).contains(day), (1...12).contains(month)
        else { return nil }
        return ReceiptDate(day: day, month: month, year: year < 100 ? 2000 + year : year)
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
            if let pendingName {
                items.append(ReceiptLine(name: ReceiptTextParser.itemName(pendingName), amount: amount))
            }
            pendingName = nil
        case .text(let text):
            pendingName = text
        case .amount(let amount):
            if let pendingName { addPriced(pendingName, amount) }
            pendingName = nil
        case .blank:
            break
        }
    }

    private mutating func addPriced(_ label: String, _ amount: Int) {
        if ReceiptWords.label(label, isIn: ReceiptWords.subtotals) { return }
        /** "TOTAL BAYAR" is the total even though "bayar" is a payment word: a total phrase wins. */
        let isPayment = ReceiptWords.label(label, isIn: ReceiptWords.payments)
        let isPaymentOrCharge = isPayment || ReceiptWords.label(label, isIn: ReceiptWords.charges)
        if ReceiptWords.isTotal(label) {
            total = abs(amount)
        } else if isPaymentOrCharge {
            return
        } else if ReceiptWords.label(label, isIn: ReceiptWords.discounts) {
            if !items.isEmpty { items[items.count - 1].amount -= abs(amount) }
        } else if amount < 0 {
            /** A minus without a discount word is a tax number's dash ("01.234.567.8-901.000"), not an item. */
            return
        } else {
            items.append(ReceiptLine(name: ReceiptTextParser.itemName(label), amount: amount))
        }
    }
}
