import Domain
import Foundation
import Observation

/**
 PED-04, Kirim Pesan ke Layanan Kira: an opening message the person may change, sent only by them
 through WhatsApp or SMS, or a call. Each action is a deep link with the message filled in: Kira
 never sends anything itself.
 */
@MainActor
@Observable
package final class TrustedMessageModel {
    /** The message, filled in and editable. */
    package var message: String
    /** Layanan Kira Peduli's contact, from the verified list. */
    package let contacts: CareContactsModel

    /** The screen, with `message` (the catalog's opening message) filled in. */
    package init(service: any CareService, message: String) {
        self.contacts = CareContactsModel(service: service)
        self.message = message
    }

    /** Loads the verified contacts. */
    package func load() async {
        await contacts.load()
    }

    /** Kirim lewat WhatsApp: WhatsApp's chat with Layanan Kira, the message typed in. */
    package var whatsAppURL: URL? {
        recipient?.whatsAppURL(message: message)
    }

    /** Kirim lewat SMS: Messages with Layanan Kira's number, the message typed in. */
    package var smsURL: URL? {
        recipient?.smsURL(message: message)
    }

    /** Telepon Layanan Kira. */
    package var callURL: URL? {
        recipient?.callURL
    }

    private var recipient: CareContact? {
        contacts.contact(.kiraCare)
    }
}
