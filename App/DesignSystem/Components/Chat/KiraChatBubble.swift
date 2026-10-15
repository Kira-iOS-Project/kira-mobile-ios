/**
 ChatBubble (design system): a message on Catat. The person's own (`.user`) is pandan with their
 initial on the right; Kira's (`.kira`) is a white card with a hairline and Kuku's calm face with a
 pandan AI sparkle on the left. Every AI reply carries `meta` "Dijawab Kira AI · dari pesan 12.41"
 (the time itself sits in a centred separator, not on bubbles). Transactions already saved from a
 message show inside Kira's bubble (`.saved`): tile, name, amount, category.
 */
import SwiftUI

/** A transaction saved from a message, shown inside Kira's bubble. */
struct KiraSavedTransaction: Identifiable {
    let label: Text
    let amount: Decimal
    let category: KiraCategory
    var categoryName: Text?
    let id = UUID()
}

/** One chat message. */
struct KiraChatBubble<Content: View>: View {
    /** Who wrote the message. */
    enum Sender {
        case user, kira
    }

    typealias Saved = KiraSavedTransaction

    private let sender: Sender
    private let meta: LocalizedStringResource?
    private let initial: String?
    private let content: Content
    private var saved: [Saved] = []
    private var showsAvatar = true

    /** `initial` is the person's initial beside their own messages. */
    init(
        _ sender: Sender, meta: LocalizedStringResource? = nil, initial: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.sender = sender
        self.meta = meta
        self.initial = initial
        self.content = content()
    }

    private var hasAvatar: Bool { showsAvatar && (sender == .kira || initial != nil) }

    var body: some View {
        VStack(alignment: sender == .user ? .trailing : .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: KiraSpacing.space2) {
                if sender == .user { Spacer(minLength: 56) }
                if sender == .kira, showsAvatar { KiraAvatarFace() }
                bubble
                if sender == .user, showsAvatar, let initial { initialAvatar(initial) }
                if sender == .kira { Spacer(minLength: 40) }
            }
            if let meta {
                Text(meta)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.inkMuted)
                    .padding(sender == .user ? .trailing : .leading, hasAvatar ? 44 : 4)
            }
        }
    }

    private var bubble: some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 20, bottomLeadingRadius: sender == .kira ? 6 : 20,
            bottomTrailingRadius: sender == .user ? 6 : 20, topTrailingRadius: 20, style: .continuous)
        return VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            content.font(.body)
            if !saved.isEmpty { SavedList(items: saved) }
        }
        .foregroundStyle(sender == .user ? Color.onPandan : Color.ink)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(sender == .user ? Color.pandan : Color.surfaceRaised, in: shape)
        .overlay { shape.strokeBorder(sender == .user ? Color.clear : Color.hairline, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }

    private func initialAvatar(_ initial: String) -> some View {
        KiraAvatar(initial, size: 32, tone: .kunyit)
    }

    /** The same message with the transactions saved from it. */
    func saved(_ items: [Saved]) -> Self {
        var bubble = self
        bubble.saved = items
        return bubble
    }

    /** The same message without its avatar. */
    func hidesAvatar() -> Self {
        var bubble = self
        bubble.showsAvatar = false
        return bubble
    }
}

/** Kuku's calm face in a 32 pt circle with the pandan AI sparkle: Kira's avatar. */
private struct KiraAvatarFace: View {
    var body: some View {
        KiraMascot(.tenang, size: 32, crop: .face)
            .background(.iluHijauMuda)
            .clipShape(Circle())
            .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "sparkle")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.onPandan)
                    .frame(width: 16, height: 16)
                    .background(.pandan, in: Circle())
                    .overlay { Circle().strokeBorder(.surface, lineWidth: 2) }
                    .offset(x: 4, y: 3)
            }
            .accessibilityHidden(true)
    }
}

/** The transactions saved from a message, under a line inside Kira's bubble. */
private struct SavedList: View {
    let items: [KiraSavedTransaction]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 10) {
                    KiraCategoryIcon(item.category, size: 32).padding(.top, 2)
                    VStack(alignment: .leading, spacing: 0) {
                        item.label.font(.subheadline.weight(.semibold))
                        KiraAmount(item.amount, size: .small)
                        if let name = item.categoryName { name.font(.footnote).foregroundStyle(.inkMuted) }
                    }
                }
            }
        }
        .padding(.top, KiraSpacing.space2)
        .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
    }
}

#if DEBUG
    #Preview { GalleryChat().galleryPage() }
#endif
