/** The goal mappings between the generated client and the Domain that no route test reaches. */
import Domain
import Testing

@testable import APIClient

@Suite("Goal mappings")
struct GoalMappingTests {
    @Test("every goal kind is sent under the API's own name")
    func kinds() {
        for kind in GoalKind.allCases {
            #expect(Components.Schemas.CreateGoal.KindPayload(kind).rawValue == kind.rawValue)
        }
    }

    @Test("inputs read back as numbers, texts and flags")
    func inputs() {
        let inputs = Components.Schemas.GoalInputs(
            additionalProperties: [
                "years": .init(value1: 5), "city": .init(value2: "Bandung"), "married": .init(value3: true),
            ])
        #expect(inputs.domain == ["years": .number(5), "city": .text("Bandung"), "married": .flag(true)])
    }
}
