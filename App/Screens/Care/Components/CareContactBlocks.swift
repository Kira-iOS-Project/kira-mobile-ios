/**
 The blocks Kira Peduli (PED-01) and its sheet over the chat (PED-03) share: Healing119's call and
 chat rows, the Layanan Kira card with the care illustration, and Telepon 119, the only red button. Numbers come
 from the verified list; each row opens a link the person taps, and a long press copies a number.
 */
import Domain
import SwiftUI

/** Telepon Healing119 and Chat Healing119; `isShort` drops the counsellors line (PED-03). */
struct CareHealingRows: View {
    let contact: CareContact?
    var isShort = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let contact {
            if let phone = contact.phone {
                KiraListRow(Text("care.healing119.call"), leading: .icon(.phone)) { open(contact.callURL) }
                    .subtitle(Text(callDetail(phone: phone, ext: contact.phoneExtension)))
                    .copiesNumber(phone)
            }
            if let website = contact.website {
                KiraListRow(Text("care.healing119.chat"), leading: .icon(.chat), trailing: .external) {
                    openURL(website)
                }
                .subtitle(Text("care.healing119.chatDetail \(website.host() ?? website.absoluteString)"))
            }
        }
    }

    private func callDetail(phone: String, ext: String?) -> LocalizedStringResource {
        let ext = ext ?? ""
        return isShort
            ? "care.sheet.healing119.callDetail \(phone) \(ext)"
            : "care.healing119.callDetail \(phone) \(ext)"
    }

    private func open(_ url: URL?) {
        if let url { openURL(url) }
    }
}

/**
 Hubungi Layanan Kira: the care art in a 56 pt circle (Kira Peduli has no Kuku), one button read as a sentence. It
 shows only while the verified list has Layanan Kira Peduli, so it never leads to a message
 nobody can receive.
 */
struct CareKiraCard: View {
    let contact: CareContact?
    let detail: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        if contact != nil { card }
    }

    private var card: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                KiraIllustration(.care, size: 44)
                    .frame(width: 56, height: 56)
                    .background(.surfaceRaised)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.pandanLine, lineWidth: 1))
                VStack(alignment: .leading, spacing: 2) {
                    Text("care.kira.title").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    Text(detail).font(.subheadline).kiraLineHeight(19, size: 14).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 14))
            .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("care.kira.label"))
        .accessibilityAddTraits(.isButton)
    }
}

/** Telepon 119 (PSC 119): the emergency red, the one red button of Kira Peduli. */
struct CareEmergencyButton: View {
    let contact: CareContact?
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let phone = contact?.phone {
            KiraButton("care.emergency.call \(phone)", variant: .emergency) {
                if let url = contact?.callURL { openURL(url) }
            }
            .icon(.phone).block()
            .copiesNumber(phone)
        }
    }
}

extension View {
    /** A long press offers Salin Nomor, which copies `number`: numbers are text to copy too. */
    func copiesNumber(_ number: String) -> some View {
        contextMenu {
            Button {
                KiraClipboard.copy(number, copied: "care.copyNumber.copied")
            } label: {
                Label {
                    Text("care.copyNumber")
                } icon: {
                    KiraIcon(.copy)
                }
            }
        }
    }
}
