import Domain
import Observation

/**
 The answers of Kenali Profil Risikomu while the app runs: they survive Kembali, Lanjut, closing
 the quiz ("Tutup kuis, jawaban tersimpan") and opening it again, and Ulangi Kuis starts from
 them. They are kept in memory only, until the session ends (Keluar, a deleted account or a
 refused session) or the app quits, and never written to the device; the server keeps the saved
 ones.
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

    /** Forgets the answers when the session ends, so the next person starts the quiz empty. */
    package func clear() {
        answers = RiskAnswers()
    }
}
