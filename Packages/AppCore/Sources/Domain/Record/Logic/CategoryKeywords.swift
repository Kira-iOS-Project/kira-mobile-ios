/**
 The keyword table that guesses a draft's category and direction from its words. The person
 confirms every draft, and the pencil changes a wrong guess; nothing here is remembered.
 */
package enum CategoryKeywords {
    /** Two-word phrases, checked before single words: "rumah sakit" is health, not household. */
    static let phrases: [String: TransactionCategory] = [
        "rumah sakit": .health, "paket data": .bills, "rumah tangga": .household,
        "kopi susu": .coffee, "es kopi": .coffee, "uang kos": .bills, "bayar kos": .bills,
    ]

    /** Single words, by category. */
    static let words: [TransactionCategory: Set<String>] = [
        .food: [
            "makan", "nasi", "bakso", "mie", "mi", "soto", "sate", "ayam", "warteg", "padang", "sarapan",
            "gorengan", "martabak", "jajan", "snack", "camilan", "roti", "seblak", "pecel", "gado-gado",
            "burger", "pizza", "boba", "teh", "minum", "makanan", "lauk", "sayur", "buah",
        ],
        .coffee: ["kopi", "ngopi", "latte", "cappuccino", "espresso", "americano", "kafe", "cafe"],
        .transport: [
            "bensin", "grab", "gojek", "gocar", "goride", "ojek", "ojol", "maxim", "taksi", "taxi", "parkir",
            "tol", "krl", "mrt", "lrt", "busway", "transjakarta", "kereta", "angkot", "bus", "pertalite",
            "pertamax", "solar", "travel", "pesawat", "tiket",
        ],
        .shopping: [
            "belanja", "beras", "minyak", "sabun", "sampo", "indomaret", "alfamart", "supermarket",
            "baju", "celana", "sepatu", "tas", "shopee", "tokopedia", "lazada", "skincare", "kosmetik",
        ],
        .bills: [
            "listrik", "pln", "token", "pdam", "internet", "wifi", "pulsa", "kuota", "indihome", "sewa",
            "kos", "kost", "kontrakan", "tagihan", "iuran",
        ],
        .paylaterInstalment: ["paylater", "cicilan", "kredivo", "akulaku", "spaylater", "angsuran"],
        .savingsDeposit: ["tabungan", "nabung", "menabung", "deposito", "investasi"],
        .insurance: ["asuransi", "bpjs", "premi"],
        .entertainment: ["nonton", "bioskop", "netflix", "spotify", "game", "konser", "karaoke", "langganan"],
        .health: ["obat", "apotek", "dokter", "klinik", "vitamin", "periksa"],
        .education: ["buku", "kursus", "sekolah", "kuliah", "spp", "les", "seminar"],
        .household: ["galon", "gas", "elpiji", "laundry", "deterjen"],
        .salary: ["gaji", "gajian", "upah"],
        .bonus: ["bonus", "thr", "insentif", "komisi"],
        .business: ["jualan", "usaha", "omzet", "penjualan", "dagangan", "laku", "untung"],
    ]

    /** Words that make a draft income even when its category is not known. */
    static let incomeWords: Set<String> = [
        "dapat", "dapet", "terima", "nerima", "dikasih", "kiriman", "transferan", "cashback", "refund",
        "hadiah", "angpao", "honor",
    ]

    /** Each word with its category; a word listed under two categories stops the app at once. */
    static let index: [String: TransactionCategory] = Dictionary(
        uniqueKeysWithValues: words.flatMap { category, words in words.map { ($0, category) } })

    /** The first category any phrase or word of `words` (lower case) names, in reading order. */
    package static func category(of words: [String]) -> TransactionCategory? {
        for (position, word) in words.enumerated() {
            if position + 1 < words.count, let category = phrases["\(word) \(words[position + 1])"] {
                return category
            }
            if let category = index[word] { return category }
        }
        return nil
    }

    /**
     The draft's category and direction: the category a keyword names, else "other" on the side
     the income words point to.
     */
    package static func guess(_ words: [String]) -> (category: TransactionCategory, type: TransactionType) {
        let isIncome = words.contains { incomeWords.contains($0) }
        if let category = category(of: words), !(isIncome && category.type == .expense) {
            return (category, category.type)
        }
        return isIncome ? (.otherIncome, .income) : (.otherExpense, .expense)
    }
}
