import Foundation
import Testing

@testable import Domain

@Suite("BankStatementParser")
struct BankStatementParserTests {
    private func parse(_ text: String) throws(BankStatementError) -> BankStatement {
        try BankStatementParser.parse(Data(text.utf8))
    }

    @Test("reads the sample file the screen offers")
    func sample() throws {
        let statement = try parse(StatementTemplate.text)
        #expect(statement.rows.count == 3)
        #expect(
            statement.rows[0]
                == StatementRow(
                    day: CalendarDay(year: 2026, month: 9, day: 26), description: "Kopi Susu", amount: -22_000)
        )
        #expect(statement.rows[0].type == .expense)
        #expect(statement.rows[2].type == .income)
        #expect(statement.dateFrom == CalendarDay(year: 2026, month: 9, day: 26))
        #expect(statement.dateTo == CalendarDay(year: 2026, month: 9, day: 30))
    }

    @Test("reads semicolons, quotes, a byte-order mark, CRLF, blank lines and a plus sign")
    func spreadsheetExport() throws {
        let text = "\u{FEFF}Tanggal;Keterangan;Nominal\r\n\r\n2026-09-01;\"Toko \"\"Maju\"\"; Jaya\";+150000\r\n"
        let statement = try parse(text)
        #expect(
            statement.rows == [
                StatementRow(
                    day: CalendarDay(year: 2026, month: 9, day: 1), description: "Toko \"Maju\"; Jaya",
                    amount: 150_000)
            ])
    }

    @Test("masks account numbers before anything else sees them")
    func masks() throws {
        let statement = try parse("tanggal,keterangan,nominal\n2026-09-01,TRF 1234 5678 9012 BUDI,-50000\n")
        #expect(statement.rows[0].description == "TRF ••••9012 BUDI")
    }

    @Test(
        "refuses a file with the reason to fix",
        arguments: [
            ("", BankStatementError.empty),
            ("tanggal,keterangan,nominal\n", .empty),
            ("date,description,amount\n2026-09-01,Kopi,-1\n", .wrongHeader),
            ("tanggal,keterangan\n", .wrongHeader),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi\n", .wrongColumnCount(line: 2)),
            ("tanggal,keterangan,nominal\n01/09/2026,Kopi,-1\n", .invalidDate(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01, ,-1\n", .missingDescription(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi,-22.000\n", .invalidAmount(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi,Rp22000\n", .invalidAmount(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi,0\n", .invalidAmount(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi,-\n", .invalidAmount(line: 2)),
            ("tanggal,keterangan,nominal\n2026-09-01,Kopi,12345678901234\n", .invalidAmount(line: 2)),
            ("tanggal,keterangan,nominal\n2026-06-01,Kopi,-1\n2026-09-02,Kopi,-1\n", .rangeTooLong),
            ("tanggal,keterangan,nominal\n2026-07-01,Kopi,-1\n2026-10-01,Kopi,-1\n", .rangeTooLong),
        ])
    func refuses(text: String, error: BankStatementError) {
        #expect(throws: error) { try parse(text) }
    }

    @Test("allows 92 calendar days, the first and last counted, as the backend does; 93 is refused above")
    func longestRange() throws {
        let statement = try parse("tanggal,keterangan,nominal\n2026-07-01,A,-1\n2026-09-30,B,-1\n")
        #expect(statement.dateFrom.days(to: statement.dateTo) + 1 == 92)
    }

    @Test("refuses files that are not text, too large or too long")
    func limits() {
        #expect(throws: BankStatementError.notText) { try BankStatementParser.parse(Data([0xFF, 0xFE, 0x00])) }
        #expect(throws: BankStatementError.notText) { try BankStatementParser.parse(Data([0x61, 0x00, 0x62])) }
        let large = Data(count: BankStatementParser.maximumBytes + 1)
        #expect(throws: BankStatementError.tooLarge) { try BankStatementParser.parse(large) }
        let rows = Array(repeating: "2026-09-01,Kopi,-1", count: BankStatementParser.maximumRows + 1)
        #expect(throws: BankStatementError.tooManyRows) {
            try parse((["tanggal,keterangan,nominal"] + rows).joined(separator: "\n"))
        }
    }

    @Test("splits CSV fields, keeping separators inside quotes")
    func csvLine() {
        #expect(CSVLine.fields("a,\"b,c\",d") == ["a", "b,c", "d"])
        #expect(CSVLine.fields("\"say \"\"hi\"\"\",x") == ["say \"hi\"", "x"])
        #expect(CSVLine.fields("") == [""])
        #expect(CSVLine.fields("a;b", separator: ";") == ["a", "b"])
    }
}

@Suite("SensitiveNumbers in bank statements")
struct StatementMaskingTests {
    @Test(
        "keeps the last four digits of long numbers only",
        arguments: [
            ("TRF 1234567890 BUDI", "TRF ••••7890 BUDI"), ("KARTU 4111-1111-1111-1234", "KARTU ••••1234"),
            ("Kopi Susu", "Kopi Susu"), ("INV 1234567", "INV 1234567"),
            ("A 12345678 B 87654321", "A ••••5678 B ••••4321"),
        ])
    func masked(text: String, shown: String) {
        #expect(SensitiveNumbers.masked(text, minimumDigits: 8) == shown)
    }
}

@Suite("CategorySuggestion")
struct CategorySuggestionTests {
    @Test(
        "matches whole words, specific entries first",
        arguments: [
            ("Belanja Bulanan", TransactionType.expense, TransactionCategory.shopping),
            ("Internet Bulanan", .expense, .bills), ("Token Listrik", .expense, .bills),
            ("Makan Malam", .expense, .food), ("BPJS Kesehatan", .expense, .health),
            ("BPJS Ketenagakerjaan", .expense, .insurance), ("Bensin", .expense, .transport),
            ("GRABFOOD*Nasi Padang", .expense, .food), ("Grab ke Kantor", .expense, .transport),
            ("Kopi Susu", .expense, .coffee), ("Nasi Goreng", .expense, .food), ("Netflix", .expense, .entertainment),
            ("Kredivo", .expense, .paylaterInstalment), ("Reksadana", .expense, .savingsDeposit),
            ("SPP Sekolah", .expense, .education), ("Laundry", .expense, .household),
            ("Telkomsel", .expense, .bills), ("Uniqlo", .expense, .shopping), ("Parkir Mal", .expense, .transport),
            ("Sesuatu", .expense, .otherExpense), ("Gaji", .income, .salary), ("THR", .income, .bonus),
            ("Penjualan Online", .income, .business), ("Transfer dari Ibu", .income, .otherIncome),
            ("Transfer Tolong", .expense, .otherExpense), ("Martabak Manis", .expense, .food),
            ("Gajian Kantor", .expense, .otherExpense),
        ])
    func suggests(description: String, type: TransactionType, category: TransactionCategory) {
        #expect(CategorySuggestion.category(for: description, type: type) == category)
    }
}

@Suite("StatementImport")
struct StatementImportTests {
    @Test("sends each row with its sign and a suggested category")
    func upload() throws {
        let statement = try BankStatementParser.parse(Data(StatementTemplate.text.utf8))
        let upload = ImportUpload(statement: statement, fileName: "mutasi.csv", fileSize: 120)
        #expect(upload.fileName == "mutasi.csv" && upload.fileSize == 120)
        #expect(upload.rows.map(\.category) == [.coffee, .food, .salary])
        #expect(upload.rows.map(\.amount) == [-22_000, -27_000, 7_500_000])
        #expect(upload.rows[0].description == "Kopi Susu" && upload.rows[0].day.iso == "2026-09-26")
        let result = ImportCommitResult(savedCount: 39, skippedCount: 3)
        #expect(result.savedCount == 39 && result.skippedCount == 3)
        #expect(ImportCommitRow(id: "r1", category: .food).category == .food)
        #expect(StatementTemplate.fileName.hasSuffix(".csv"))
    }
}
