/**
 Apple's on-device Foundation Models tidying the drafts the slang rules read (CAT-01), on iOS 26 and
 later with Apple Intelligence on. The model sees the message and the rules' drafts and returns a
 better name and category for each; the amounts are not asked for, so the machine's stay. Without
 the model, or when it fails, the rules' drafts are sent as they are.
 */
import Domain
import Features
import Foundation

#if canImport(FoundationModels)
    import FoundationModels
#endif

nonisolated struct FoundationModelsRefiner: DraftRefining {
    func refine(_ text: String, drafts: [DraftCandidate]) async -> [DraftRefinement]? {
        #if canImport(FoundationModels)
            if #available(iOS 26, *) { return await OnDeviceDraftModel.refine(text, drafts: drafts) }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
    /** The model's answer: one entry per draft, by its number. */
    @available(iOS 26, *)
    @Generable
    struct RefinedDrafts {
        @Guide(description: "One entry for each numbered draft, in the same order")
        var drafts: [RefinedDraft]
    }

    /** A better name and category for one draft. */
    @available(iOS 26, *)
    @Generable
    struct RefinedDraft {
        @Guide(description: "The draft's number from the list")
        var number: Int
        @Guide(description: "A short Indonesian name in Title Case, without the amount, such as Makan Siang")
        var name: String
        @Guide(description: "The category id", .anyOf(TransactionCategory.allCases.map(\.rawValue)))
        var category: String
    }

    @available(iOS 26, *)
    nonisolated enum OnDeviceDraftModel {
        static let instructions = """
            You tidy expense and income drafts read from an Indonesian chat message. For each numbered \
            draft give a short name in Indonesian Title Case (prepositions such as ke, di, dari stay lower \
            case) and the best category id. Never invent drafts and never mention amounts.
            """

        static func refine(_ text: String, drafts: [DraftCandidate]) async -> [DraftRefinement]? {
            guard SystemLanguageModel.default.isAvailable else { return nil }
            let list = drafts.enumerated().map { index, draft in
                "\(index + 1). \(draft.name) (\(draft.type.rawValue), category \(draft.category.rawValue))"
            }
            let prompt = "Message: \(text)\nDrafts:\n\(list.joined(separator: "\n"))"
            do {
                let session = LanguageModelSession(instructions: instructions)
                let answer = try await session.respond(to: prompt, generating: RefinedDrafts.self).content
                return answer.drafts.compactMap { draft in
                    TransactionCategory(rawValue: draft.category).map {
                        DraftRefinement(index: draft.number - 1, name: draft.name, category: $0)
                    }
                }
            } catch {
                return nil
            }
        }
    }
#endif
