/**
 The words and tiles of the community values: each category's chip, each platform's name, each
 report reason's row, a group's tile, and the numbers and months as Kira writes them ("1.240",
 "Maret 2026") whatever the device's region.
 */
import Domain
import Foundation
import SwiftUI

extension CommunityCategory {
    /** The chip's words ("Bebas Hutang"). */
    var title: LocalizedStringResource {
        switch self {
        case .debtFree: "community.category.debtFree"
        case .stocks: "community.category.stocks"
        case .crypto: "community.category.crypto"
        case .financeTalk: "community.category.financeTalk"
        }
    }
}

extension CommunityPlatform {
    /** "WhatsApp", "Telegram", "Discord". */
    var title: LocalizedStringResource {
        switch self {
        case .whatsapp: "community.platform.whatsapp"
        case .telegram: "community.platform.telegram"
        case .discord: "community.platform.discord"
        }
    }
}

extension CommunityPlatform {
    /** "Buka WhatsApp": the outside link's button. */
    var openTitle: LocalizedStringResource {
        switch self {
        case .whatsapp: "community.outbound.open.whatsapp"
        case .telegram: "community.outbound.open.telegram"
        case .discord: "community.outbound.open.discord"
        }
    }
}

extension GroupReportReason {
    /** The reason's row ("Ajakan Gagal Bayar"). */
    var title: LocalizedStringResource {
        switch self {
        case .defaultInvite: "community.report.reason.defaultInvite"
        case .guaranteedProfit: "community.report.reason.guaranteedProfit"
        case .scam: "community.report.reason.scam"
        case .dataOrJockey: "community.report.reason.dataOrJockey"
        case .inappropriate: "community.report.reason.inappropriate"
        case .other: "community.report.reason.other"
        }
    }
}

extension CommunityGroupIcon {
    /** The design system's tile the board draws for it. */
    var category: KiraCategory {
        switch self {
        case .paylater: .paylater
        case .stocks: .stocks
        case .crypto: .crypto
        case .salary: .salary
        case .other: .other
        }
    }
}

extension CommunityGroupSummary {
    /** "1.240". */
    var members: String {
        memberCount.formatted(.number.locale(Locale(identifier: "id_ID")))
    }

    /** "Bebas Hutang · WhatsApp", with "· edukasi saja" for a learning-only group. */
    var meta: Text {
        let base = Text("community.group.meta \(Text(category.title)) \(Text(platform.title))")
        return educationOnly ? Text("community.group.metaEducation \(base)") : base
    }
}

extension CalendarDay {
    /** "Maret 2026": a month in Indonesian words. */
    var monthYear: String {
        date.formatted(
            Date.FormatStyle(locale: Locale(identifier: "id_ID"), timeZone: KiraDateFormat.timeZone).month(.wide).year()
        )
    }
}
