/**
 Kirim Produk ke Etalase (KOM-08): what a seller includes in their email, and "Kirim Lewat Email",
 which opens the mail app on a message to the Kira team with the subject and a numbered list to
 fill in. There is no form in the app; the team checks the seller's licence or certification.
 */
import Domain
import Features
import SwiftUI
import UIKit

struct SubmitProductScreen: View {
    let onOpen: (AppRoute) -> Void
    @State private var model = SubmitProductModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "submitProduct.title", subtitle: "submitProduct.subtitle",
                    leading: .back("submitProduct.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                header
                VStack(alignment: .leading, spacing: 10) {
                    KiraSectionTitle("submitProduct.include")
                    NumberedList(items: Self.items)
                }
                KiraNotice(.info, message: "submitProduct.notice")
                KiraButton("submitProduct.send", action: send).icon(.send).block()
                    .padding(.top, KiraSpacing.space2)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space2)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .kiraDialog(isPresented: missingBinding) {
            KiraDialog(
                "submitProduct.noMail.title", message: "submitProduct.noMail.body", art: .illustration(.letter),
                primary: KiraButton("submitProduct.noMail.copy") {
                    UIPasteboard.general.string = ProductSubmission.address
                },
                secondary: KiraButton("submitProduct.noMail.close", variant: .secondary) {})
        }
    }

    private var header: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 6) {
                Text("submitProduct.heading")
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                    .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.48)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("submitProduct.body").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraIllustration(.letter, size: 80)
        }
        .padding(.vertical, 2)
    }

    /** The five things the email holds, also the numbered list of its body. */
    private static let items: [LocalizedStringResource] = [
        "submitProduct.item.product", "submitProduct.item.seller", "submitProduct.item.link",
        "submitProduct.item.price", "submitProduct.item.description",
    ]

    private func send() {
        let url = ProductSubmission.mailURL(
            subject: String(localized: "submitProduct.mail.subject"),
            greeting: String(localized: "submitProduct.mail.greeting"),
            items: Self.items.map { String(localized: $0) })
        guard let url else { return model.mailOpened(false) }
        openURL(url) { model.mailOpened($0) }
    }

    private var missingBinding: Binding<Bool> {
        Binding(get: { model.phase == .mailAppMissing }, set: { if !$0 { model.dismiss() } })
    }
}

/** The list of the board: each item behind its number in a pandan circle, in one card. */
private struct NumberedList: View {
    let items: [LocalizedStringResource]

    var body: some View {
        KiraRowStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: KiraSpacing.space3) {
                    Text(index + 1, format: .number)
                        .font(KiraFont.display(13, .heavy, relativeTo: .footnote))
                        .foregroundStyle(.pandan)
                        .frame(width: 26, height: 26)
                        .background(.pandanSoft, in: Circle())
                        .overlay { Circle().strokeBorder(.pandanLine, lineWidth: 1) }
                        .accessibilityHidden(true)
                    Text(item).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 11)
                .kiraRowSeparator()
            }
        }
        .padding(.horizontal, KiraSpacing.space4)
        .padding(.vertical, KiraSpacing.space1)
        .kiraCard()
    }
}
