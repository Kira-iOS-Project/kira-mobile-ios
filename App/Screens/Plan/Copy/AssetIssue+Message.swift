/** The sentence under a Tambah Aset field that the last Simpan found wrong: what to do, never blame. */
import Domain
import SwiftUI

extension AssetCheck.Issue {
    /** The field's error line. */
    var message: LocalizedStringResource {
        switch self {
        case .noClass: "asset.issue.class"
        case .noName: "asset.issue.name"
        case .nameTooLong: "asset.issue.nameLong"
        case .noValue: "asset.issue.value"
        case .valueTooLarge: "asset.issue.valueLarge"
        case .futureDay: "asset.issue.day"
        }
    }
}
