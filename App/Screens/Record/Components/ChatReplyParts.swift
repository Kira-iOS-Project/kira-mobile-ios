/**
 The pieces Catat's replies are built from: a draft as the card shows it, the saved transactions
 inside a bubble, and the small paper of a scanned receipt in the person's bubble (canvas HasilScan).
 */
import Domain
import SwiftUI

/** A draft as `KiraDraftCard` shows it: name, amount, category tile and name. */
enum DraftCardItem {
    static func of(_ draft: DraftItem) -> KiraDraftItem {
        KiraDraftItem(
            label: Text(draft.name), amount: Decimal(draft.amount), category: draft.category.tile,
            categoryName: Text(draft.category.title))
    }
}

/** The transactions saved from a message, for `KiraChatBubble.saved`. */
enum SavedItems {
    static func of(_ message: ChatMessage) -> [KiraSavedTransaction] {
        (message.drafts ?? []).map { draft in
            KiraSavedTransaction(
                label: Text(draft.name), amount: Decimal(draft.amount), category: draft.category.tile,
                categoryName: Text(draft.category.title))
        }
    }
}

/** The receipt photo in the person's bubble: a light paper with printed lines, cut at the bottom. */
struct ReceiptThumbnail: View {
    let storeName: String

    var body: some View {
        VStack(spacing: 6) {
            bar(64, 6, .ink)
            bar(48, 3, .lineStrong).padding(.bottom, KiraSpacing.space1)
            row(44, 26)
            row(58, 26)
            row(40, 26)
            Rectangle().fill(.lineStrong).frame(height: 1).padding(.vertical, 2)
            HStack {
                bar(30, 5, .ink)
                Spacer(minLength: 0)
                bar(34, 5, .ink)
            }
            row(24, 30)
            Spacer(minLength: 0)
        }
        .padding(EdgeInsets(top: 14, leading: 12, bottom: 0, trailing: 12))
        .frame(width: 120, height: 150)
        .background(.surface)
        .clipShape(ReceiptEdge())
        .environment(\.colorScheme, .light)
        .accessibilityElement()
        .accessibilityLabel(Text("record.receipt.photoLabel \(storeName)"))
    }

    private func row(_ left: CGFloat, _ right: CGFloat) -> some View {
        HStack {
            bar(left, 3, .lineStrong)
            Spacer(minLength: 0)
            bar(right, 3, .lineStrong)
        }
    }

    private func bar(_ width: CGFloat, _ height: CGFloat, _ color: Color) -> some View {
        RoundedRectangle(cornerRadius: height / 2).fill(color).frame(width: width, height: height)
    }
}

/** A receipt's torn edge: rounded top corners, a zigzag of twelve teeth at the bottom. */
nonisolated struct ReceiptEdge: Shape {
    var teeth = 12

    func path(in rect: CGRect) -> Path {
        var path = Path(
            roundedRect: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: 20), cornerRadius: 10)
        path.addRect(CGRect(x: rect.minX, y: rect.minY + 10, width: rect.width, height: rect.height - 15))
        let step = rect.width / CGFloat(teeth)
        var bottom = Path()
        bottom.move(to: CGPoint(x: rect.minX, y: rect.maxY - 5))
        for tooth in 0..<teeth {
            let left = rect.minX + CGFloat(tooth) * step
            bottom.addLine(to: CGPoint(x: left + step / 2, y: rect.maxY))
            bottom.addLine(to: CGPoint(x: left + step, y: rect.maxY - 5))
        }
        bottom.closeSubpath()
        path.addPath(bottom)
        return path
    }
}
