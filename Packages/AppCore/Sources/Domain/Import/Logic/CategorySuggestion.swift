/**
 The category an imported row starts with (CAT-12: "Kategori diisi otomatis"), chosen on the device
 from a keyword table: the first entry whose keyword appears as whole words in the description
 wins, so specific entries ("grabfood", "bpjs ketenagakerjaan") come before general ones ("grab",
 "bpjs"). The bank's merchants and the board's choices (BPJS Kesehatan is Kesehatan) come first;
 a description they miss falls back to Catat's own keywords (`CategoryKeywords`), when those name a
 category of the row's direction. The person can change it on the review screen before saving.
 */

/** Suggests a category for a statement row. */
package enum CategorySuggestion {
    /** The category for a row described as `description` that went `type`'s way. */
    package static func category(for description: String, type: TransactionType) -> TransactionCategory {
        let tokens = description.lowercased().split { !($0.isLetter || $0.isNumber) }.map(String.init)
        let words = " " + tokens.joined(separator: " ") + " "
        let table = type == .expense ? expenseTable : incomeTable
        if let match = table.first(where: { entry in entry.keywords.contains { words.contains(" \($0) ") } }) {
            return match.category
        }
        if let known = CategoryKeywords.category(of: tokens), known.type == type { return known }
        return type == .expense ? .otherExpense : .otherIncome
    }

    private typealias Entry = (category: TransactionCategory, keywords: [String])

    private static let expenseTable: [Entry] = [
        (.food, ["gofood", "grabfood", "shopeefood", "makan", "resto", "restoran", "warteg", "warung", "bakso"]),
        (.coffee, ["kopi", "coffee", "starbucks", "janji jiwa", "kopi kenangan", "fore", "tomoro"]),
        (.food, ["nasi", "ayam", "mie", "pizza", "mcd", "mcdonalds", "kfc", "hokben", "sate", "roti", "bakery"]),
        (.transport, ["grab", "gojek", "gocar", "goride", "maxim", "bensin", "pertamina", "shell", "spbu"]),
        (.transport, ["parkir", "tol", "krl", "mrt", "lrt", "transjakarta", "kai", "kereta", "taksi", "ojek"]),
        (.paylaterInstalment, ["paylater", "spaylater", "kredivo", "akulaku", "indodana", "cicilan", "angsuran"]),
        (.insurance, ["bpjs ketenagakerjaan", "asuransi", "prudential", "allianz", "axa", "manulife", "premi"]),
        (.health, ["bpjs kesehatan", "bpjs", "apotek", "apotik", "dokter", "klinik", "rumah sakit", "obat"]),
        (.bills, ["listrik", "pln", "token", "internet", "indihome", "biznet", "pulsa", "paket data", "pdam"]),
        (.bills, ["telkomsel", "indosat", "smartfren", "tagihan", "iuran"]),
        (.savingsDeposit, ["tabungan", "deposito", "reksadana", "bibit", "investasi", "emas"]),
        (.education, ["sekolah", "kuliah", "spp", "ukt", "kursus", "les", "buku"]),
        (.entertainment, ["netflix", "spotify", "youtube", "disney", "vidio", "bioskop", "cgv", "xxi", "konser"]),
        (.shopping, ["indomaret", "alfamart", "alfamidi", "tokopedia", "shopee", "lazada", "blibli", "belanja"]),
        (.shopping, ["supermarket", "superindo", "hypermart", "transmart", "uniqlo"]),
        (.household, ["laundry", "lpg", "galon", "kos", "sewa", "kontrakan"]),
    ]

    private static let incomeTable: [Entry] = [
        (.salary, ["gaji", "salary", "payroll", "upah"]),
        (.bonus, ["bonus", "thr", "insentif", "komisi"]),
        (.business, ["penjualan", "jualan", "usaha", "toko", "omzet"]),
    ]
}
