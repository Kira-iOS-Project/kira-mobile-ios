import Domain
import Observation

/**
 The answers of Kenali Profil Risikomu while the app runs: they survive Kembali, Lanjut, closing
 the quiz ("Tutup kuis, jawaban tersimpan") and opening it again, and Ulangi Kuis starts from
 them. They are kept in memory only, for as long as the app's process lives (until the app quits
 or the system ends it), and never written to the device; the server keeps the saved ones.
 */
@MainActor
@Observable
package final class RiskQuizDraft {
    /** The options chosen so far. */
    package var answers: RiskAnswers

    /** A draft holding `answers` (none by default). */
    package init(answers: RiskAnswers = RiskAnswers()) {
        self.answers = answers
    }
}
