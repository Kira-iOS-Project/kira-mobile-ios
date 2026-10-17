/**
 The options chosen in Kenali Profil Risikomu, one per question, as 0-based indexes in the order
 each board shows them. A question not answered yet has none.
 */
package struct RiskAnswers: Hashable, Sendable {
    private var choices: [Int?]

    /** No answer yet, or `indexes` in the questions' order (the saved answers, the board's persona). */
    package init(_ indexes: [Int] = []) {
        choices = RiskQuestion.allCases.map { question in
            indexes.indices.contains(question.rawValue - 1) ? indexes[question.rawValue - 1] : nil
        }
    }

    /** The option chosen for `question`, if any. */
    package func choice(for question: RiskQuestion) -> Int? {
        choices[question.rawValue - 1]
    }

    /** Chooses `option` for `question`; an index outside the four options is ignored. */
    package mutating func choose(_ option: Int, for question: RiskQuestion) {
        guard (0..<RiskQuestion.optionCount).contains(option) else { return }
        choices[question.rawValue - 1] = option
    }

    /** The five indexes `PUT /risk-profile` sends, nil while a question is unanswered. */
    package var indexes: [Int]? {
        let answered = choices.compactMap(\.self)
        return answered.count == RiskQuestion.total ? answered : nil
    }
}
