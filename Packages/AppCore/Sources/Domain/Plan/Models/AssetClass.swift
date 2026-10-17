/**
 The asset classes of Portofolio Manual (REN-10, REN-11): the backend's `assetClass` values, in the
 order of Tambah Aset's grid (Deposito, Reksa Dana, SBN, Emas, Saham, Kripto, Lainnya).
 */
package enum AssetClass: String, CaseIterable, Codable, Sendable {
    /** Deposito. */
    case deposit
    /** Reksa Dana. */
    case mutualFund = "mutual_fund"
    /** SBN, the government's retail bonds. */
    case governmentBond = "government_bond"
    /** Emas. */
    case gold
    /** Saham. */
    case stock
    /** Kripto. */
    case crypto
    /** Lainnya. */
    case other
}
