/**
 Riwayat's upload icon: Impor Mutasi is part of Kira Plus (the plan's `voiceAndImport`), so on a
 plan without it the icon opens Paket Kira, as the microphone does for voice.
 */
extension HistoryModel {
    /** Where the upload icon leads. */
    package enum ImportEntry: Equatable, Sendable {
        /** Impor Mutasi. */
        case importer
        /** Paket Kira: the plan has no import. */
        case plans
    }
}
