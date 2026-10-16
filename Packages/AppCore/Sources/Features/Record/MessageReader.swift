import Domain
import Foundation

/**
 Turns a chat message into the drafts sent with it (CAT-01): the slang rules read every amount,
 then the on-device model, when there is one and it supports Indonesian, may give each draft a
 better name and category. The amounts are always the rules', so the machine validates them, not
 the model.
 */
package struct MessageReader: Sendable {
    private let parser: DraftTextParser
    private let refiner: (any DraftRefining)?

    /** `fallbackName` names a draft whose message names only an amount ("Transaksi"). */
    package init(fallbackName: String, refiner: (any DraftRefining)?) {
        self.parser = DraftTextParser(fallbackName: fallbackName)
        self.refiner = refiner
    }

    /** The drafts of `text` at `date`, and which reader produced them. */
    package func read(_ text: String, at date: Date) async -> (drafts: [DraftInput], parser: DraftParserKind) {
        var candidates = parser.parse(text)
        guard !candidates.isEmpty, let refiner, await refiner.supportsIndonesian(),
            let refinements = await refiner.refine(text, drafts: candidates)
        else {
            return (candidates.map { DraftInput($0, occurredAt: date) }, .slangRules)
        }
        var applied = false
        for refinement in refinements where candidates.indices.contains(refinement.index) {
            let name = refinement.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, refinement.category.type == candidates[refinement.index].type else { continue }
            candidates[refinement.index].name = name
            candidates[refinement.index].category = refinement.category
            applied = true
        }
        return (candidates.map { DraftInput($0, occurredAt: date) }, applied ? .onDeviceModel : .slangRules)
    }
}
