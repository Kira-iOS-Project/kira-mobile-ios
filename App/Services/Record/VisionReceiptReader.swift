/**
 Reads a receipt's text on the device with Vision (CAT-06): accurate recognition in Indonesian and
 English, each observation turned top-left-origin for `TextFragmentLines`, which joins a row's
 pieces into the printed line. The image is never written anywhere and is gone once read.
 */
import Domain
import Features
import ImageIO
import Vision

nonisolated struct VisionReceiptReader: ReceiptTextReading {
    /** The languages to read, in order, as far as this device's Vision supports them. */
    private static let languages = ["id-ID", "en-US"]

    func lines(in image: Data) async throws -> [String] {
        try await Task.detached(priority: .userInitiated) { try Self.recognize(image) }.value
    }

    private static func recognize(_ image: Data) throws -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let supported = Set((try? request.supportedRecognitionLanguages()) ?? [])
        let chosen = languages.filter(supported.contains)
        if !chosen.isEmpty { request.recognitionLanguages = chosen }
        try VNImageRequestHandler(data: image, orientation: orientation(of: image)).perform([request])
        let fragments = (request.results ?? []).compactMap { observation -> TextFragment? in
            guard let text = observation.topCandidates(1).first?.string else { return nil }
            let box = observation.boundingBox
            return TextFragment(text: text, minX: box.minX, midY: 1 - box.midY, height: box.height)
        }
        return TextFragmentLines.lines(of: fragments)
    }

    /** The photo's EXIF orientation, so a portrait shot is read upright. */
    static func orientation(of image: Data) -> CGImagePropertyOrientation {
        guard let source = CGImageSourceCreateWithData(image as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: CFTypeRef],
            let raw = properties[kCGImagePropertyOrientation] as? UInt32,
            let orientation = CGImagePropertyOrientation(rawValue: raw)
        else { return .up }
        return orientation
    }
}
