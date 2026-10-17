/**
 What a goal saves for (Tujuan Baru, REN-02): its kind, as `POST /goals` names it. Each kind has its
 own form and result; Dana Darurat is the only one a person keeps just once.
 */
package enum GoalKind: String, CaseIterable, Hashable, Sendable {
    /** Dana Darurat (REN-03, REN-05). */
    case emergencyFund = "emergency_fund"
    /** DP Rumah (REN-02b). */
    case houseDownPayment = "house_dp"
    /** Pendidikan Anak (REN-02c). */
    case education
    /** Menikah (REN-02d). */
    case wedding
    /** Dana Pensiun (REN-02e). */
    case retirement
    /** Kendaraan (REN-02f). */
    case vehicle
    /** Barang Impian (REN-02g). */
    case goods
    /** Lainnya (REN-02h). */
    case other
}
