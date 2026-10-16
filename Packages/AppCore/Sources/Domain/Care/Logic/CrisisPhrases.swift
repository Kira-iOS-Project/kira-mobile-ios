/**
 The reviewed phrase list of PED-02 (Indonesian, slang included). Each phrase is written in plain
 words; `CrisisText` reads the phrase and the message the same way (lower case, no accents,
 repeated letters once, slang spellings to one word: "ga", "gk", "nggak" and "tidak" are all
 "gak"), so one entry covers its spellings. A phrase ending in " $" matches only at the end of a
 clause, words of `trailing` aside: "udah gak kuat $" is despair, and so is "udah gak kuat banget
 aku", while "udah gak kuat bayar cicilan" is about money.

 The threshold (recorded so a review can change it on purpose): tiredness, stress or a headache
 alone is not a signal. "capek banget hari ini beli kopi 25rb" is an ordinary expense and is
 recorded as one; only despair or words about ending one's life count. Between the two, the
 on-device model may be asked, never the list relaxed. A missed signal costs more than a false
 one, so explicit words count even in a sentence that seems to deny them ("aku gak mau bunuh
 diri"): the reply only asks whether the person is safe.
 */
enum CrisisPhrases {
    /** Words about ending one's life or self-harm. */
    static let danger = [
        "bunuh diri", "bundir", "ngebundir", "pengen mati", "aku mau mati", "mending mati", "lebih baik mati",
        "aku mati aja", "mau mati aja", "mending aku mati", "mending gak ada aja", "mending aku gak ada",
        "lebih baik aku gak ada",
        "mending aku gak usah ada", "gak mau hidup lagi", "gak pengen hidup lagi", "gak mau hidup $",
        "gak pengen hidup $", "capek hidup", "capek sama hidup", "capek banget sama hidup", "lelah hidup",
        "bosan hidup", "bosen hidup", "males hidup", "muak hidup", "udah gak kuat hidup", "gak sanggup hidup",
        "akhiri hidup", "akhiri hidupku", "akhirin hidup", "akhirin hidupku", "gantung diri", "minum racun",
        "lompat dari gedung", "lompat dari jembatan", "lompat dari atap", "loncat dari gedung",
        "loncat dari jembatan", "nyilet tangan", "nyilet nadi", "potong nadi", "sayat tangan", "nyakitin diri",
        "self harm", "selfharm", "pengen ngilang selamanya", "pergi selamanya",
        "lebih baik tanpa aku", "kill myself", "want to die", "end my life", "suicide", "unalive",
    ]

    /** Despair without words about ending one's life. */
    static let concern = [
        "putus asa", "gak ada harapan", "udah gak kuat $", "aku gak kuat $", "gak kuat lagi $",
        "aku gak kuat lagi", "udah gak sanggup $", "gak sanggup lagi $", "pengen nyerah", "nyerah aja", "aku nyerah",
        "hidupku hancur",
        "hidup aku hancur", "aku hancur", "hatiku hancur", "hati aku hancur", "rasanya hancur",
        "depresi", "aku stres berat", "lagi stres berat", "aku gak berguna", "aku cuma beban",
        "jadi beban keluarga", "gak tahu harus gimana lagi", "buntu banget", "pengen ngilang",
        "pengen kabur dari semuanya", "nangis terus", "tiap malam nangis", "akhiri semuanya", "akhirin semuanya",
        "gak ada gunanya lagi", "hidup gak ada artinya", "kesepian banget",
    ]

    /**
     Words of a heavy day that are not a signal on their own. A message with one of them and no
     listed phrase is the debatable case: only the on-device model, where it supports Indonesian,
     may still find a signal in it.
     */
    static let cues: Set<String> = [
        "capek", "lelah", "pusing", "stres", "sedih", "nangis", "takut", "hancur", "sendirian", "kesepian",
        "berat", "frustasi", "galau", "cemas", "panik", "putus", "nyerah", "kalut", "mati", "hopeless",
    ]

    /** Words that may follow a phrase ending in " $" without ending its clause's meaning. */
    static let trailing: Set<String> = [
        "aku", "lagi", "banget", "aja", "ya", "deh", "sih", "nih", "kok", "rasanya", "beneran", "sekarang",
    ]

    /** One spelling per slang word, keyed by its spellings. */
    static let spellings: [String: [String]] = [
        "gak": ["ga", "gk", "g", "gag", "nggak", "ngga", "enggak", "engga", "tidak", "tak", "ndak", "nda", "kagak"],
        "pengen": ["pengin", "pingin", "pingen", "ingin", "pgn", "pen", "pngn"],
        "mau": ["mo", "mw"],
        "aku": ["gue", "gua", "gw", "gwe", "saya", "ak", "aq", "sy", "ane"],
        "aja": ["aj", "ajah", "saja"],
        "udah": ["udh", "uda", "dah", "sdh", "sudah"],
        "banget": ["bgt", "bngt", "bnget"],
        "lagi": ["lg", "lgi"],
        "tahu": ["tau", "tw"],
        "gimana": ["gmn", "gmana", "bagaimana"],
        "mending": ["mendingan", "mnding"],
        "hidup": ["idup"],
        "capek": ["cape", "cpk", "capk"],
        "nyerah": ["menyerah"],
        "akhiri": ["mengakhiri"],
        "akhirin": ["ngakhirin", "mengakhirin"],
        "ngilang": ["menghilang"],
        "nyakitin": ["menyakiti", "nyakiti", "melukai", "ngelukain", "lukai"],
        "stres": ["stress", "setres"],
        "yang": ["yg"],
    ]
}
