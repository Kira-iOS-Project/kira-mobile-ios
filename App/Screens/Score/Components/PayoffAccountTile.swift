/**
 One account in the plan's order, as the RencanaPelunasan and PelunasanAktif boards draw it: a
 hairline card with the category tile, its place in the order on a small round badge (pandan for
 the first, muted for the rest), the name, the lines under it, the tag, and a chevron when it opens
 something.
 */
import Domain
import SwiftUI

struct PayoffAccountTile: View {
    private let rank: Int
    private let category: KiraCategory
    private let name: String
    private let lines: [LocalizedStringResource]
    private let tag: LocalizedStringResource
    private let tagTone: KiraTag.Tone
    private let action: (() -> Void)?

    /** `rank` is the place from 1; `lines` go under the name ("Sisa Rp420.000,00", "Lunas 25 Oktober 2026"). */
    init(
        rank: Int, category: KiraCategory, name: String, lines: [LocalizedStringResource],
        tag: LocalizedStringResource, tagTone: KiraTag.Tone = .neutral, action: (() -> Void)? = nil
    ) {
        self.rank = rank
        self.category = category
        self.name = name
        self.lines = lines
        self.tag = tag
        self.tagTone = tagTone
        self.action = action
    }

    var body: some View {
        if let action {
            Button(action: action) { card(chevron: true) }
                .buttonStyle(.plain)
        } else {
            card(chevron: false)
        }
    }

    private func card(chevron: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RankedTile(rank: rank, category: category)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.body.weight(.semibold)).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                KiraTag(tag, tone: tagTone).padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if chevron {
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
                    .frame(maxHeight: .infinity)
                    .accessibilityHidden(true)
            }
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard(cornerRadius: KiraRadius.medium)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/** The category tile with the account's place on a 20 pt badge over its top left corner. */
private struct RankedTile: View {
    let rank: Int
    let category: KiraCategory

    var body: some View {
        KiraCategoryIcon(category)
            .overlay(alignment: .topLeading) {
                Text(rank, format: .number)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(rank == 1 ? Color.onPandan : Color.ink)
                    .frame(width: 20, height: 20)
                    .background(rank == 1 ? Color.pandan : Color.surfaceMuted, in: Circle())
                    .overlay { Circle().strokeBorder(Color.surfaceRaised, lineWidth: 2) }
                    .offset(x: -7, y: -7)
            }
            .accessibilityHidden(true)
    }
}
