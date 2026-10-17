/**
 A wallet or a debt account the person adds by hand (UNG-02, `POST /wallets`): its kind, its name,
 and its amount now: the balance held, or for a credit card, paylater or pinjol the debt left.
 */
package struct WalletDraft: Hashable, Sendable {
    /** One of the six kinds the sheet offers. */
    package let type: WalletType
    /** The name the person gives it ("Dompet Digital 2"). */
    package let name: String
    /** The balance, or the debt left for a debt account, in whole rupiah. */
    package let amount: Int

    /** A draft with every field. */
    package init(type: WalletType, name: String, amount: Int) {
        self.type = type
        self.name = name
        self.amount = amount
    }
}
