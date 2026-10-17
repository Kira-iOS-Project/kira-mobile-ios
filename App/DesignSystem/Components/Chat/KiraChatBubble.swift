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
            ChatLineLayout(isUser: sender == .user, isCard: !saved.isEmpty) {
                bubble
                if sender == .kira, showsAvatar { KiraAvatarFace() }
                if sender == .user, showsAvatar, let initial { initialAvatar(initial) }
            }
            if let meta {
                Text(meta)
                    .font(.caption.weight(.medium)).kiraLineHeight(16, size: 12)
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
            content.font(.body).kiraLineHeight(22, size: 17)
            if !saved.isEmpty { SavedList(items: saved) }
        }
        /** A bubble with saved transactions spans the width ChatLineLayout gives it. */
        .frame(maxWidth: saved.isEmpty ? nil : .infinity, alignment: .leading)
        .foregroundStyle(sender == .user ? Color.onPandan : Color.ink)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(sender == .user ? Color.pandan : Color.surfaceRaised, in: shape)
        .overlay { shape.strokeBorder(sender == .user ? Color.clear : Color.hairline, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }

    private func initialAvatar(_ initial: String) -> some View {
        KiraAvatar(initial, size: 32, tone: .turmeric)
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

/**
 A message's line (`.k-bubble__line`): the bubble at most 82 % of the width, or 76 % beside an avatar
 (`max-width` also caps the card's `width: 82%`, so a card is 82 % alone and 76 % beside one); a
 bubble whose text wraps takes its whole limit, as a CSS box does, rather than its longest line;
 the avatar 8 pt from it, both on the line's bottom.
 Kira's line starts at the left, the person's at the right. Its subviews are the bubble, then the
 avatar if any.
 */
private struct ChatLineLayout: Layout {
    let isUser: Bool
    let isCard: Bool

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.width ?? 361
        let frames = arrange(width: width, subviews: subviews)
        return CGSize(width: width, height: frames.map(\.maxY).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        for (subview, frame) in zip(subviews, arrange(width: bounds.width, subviews: subviews)) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size))
        }
    }

    /** The bubble's and the avatar's frames, bottom-aligned, in the line's coordinates. */
    private func arrange(width: CGFloat, subviews: Subviews) -> [CGRect] {
        guard let bubble = subviews.first else { return [] }
        let avatar = subviews.count > 1 ? subviews[1].sizeThatFits(.unspecified) : nil
        let limit = (width * (avatar == nil ? 0.82 : 0.76)).rounded(.down)
        var size = bubble.sizeThatFits(ProposedViewSize(width: limit, height: nil))
        if isCard || bubble.sizeThatFits(.unspecified).width > limit { size.width = limit }
        let height = max(size.height, avatar?.height ?? 0)
        let inset = avatar.map { $0.width + KiraSpacing.space2 } ?? 0
        let bubbleX = isUser ? width - inset - size.width : inset
        var frames = [CGRect(x: bubbleX, y: height - size.height, width: size.width, height: size.height)]
        if let avatar {
            frames.append(
                CGRect(
                    x: isUser ? width - avatar.width : 0, y: height - avatar.height, width: avatar.width,
                    height: avatar.height))
        }
        return frames
    }
}

/**
 Kira's avatar: the guide's calm Kuku on its round ground with the pandan sparkle that marks an AI
 reply, the circle 32 pt across (the image adds the badge's overhang).
 */
private struct KiraAvatarFace: View {
    var body: some View {
        KiraMascot(.calm, size: 32 * 124 / 114, crop: .face)
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
                        item.label.font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                        KiraAmount(item.amount, size: .small)
                        if let name = item.categoryName {
                            name.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                        }
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
