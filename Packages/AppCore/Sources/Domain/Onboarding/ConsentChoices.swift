/**
 Persetujuan Data (ONB-08): the purposes a person can turn off, as `PUT /me/consents` takes them.
 The core purpose (recording and the Kira Score) is always on and not part of the choice.
 */
package struct ConsentChoices: Hashable, Sendable {
    /** "Kira AI Membaca Chat dan Struk": on-device reading of chats, receipts and voice. */
    package var aiProcessing: Bool
    /** "Ringkasan Mingguan": the weekly summary inside the app. */
    package var weeklySummary: Bool

    /** The choices as given; both are on when the screen opens. */
    package init(aiProcessing: Bool = true, weeklySummary: Bool = true) {
        self.aiProcessing = aiProcessing
        self.weeklySummary = weeklySummary
    }
}
