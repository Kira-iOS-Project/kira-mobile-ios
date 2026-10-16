import Domain
import Foundation
import Testing

@testable import Features

@Suite("MessageReader")
struct MessageReaderTests {
    private let text = "makan siang 25rb, grab ke kantor 18rb"

    @Test("without a model the slang rules' drafts go as they are")
    func rules() async {
        let read = await MessageReader(fallbackName: "Transaksi", refiner: nil).read(text, at: Fixtures.noon)
        #expect(read.parser == .slangRules)
        #expect(read.drafts.map(\.name) == ["Makan Siang", "Grab ke Kantor"])
        #expect(read.drafts.allSatisfy { $0.occurredAt == Fixtures.noon })
    }

    @Test("the model renames and recategorises, never changing an amount or a direction")
    func refined() async {
        let refiner = FakeRefiner(refinements: [
            DraftRefinement(index: 0, name: " Makan Siang di Kantor ", category: .food),
            DraftRefinement(index: 1, name: "Ojek Online", category: .transport),
            DraftRefinement(index: 1, name: "  ", category: .transport),
            DraftRefinement(index: 0, name: "Gaji", category: .salary),
            DraftRefinement(index: 9, name: "Lain", category: .food),
        ])
        let read = await MessageReader(fallbackName: "Transaksi", refiner: refiner).read(text, at: Fixtures.noon)
        #expect(read.parser == .onDeviceModel)
        #expect(read.drafts.map(\.name) == ["Makan Siang di Kantor", "Ojek Online"])
        #expect(read.drafts.map(\.amount) == [25_000, 18_000])
    }

    @Test("a model without Indonesian is never asked: the rules' drafts go as they are")
    func noIndonesian() async {
        let refiner = FakeRefiner(
            refinements: [DraftRefinement(index: 0, name: "Makan Siang di Kantor", category: .food)],
            knowsIndonesian: false)
        let read = await MessageReader(fallbackName: "Transaksi", refiner: refiner).read(text, at: Fixtures.noon)
        #expect(read.parser == .slangRules)
        #expect(read.drafts.map(\.name) == ["Makan Siang", "Grab ke Kantor"])
    }

    @Test("a model with nothing usable, no answer, or no drafts leaves the rules")
    func unused() async {
        let useless = FakeRefiner(refinements: [DraftRefinement(index: 0, name: "", category: .food)])
        #expect(await MessageReader(fallbackName: "T", refiner: useless).read(text, at: .now).parser == .slangRules)
        let silent = FakeRefiner(refinements: nil)
        #expect(await MessageReader(fallbackName: "T", refiner: silent).read(text, at: .now).parser == .slangRules)
        let none = await MessageReader(fallbackName: "T", refiner: useless).read("halo", at: .now)
        #expect(none.drafts.isEmpty)
        #expect(none.parser == .slangRules)
    }
}
