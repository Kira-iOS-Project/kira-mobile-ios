/**
 The guides Mode Darurat Utang opens, one per situation (PED-08, PED-13, PED-14, PED-15). Their
 words are static, written and reviewed by the Kira team; what differs in logic is which actions
 each one offers, in the order the board stacks them.
 */
package enum DebtGuide: String, CaseIterable, Hashable, Sendable {
    /** PED-08 Ditagih Kasar: a licensed lender's collector crossing the line. */
    case harshCollection
    /** PED-13 Diteror Pinjol Ilegal: an unlicensed lender. */
    case illegalLender
    /** PED-14 Aduan Belum Selesai: a complaint the lender left unresolved. */
    case unresolvedComplaint
    /** PED-15 Ditawari Jasa "Pelunasan": a paid offer to make the debt go away. */
    case payoffOffer

    /** The buttons under the steps, top first. */
    package var actions: [DebtGuideAction] {
        switch self {
        case .harshCollection: [.callOJK, .whatsAppOJK]
        case .illegalLender: [.reportToSatgas, .callOJK]
        case .unresolvedComplaint: [.openLapsSjk, .callOJK]
        case .payoffOffer: [.reportToSatgas, .negotiationScript]
        }
    }

    /** The link inside the closing notice, where the board has one. */
    package var noticeLink: DebtGuideAction? {
        self == .harshCollection ? .negotiationScript : nil
    }
}

/** What a guide's button or link does. */
package enum DebtGuideAction: Hashable, Sendable {
    /** Telepon OJK 157: the phone app with 157. */
    case callOJK
    /** WhatsApp OJK: WhatsApp's chat with OJK's number. */
    case whatsAppOJK
    /** Lapor ke Satgas PASTI: its site in the browser. */
    case reportToSatgas
    /** Buka LAPS SJK: its site in the browser. */
    case openLapsSjk
    /** Susun Naskah Keringanan: the negotiation script (PED-09). */
    case negotiationScript
}
