/**
 Reads a receipt's text on the device with Vision (CAT-06): the photo upright and scaled to about
 2000 pixels, accurate recognition in Indonesian and English with language correction, each
 observation turned top-left-origin for `TextFragmentLines`, which joins a row's pieces into the
 printed line in reading order. The image is never written anywhere and is gone once read.
 */
import Domain
import Features
import Foundation
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
        try handler(for: image).perform([request])
        let fragments = (request.results ?? []).compactMap { observation -> TextFragment? in
            guard let text = observation.topCandidates(1).first?.string else { return nil }
            let box = observation.boundingBox
            return TextFragment(text: text, minX: box.minX, midY: 1 - box.midY, height: box.height)
        }
        return TextFragmentLines.lines(of: fragments)
    }

    /**
     The photo upright and at most `maxSide` pixels on its long edge: a 12-megapixel shot read whole
     is slow and no sharper for Vision, and its EXIF orientation is applied while it is scaled. A
     photo ImageIO cannot read goes to Vision as it is, with its orientation.
     */
    static func handler(for image: Data, maxSide: Int = 2000) -> VNImageRequestHandler {
        let options: [CFString: CFTypeRef] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true as CFBoolean,
            kCGImageSourceCreateThumbnailWithTransform: true as CFBoolean,
            kCGImageSourceThumbnailMaxPixelSize: maxSide as CFNumber,
        ]
        guard let source = CGImageSourceCreateWithData(image as CFData, nil),
            let scaled = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
        else { return VNImageRequestHandler(data: image, orientation: orientation(of: image)) }
        return VNImageRequestHandler(cgImage: scaled, orientation: .up)
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
