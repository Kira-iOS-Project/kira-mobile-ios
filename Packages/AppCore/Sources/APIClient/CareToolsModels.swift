import Domain
import Foundation

/** A debt as `GET /api/debts` lists it. */
package struct DebtDTO: Hashable, Sendable {
    /** The debt's id. */
    package let id: String
    /** The lender as the person named it. */
    package let name: String
    /** The kind of debt. */
    package let kind: DebtKind
    /** What is left to pay, in whole rupiah. */
    package let remaining: Int
    /** The instalment each month, in whole rupiah. */
    package let monthlyInstalment: Int

    init(_ debt: Components.Schemas.Debt) throws {
        id = debt.id
        name = debt.name
        kind = try bridged(debt.kind)
        remaining = debt.remaining
        monthlyInstalment = debt.monthlyInstalment
    }
}

/** A contact of the safety plan: a name and a number. */
package struct SafetyPlanPersonDTO: Hashable, Sendable {
    /** Who it is. */
    package let name: String
    /** The number as written. */
    package let phone: String

    /** A contact to send. */
    package init(name: String, phone: String) {
        self.name = name
        self.phone = phone
    }
}

/** The safety plan as the API reads and writes it. */
package struct SafetyPlanDTO: Hashable, Sendable {
    /** Tanda Aku Mulai Berat. */
    package let warningSigns: String
    /** Hal yang Menenangkanku. */
    package let calmingThings: String
    /** Orang yang Bisa Kuhubungi. */
    package let people: [SafetyPlanPersonDTO]
    /** Layanan Profesional. */
    package let professionals: [SafetyPlanPersonDTO]
    /** Tempat Aku Merasa Aman. */
    package let safePlace: String
    /** When it was saved; nil on a plan being sent. */
    package let updatedAt: Date?

    /** A plan to send. */
    package init(
        warningSigns: String, calmingThings: String, people: [SafetyPlanPersonDTO],
        professionals: [SafetyPlanPersonDTO], safePlace: String, updatedAt: Date? = nil
    ) {
        self.warningSigns = warningSigns
        self.calmingThings = calmingThings
        self.people = people
        self.professionals = professionals
        self.safePlace = safePlace
        self.updatedAt = updatedAt
    }

    init(_ plan: Components.Schemas.SafetyPlan) {
        let input = plan.value1
        self.init(
            warningSigns: input.warningSigns, calmingThings: input.calmingThings,
            people: input.people.map { SafetyPlanPersonDTO(name: $0.name, phone: $0.phone) },
            professionals: input.professionals.map { SafetyPlanPersonDTO(name: $0.name, phone: $0.phone) },
            safePlace: input.safePlace, updatedAt: plan.value2.updatedAt)
    }

    /** The request body. */
    var input: Components.Schemas.SafetyPlanInput {
        Components.Schemas.SafetyPlanInput(
            warningSigns: warningSigns, calmingThings: calmingThings,
            people: people.map { .init(name: $0.name, phone: $0.phone) },
            professionals: professionals.map { .init(name: $0.name, phone: $0.phone) }, safePlace: safePlace)
    }
}
