/**
 One asset the person keeps in Portofolio Manual: its class, the name they gave it (the row's
 title), its value in whole rupiah as they estimate it, and the day of that estimate. Kira never
 prices it: the value is the person's own.
 */
package struct Asset: Hashable, Identifiable, Sendable {
    /** The asset's id. */
    package let id: String
    /** Its class. */
    package let assetClass: AssetClass
    /** Its name, the title of its row. */
    package let name: String
    /** Its value in whole rupiah. */
    package let value: Int
    /** The day the value was estimated. */
    package let valuedOn: CalendarDay

    /** An asset. */
    package init(id: String, assetClass: AssetClass, name: String, value: Int, valuedOn: CalendarDay) {
        self.id = id
        self.assetClass = assetClass
        self.name = name
        self.value = value
        self.valuedOn = valuedOn
    }
}

/** What Tambah Aset sends: a new asset, or the new figures of one already kept. */
package struct AssetInput: Hashable, Sendable {
    /** The class. */
    package let assetClass: AssetClass
    /** The name, trimmed. */
    package let name: String
    /** The value in whole rupiah. */
    package let value: Int
    /** The day of the estimate. */
    package let valuedOn: CalendarDay

    /** An input. */
    package init(assetClass: AssetClass, name: String, value: Int, valuedOn: CalendarDay) {
        self.assetClass = assetClass
        self.name = name
        self.value = value
        self.valuedOn = valuedOn
    }
}
