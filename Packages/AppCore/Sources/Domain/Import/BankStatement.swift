/**
 A bank statement as Impor Mutasi (CAT-11) reads it from a CSV file on the device, and the reasons
 a file is refused. Each reason names what to fix, so the screen can say how.
 */

/** One row of the file: a day, what the bank wrote, and the signed amount. */
package struct StatementRow: Hashable, Sendable {
    /** The row's line in the file, counting the header as line 1. */
    package let line: Int
    /** The row's date. */
    package let day: CalendarDay
    /** The bank's description with account numbers masked. */
    package let description: String
    /** Whole rupiah; negative for money out. */
    package let amount: Int

    /** A row with the given fields. */
    package init(line: Int, day: CalendarDay, description: String, amount: Int) {
        self.line = line
        self.day = day
        self.description = description
        self.amount = amount
    }

    /** Money out for a negative amount, money in otherwise. */
    package var type: TransactionType { amount < 0 ? .expense : .income }
}

/** The rows of a file that passed every check, and the days they span. */
package struct BankStatement: Hashable, Sendable {
    /** The rows, in the file's order. */
    package let rows: [StatementRow]
    /** The earliest day of the rows. */
    package let dateFrom: CalendarDay
    /** The latest day of the rows. */
    package let dateTo: CalendarDay
}

/** Why a file cannot be imported. */
package enum BankStatementError: Error, Hashable, Sendable {
    /** The file is not text (a PDF, a spreadsheet, a picture). */
    case notText
    /** The file is larger than a three-month statement can be. */
    case tooLarge
    /** The file holds no row under its header. */
    case empty
    /** The first line is not `tanggal,keterangan,nominal`. */
    case wrongHeader
    /** A row has more or fewer than three columns. */
    case wrongColumnCount(line: Int)
    /** A row's date is not written year-month-day, or is not a real date. */
    case invalidDate(line: Int)
    /** A row's amount has dots, "Rp", a decimal comma, or is zero. */
    case invalidAmount(line: Int)
    /** A row has no description. */
    case missingDescription(line: Int)
    /** The rows span more than three months. */
    case rangeTooLong
    /** The file has more rows than one import takes. */
    case tooManyRows
}
