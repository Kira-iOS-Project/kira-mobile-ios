/**
 Apple's on-device Foundation Models as the second reader of a Catat message (PED-02), on iOS 26
 and later with Apple Intelligence on, and only once Apple's model supports Indonesian (it does not
 yet, so today the reviewed phrase list decides alone). `CrisisDetector` asks it only for the
 debatable case and lets it raise the list's level, never lower it. The message never leaves the
 device, and the model only classifies: Kira's reply stays the team's fixed template.
 */
import Domain
import Features
import Foundation

#if canImport(FoundationModels)
    import FoundationModels
#endif

nonisolated struct FoundationModelsCrisisRefiner: CrisisRefining {
    func supportsIndonesian() -> Bool {
        #if canImport(FoundationModels)
            if #available(iOS 26, *) {
                return SystemLanguageModel.default.supportsLocale(Locale(identifier: "id_ID"))
            }
        #endif
        return false
    }

    func assess(_ text: String) async -> CrisisAssessment? {
        #if canImport(FoundationModels)
            if #available(iOS 26, *) { return await OnDeviceCrisisModel.assess(text) }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
    /** The model's reading of one message. */
    @available(iOS 26, *)
    @Generable
    struct CrisisReading {
        @Guide(description: "none, concern or danger", .anyOf(["none", "concern", "danger"]))
        var level: String
    }

    @available(iOS 26, *)
    nonisolated enum OnDeviceCrisisModel {
        static let instructions = """
            You read one Indonesian chat message, often informal, from a personal finance app and say \
            whether its writer may be in crisis. danger: any words about ending their life, wanting to \
            die or harming themselves. concern: despair or hopelessness about their life, without those \
            words. none: anything else, including a tiring day, stress about bills or money, or an \
            ordinary expense. When unsure between two levels, choose the stronger one.
            """

        static func assess(_ text: String) async -> CrisisAssessment? {
            guard SystemLanguageModel.default.isAvailable else { return nil }
            do {
                let session = LanguageModelSession(instructions: instructions)
                let reading = try await session.respond(to: text, generating: CrisisReading.self).content
                switch reading.level {
                case "danger": return .signal(.danger)
                case "concern": return .signal(.concern)
                default: return CrisisAssessment.none
                }
            } catch {
                return nil
            }
        }
    }
#endif
