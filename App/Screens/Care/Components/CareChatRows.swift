/**
 Kira Peduli's lines in the Catat chat (boards SinyalKrisis, CheckInChat): the person's message or
 quick reply, Kira's fixed reply to a crisis signal with its quick replies and the counsellor card,
 the check-in greeting with its quick replies, and the reply to Sedikit Lebih Baik with the Mode
 Darurat Utang card. Kira's replies here carry no Kuku avatar and say they are automatic.
 */
import Domain
import Features
import SwiftUI

/** One Kira Peduli line; without a model (Riwayat Percakapan) the quick replies and cards are hidden. */
struct CareChatRow: View {
    let entry: CareChatEntry
    let model: CareChatModel?
    let initial: String?

    var body: some View {
        switch entry.kind {
        case .personText(let text):
            KiraChatBubble(.user, initial: initial) { Text(text) }
        case .personChoice(let choice):
            KiraChatBubble(.user, initial: initial) { Text(choice.title) }
        case .crisisReply(let isAnswered):
            CrisisReply(entry: entry, model: isAnswered ? nil : model, onHelp: model?.openHelp)
        case .checkInGreeting(let name, let isAnswered):
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                KiraChatBubble(.kira, meta: "care.meta.checkIn") {
                    Text(name.isEmpty ? "care.checkIn.sample" : "care.checkInChat.greeting \(name)")
                }
                .hidesAvatar()
                if !isAnswered, let model { CareQuickReplies(choices: CareChoice.checkIn, entry: entry, model: model) }
            }
        case .checkInBetter:
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                KiraChatBubble(.kira, meta: "care.meta.automatic") { Text("care.checkInChat.better") }.hidesAvatar()
                if let model { DebtEmergencyCard(onOpen: model.openDebtEmergency) }
            }
        }
    }
}

/** Kira's two fixed sentences, the quick replies until one is chosen, and Lihat Bantuan. */
private struct CrisisReply: View {
    let entry: CareChatEntry
    let model: CareChatModel?
    let onHelp: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                KiraChatBubble(.kira) { Text("care.crisis.reply") }.hidesAvatar()
                KiraChatBubble(.kira, meta: "care.meta.automatic") { Text("care.crisis.question") }.hidesAvatar()
            }
            if let model { CareQuickReplies(choices: CareChoice.crisis, entry: entry, model: model) }
            if let onHelp { CounsellorCard(onHelp: onHelp) }
        }
    }
}

/** The quick replies under a Kira Peduli line, in the board's order. */
private struct CareQuickReplies: View {
    let choices: [CareChoice]
    let entry: CareChatEntry
    let model: CareChatModel

    var body: some View {
        KiraFlowRow {
            ForEach(choices, id: \.self) { choice in
                KiraChip(choice.title, isSelected: false) { Task { await model.choose(choice, in: entry) } }
            }
        }
        .padding(.top, 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("care.quickReplies.label"))
    }
}

/** "Kamu bisa bicara dengan konselor sekarang, gratis." with Lihat Bantuan. */
private struct CounsellorCard: View {
    let onHelp: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            CareCardArt(name: .care)
            VStack(alignment: .leading, spacing: 10) {
                Text("care.counsellor.message").font(.subheadline).kiraLineHeight(20, size: 15)
                KiraButton("care.counsellor.help", size: .small, action: onHelp)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 2)
        }
        .padding(.init(top: 12, leading: 12, bottom: 14, trailing: 14))
        .kiraCard(cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("care.counsellor.label"))
    }
}

/** The Mode Darurat Utang card with Buka (CheckInChat). */
private struct DebtEmergencyCard: View {
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            CareCardArt(name: .shield).frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: 2) {
                Text("care.debtCard.title").font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                Text("care.debtCard.subtitle").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraButton("care.debtCard.open", size: .small, action: onOpen)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(12)
        .kiraCard(cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .contain)
    }
}

/** The 44 pt round illustration at the left of a card in the chat. */
private struct CareCardArt: View {
    let name: KiraIllustrationName

    var body: some View {
        KiraIllustration(name, size: 44)
            .clipShape(Circle())
            .overlay { Circle().strokeBorder(Color.hairline, lineWidth: 1) }
            .accessibilityHidden(true)
    }
}
