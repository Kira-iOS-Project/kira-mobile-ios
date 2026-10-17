/**
 The risk profile on the canvas's sample, so the quiz and Hasil Kuis run in previews, under
 `-KiraScreen` and in the app before the live service lands. It answers the server's table for the
 boards' fixtures: [1, 1, 1, 0, 1] (the persona) is Moderat, [2, 2, 3, 3, 3] Agresif, any third
 answer "Kurang dari 1 Tahun" Konservatif; other answers read as Moderat here, never scored on the
 device in the app. `failedSaves` saves fail first with `problem`, then saves go through.
 */
import APIClient
import Domain
import Features

actor PreviewRiskProfileService: RiskProfileService {
    private var saved: SavedRiskProfile?
    private var failedSaves: Int
    private let problem: AppProblem

    init(saved: SavedRiskProfile? = nil, failedSaves: Int = 0, problem: AppProblem = .connectionLost) {
        self.saved = saved
        self.failedSaves = failedSaves
        self.problem = problem
    }

    func savedProfile() -> SavedRiskProfile? { saved }

    func saveRiskProfile(answers: [Int]) throws -> RiskProfile {
        if failedSaves > 0 {
            failedSaves -= 1
            throw problem
        }
        let profile = Self.profile(answers)
        saved = SavedRiskProfile(profile: profile, answers: RiskAnswers(answers))
        return profile
    }

    /**
     The board's persona: Menambah Dana Pelan-pelan, Diam dan Tunggu Pulih, 1 sampai 3 Tahun, Belum
     Pernah Sama Sekali, and the second range.
     */
    static let persona = [1, 1, 1, 0, 1]

    /** The server's answer for the fixtures; anything else reads as Moderat here. */
    private static func profile(_ answers: [Int]) -> RiskProfile {
        if answers == [2, 2, 3, 3, 3] { return .aggressive }
        return answers.dropFirst(2).first == 0 ? .conservative : .moderate
    }

    /** A saved profile with the fixture that scores it. */
    static func saved(_ profile: RiskProfile) -> SavedRiskProfile {
        let answers: [Int] =
            switch profile {
            case .conservative: [0, 0, 0, 0, 0]
            case .moderate: persona
            case .aggressive: [2, 2, 3, 3, 3]
            }
        return SavedRiskProfile(profile: profile, answers: RiskAnswers(answers))
    }
}
