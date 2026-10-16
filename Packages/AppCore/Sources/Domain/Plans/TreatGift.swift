/** A Traktir Kira (`POST /billing/gifts`): months of Kira Plus bought for Beasiswa Kira. */
package struct TreatGift: Hashable, Sendable {
    /** The months Traktir Kira offers. */
    package static let monthOptions = [1, 3, 6]

    /** The gift's id. */
    package let id: String
    /** How many months of Kira Plus. */
    package let months: Int
    /** What was paid: Kira Plus's monthly price times `months`. */
    package let amount: Int

    /** The gift as the API sends it. */
    package init(id: String, months: Int, amount: Int) {
        self.id = id
        self.months = months
        self.amount = amount
    }
}
