/**
 Catat's and Riwayat's services (CAT-01 to CAT-12), built once by the composition root from its API
 client and read by the record slot and the record routes from the environment. KiraApp sets
 `.live(api:)`, or nothing under `-KiraPreviewServices`; unset, a debug build runs both flows on
 their preview services and a release build shows the empty slot, never sample data.
 */
import APIClient
import Features
import SwiftUI

struct RecordComposition {
    /** Catat's calls. */
    let record: any RecordService
    /** Riwayat's, Detail Transaksi's, Riwayat Percakapan's and Impor Mutasi's calls. */
    let history: any HistoryService

    /** Both services over the API client `api`. */
    static func live(api: KiraAPI) -> RecordComposition {
        RecordComposition(record: LiveRecordService(api: api), history: LiveHistoryService(api: api))
    }

    /** What the slots use when the root set nothing: the preview services in a debug build only. */
    static var fallback: RecordComposition? {
        #if DEBUG
            RecordComposition(record: PreviewRecordService(), history: PreviewHistoryService())
        #else
            nil
        #endif
    }
}

extension EnvironmentValues {
    /** Catat's and Riwayat's services; nil until the composition root sets them. */
    @Entry var recordComposition: RecordComposition?
}
