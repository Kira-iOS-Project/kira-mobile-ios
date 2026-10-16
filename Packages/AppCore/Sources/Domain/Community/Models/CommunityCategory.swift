/**
 The categories of the community directory (KOM-01's chips), the backend's category keys. The
 chips' words are the catalog's; the server's labels say the same.
 */
package enum CommunityCategory: String, CaseIterable, Hashable, Sendable {
    /** Bebas Hutang. */
    case debtFree = "debt_free"
    /** Saham. */
    case stocks
    /** Web3/Kripto. */
    case crypto
    /** Diskusi Keuangan. */
    case financeTalk = "finance_talk"
}

/** Where a group meets, as the API names it. */
package enum CommunityPlatform: String, CaseIterable, Hashable, Sendable {
    /** WhatsApp. */
    case whatsapp
    /** Telegram. */
    case telegram
    /** Discord. */
    case discord
}

/**
 A group's tile, as the API names the design system's category icons ("paylater", "saham"). A name
 this build does not know falls back to the generic tile.
 */
package enum CommunityGroupIcon: String, CaseIterable, Hashable, Sendable {
    /** Paylater: debt groups. */
    case paylater
    /** Saham: stocks. */
    case stocks = "saham"
    /** Kripto: crypto. */
    case crypto = "kripto"
    /** Gaji: salary and budgeting talk. */
    case salary = "gaji"
    /** Any other tile. */
    case other = "lainnya"

    /** The tile named `name`, or the generic one. */
    package init(named name: String) {
        self = CommunityGroupIcon(rawValue: name) ?? .other
    }
}
