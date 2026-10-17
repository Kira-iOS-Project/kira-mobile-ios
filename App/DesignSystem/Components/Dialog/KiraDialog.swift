/**
 Dialog (design system: `.k-dialog`): confirmations and the result of an action, over the screen.
 A 112 pt spot illustration (`bloom` for success, `umbrella` for failure, `care` for a confirmation) or a
 round icon, a Title Case title, one sentence, then the buttons stacked as wide as the dialog with
 the primary action on top:
   - confirm before deleting or cancelling: `destructive` primary ("Hapus"), `secondary` "Batal";
   - success names the result ("Transaksi Tersimpan") with one "Selesai";
   - failure names the cause and the way out without blame, keeps what was typed, and offers
     "Coba Lagi" with "Tutup".
 Never for bad news about the person's numbers, and never over the Kira Peduli chat. Present it
 with `.kiraDialog(isPresented:dialog:)`.
 */
import SwiftUI

/** A dialog's card: art, title, message and its stacked buttons. */
struct KiraDialog: View {
    /** The art at the top of the dialog. */
    enum Art {
        /** A spot illustration, 112 pt. */
        case illustration(KiraIllustrationName)
        /** A round pandan check: it worked. */
        case success
        /** A round terracotta alert: it did not work. */
        case failure
    }

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let art: Art
    private let primary: KiraButton
    private let secondary: KiraButton?
    private var onDismiss: (() -> Void)?
    @AccessibilityFocusState private var titleFocused: Bool
    @Environment(\.dynamicTypeSize) private var typeSize

    /**
     `primary` goes on top; `secondary` (Batal, Tutup) under it. Presented, either button closes
     the dialog after its action.
     */
    init(
        _ title: LocalizedStringResource, message: LocalizedStringResource, art: Art, primary: KiraButton,
        secondary: KiraButton? = nil
    ) {
        self.title = title
        self.message = message
        self.art = art
        self.primary = primary
        self.secondary = secondary
    }

    var body: some View {
        VStack(spacing: KiraSpacing.space2) {
            artView
            Text(title)
                /** `.k-dialog__title`'s 750, which keeps "Belum Berhasil Menyimpan" within 280 pt. */
                .font(KiraFont.display(22, axisWeight: 750, relativeTo: .title2, typeSize: typeSize))
                .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                .tracking(-0.33)
                .foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)
                .frame(maxWidth: 280)
                .balancedLines()
            /** Resolved first, then shown as plain text (no Markdown), so an email address stays untinted. */
            Text(String(localized: message))
                .font(.subheadline).kiraLineHeight(21, size: 15)
                .foregroundStyle(.inkMuted)
                .frame(maxWidth: 270)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: KiraSpacing.space2) {
                primary.followed(by: onDismiss).block()
                secondary?.followed(by: onDismiss).block()
            }
            .padding(.top, KiraSpacing.space3)
        }
        .multilineTextAlignment(.center)
        .padding(
            EdgeInsets(
                top: KiraSpacing.space6, leading: KiraSpacing.space5, bottom: KiraSpacing.space5,
                trailing: KiraSpacing.space5)
        )
        .frame(maxWidth: .infinity)
        .kiraCard(cornerRadius: KiraRadius.extraLarge)
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) {
            (secondary ?? primary).action()
            onDismiss?()
        }
        /** Presented, VoiceOver starts on the title; shown inline (the gallery), it leaves focus be. */
        .onAppear { titleFocused = onDismiss != nil }
    }

    /**
     The same dialog, presented: VoiceOver starts on its title, and its buttons and the escape
     gesture (which runs the secondary action, or the only one) call `dismiss` after their action.
     */
    func presented(dismiss: @escaping () -> Void) -> Self {
        var dialog = self
        dialog.onDismiss = dismiss
        return dialog
    }

    @ViewBuilder private var artView: some View {
        switch art {
        case .illustration(let name):
            KiraIllustration(name, size: 112).padding(.top, -4)
        case .success:
            ResultBadge(icon: .check, color: .pandan, fill: .pandanSoft, border: .pandanLine)
        case .failure:
            ResultBadge(icon: .alert, color: .vulnerable, fill: .vulnerableSoft, border: .vulnerableLine)
        }
    }
}

/** The round icon of a success or failure dialog (`.k-dialog__icon--ok` and `--bad`). */
private struct ResultBadge: View {
    let icon: KiraIconName
    let color: Color
    let fill: Color
    let border: Color

    var body: some View {
        KiraIcon(icon, size: 28, weight: .semibold)
            .foregroundStyle(color)
            .frame(width: 56, height: 56)
            .background(fill, in: Circle())
            .overlay { Circle().strokeBorder(border, lineWidth: 1) }
            .padding(.bottom, KiraSpacing.space1)
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview { GalleryDialogs().galleryPage() }
#endif
