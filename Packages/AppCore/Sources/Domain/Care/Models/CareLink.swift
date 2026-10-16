import Foundation

/**
 The links a contact opens. Each is a deep link the person taps (`tel:`, `sms:`, `https://wa.me/`):
 the phone app or WhatsApp opens with the number and any message filled in, and nothing goes out
 until the person sends it there.
 */
extension CareContact {
    /** `tel:` the number, then a pause and the extension when there is one ("tel:119,8"). */
    package var callURL: URL? {
        guard let phone else { return nil }
        let digits = Self.dialable(phone)
        guard !digits.isEmpty else { return nil }
        let pause = phoneExtension.map { "," + Self.dialable($0) } ?? ""
        return URL(string: "tel:\(digits)\(pause)")
    }

    /**
     WhatsApp's chat with this contact (`https://wa.me/62…`), with `message` typed in when it is
     not blank; nil when the contact has no WhatsApp number.
     */
    package func whatsAppURL(message: String?) -> URL? {
        guard let whatsApp else { return nil }
        let digits = Self.dialable(whatsApp)
        guard !digits.isEmpty else { return nil }
        let international = digits.hasPrefix("0") ? "62" + digits.dropFirst() : digits
        return URL(string: "https://wa.me/\(international)\(Self.query("?text=", message))")
    }

    /** Messages with this contact's number and `message` typed in when it is not blank. */
    package func smsURL(message: String?) -> URL? {
        guard let phone else { return nil }
        let digits = Self.dialable(phone)
        guard !digits.isEmpty else { return nil }
        return URL(string: "sms:\(digits)\(Self.query("&body=", message))")
    }

    /** The digits of `number`, with a leading "+" kept. */
    private static func dialable(_ number: String) -> String {
        let digits = number.filter(\.isASCII).filter(\.isNumber)
        return number.trimmingCharacters(in: .whitespaces).hasPrefix("+") ? "+" + digits : digits
    }

    /** `name` and the encoded message, or nothing for a blank one. */
    private static func query(_ name: String, _ message: String?) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&+=?#")
        let text = message?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty, let encoded = text.addingPercentEncoding(withAllowedCharacters: allowed) else {
            return ""
        }
        return name + encoded
    }
}
