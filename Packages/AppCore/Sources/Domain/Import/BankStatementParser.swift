/**
 Reads a bank statement CSV on the device (CAT-11): the header `tanggal,keterangan,nominal`, then
 one row per transaction with the date as `YYYY-MM-DD` and a signed whole-rupiah amount without
 dots or "Rp". Spreadsheets that save with semicolons are read the same. At most three months
 (92 days) per file. The file itself is never kept: only the parsed rows leave this function.
 */
import Foundation

/** Parses the three-column statement format. */
package enum BankStatementParser {
    /** The header, in order. */
    package static let columns = ["tanggal", "keterangan", "nominal"]
    /** The largest file read, in bytes. */
    package static let maximumBytes = 1_048_576
    /** The most rows one import takes. */
    package static let maximumRows = 2_000
    /** The longest span from the first day to the last, in days. */
    package static let maximumRangeDays = 92

    /** The statement in `data`, or the first reason it cannot be read. */
    package static func parse(_ data: Data) throws(BankStatementError) -> BankStatement {
        guard data.count <= maximumBytes else { throw .tooLarge }
        guard var text = String(data: data, encoding: .utf8), !text.contains("\u{0}") else { throw .notText }
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
        let lines = text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).enumerated()
            .map { (number: $0.offset + 1, text: $0.element) }
            .filter { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let header = lines.first else { throw .empty }
        let separator = try separator(of: header.text)
        var rows: [StatementRow] = []
        for line in lines.dropFirst() {
            rows.append(try row(line.text, number: line.number, separator: separator))
        }
        guard let first = rows.map(\.day).min(), let last = rows.map(\.day).max() else { throw .empty }
        guard rows.count <= maximumRows else { throw .tooManyRows }
        guard first.days(to: last) <= maximumRangeDays else { throw .rangeTooLong }
        return BankStatement(rows: rows, dateFrom: first, dateTo: last)
    }

    /** The column separator the header uses: a comma, or a semicolon. */
    private static func separator(of header: Substring) throws(BankStatementError) -> Character {
        for separator: Character in [",", ";"] {
            let names = CSVLine.fields(header, separator: separator).map {
                $0.trimmingCharacters(in: .whitespaces).lowercased()
            }
            if names == columns { return separator }
        }
        throw .wrongHeader
    }

    /** One row, checked column by column. */
    private static func row(_ text: Substring, number: Int, separator: Character) throws(BankStatementError)
        -> StatementRow
    {
        let fields = CSVLine.fields(text, separator: separator).map { $0.trimmingCharacters(in: .whitespaces) }
        guard fields.count == columns.count else { throw .wrongColumnCount(line: number) }
        guard let day = CalendarDay(iso: fields[0]) else { throw .invalidDate(line: number) }
        guard !fields[1].isEmpty else { throw .missingDescription(line: number) }
        guard let amount = amount(fields[2]), amount != 0 else { throw .invalidAmount(line: number) }
        return StatementRow(
            line: number, day: day, description: AccountNumberMask.masked(fields[1]), amount: amount)
    }

    /** A signed whole number of rupiah: "-22000", "+7500000", "7500000"; nil for anything else. */
    private static func amount(_ text: String) -> Int? {
        var digits = Substring(text)
        var sign = 1
        if let first = digits.first, first == "-" || first == "+" {
            sign = first == "-" ? -1 : 1
            digits = digits.dropFirst()
        }
        guard !digits.isEmpty, digits.count <= 13, digits.allSatisfy({ $0.isASCII && $0.isNumber }),
            let value = Int(digits)
        else { return nil }
        return sign * value
    }
}

/** Splits one CSV line into its fields, honouring double quotes ("a, b" and "" for a quote). */
package enum CSVLine {
    /** The fields of `line`, split at `separator` outside quotes. */
    package static func fields(_ line: Substring, separator: Character = ",") -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var characters = line.makeIterator()
        var pending = characters.next()
        while let character = pending {
            pending = characters.next()
            if inQuotes, character == "\"", pending == "\"" {
                current.append("\"")
                pending = characters.next()
            } else if character == "\"" {
                inQuotes.toggle()
            } else if character == separator, !inQuotes {
                fields.append(current)
                current = ""
            } else {
                current.append(character)
            }
        }
        fields.append(current)
        return fields
    }
}
