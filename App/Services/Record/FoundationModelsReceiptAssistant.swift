/**
 The on-device model's look at a receipt photo (iOS 27 and later, a model with image input): the
 store's printed name and whether it is a receipt or a transfer proof, never a number. On-device
 only: SystemLanguageModel, never Private Cloud Compute, which has a quota. Any error, or an older
 iOS, gives nothing, and the receipt goes with what Vision and the parser read.
 */
import Features
import Foundation
import ImageIO

#if canImport(FoundationModels)
    import FoundationModels
#endif

nonisolated struct FoundationModelsReceiptAssistant: ReceiptAssisting {
    func glance(at image: Data) async -> ReceiptGlance? {
        #if canImport(FoundationModels)
            if #available(iOS 27, *) { return await OnDeviceReceiptLook.glance(at: image) }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
    /** What the model is asked to read off the photo. */
    @available(iOS 27, *)
    @Generable
    struct ReceiptLook {
        @Guide(description: "The store or merchant name exactly as printed at the top, or empty when there is none")
        var storeName: String
    }

    @available(iOS 27, *)
    nonisolated enum OnDeviceReceiptLook {
        static let instructions = """
            You look at a photo of an Indonesian shop receipt or bank transfer proof. Copy the store or \
            merchant name exactly as printed. Do not read prices, totals or account numbers.
            """

        static func glance(at data: Data) async -> ReceiptGlance? {
            let model = SystemLanguageModel.default
            guard model.isAvailable, model.capabilities.contains(.vision),
                let source = CGImageSourceCreateWithData(data as CFData, nil),
                let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { return nil }
            let orientation = VisionReceiptReader.orientation(of: data)
            do {
                let session = LanguageModelSession(model: model, instructions: instructions)
                let look = try await session.respond(generating: ReceiptLook.self) {
                    "Read the store name of this document."
                    Attachment(image, orientation: orientation)
                }
                .content
                let name = look.storeName.trimmingCharacters(in: .whitespacesAndNewlines)
                return ReceiptGlance(storeName: name.isEmpty ? nil : name)
            } catch {
                return nil
            }
        }
    }
#endif
