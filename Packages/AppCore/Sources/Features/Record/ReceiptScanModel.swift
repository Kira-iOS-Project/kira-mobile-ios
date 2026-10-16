import Domain
import Foundation
import Observation

/**
 Scan Struk (CAT-05): the dark camera, the frozen photo (CAT-05b) or the picked image (CAT-05c),
 then Baca Struk (CAT-06): Vision reads the text on the device, the rules read store, items and
 total, and only that text is sent. The image lives in memory until it is read, then it is gone.
 */
@MainActor
@Observable
package final class ReceiptScanModel {
    /** Where the scan is. */
    package enum Stage: Equatable, Sendable {
        /** The live camera. */
        case camera
        /** A photo just taken, frozen to check before reading. */
        case photo(Data)
        /** An image picked from the gallery, with its file name when the picker gave one. */
        case picked(Data, fileName: String?)
        /** Vision and the API at work. */
        case reading
    }

    /** Why the scan stopped. */
    package enum Problem: Equatable, Sendable {
        /** The camera could not start or take a photo. */
        case camera
        /** No items with a total the rules could check: take it again or type it in. */
        case unreadable
        /** Sending the text failed. */
        case failed(RecordFailure)
    }

    /** Where the scan is. */
    package internal(set) var stage = Stage.camera
    /** Whether the torch is on. */
    package internal(set) var isTorchOn = false
    /** Why the scan stopped, shown as a dialog. */
    package var problem: Problem?
    /** "Kuota struk: 4 dari 10 bulan ini". */
    package let quota: UsageCounter
    private let dependencies: RecordDependencies
    private let onRead: (SendResult) -> Void
    private let onManual: () -> Void

    /** The scanner with the month's receipt quota; `onRead` gets the sent receipt, `onManual` swaps to Catat Manual. */
    package init(
        quota: UsageCounter, dependencies: RecordDependencies, onRead: @escaping (SendResult) -> Void,
        onManual: @escaping () -> Void
    ) {
        self.quota = quota
        self.dependencies = dependencies
        self.onRead = onRead
        self.onManual = onManual
    }

    /** The image waiting for Baca Struk. */
    package var image: Data? {
        switch stage {
        case .photo(let data), .picked(let data, _): data
        case .camera, .reading: nil
        }
    }

    /** Starts the camera when the screen appears. */
    package func appeared() async {
        do { try await dependencies.camera.start() } catch { problem = .camera }
    }

    /** Stops the camera when the screen goes. */
    package func disappeared() async {
        await dependencies.camera.stop()
    }

    /** The torch button. */
    package func toggleTorch() async {
        isTorchOn.toggle()
        await dependencies.camera.setTorch(isTorchOn)
    }

    /** The shutter: a still photo, frozen for checking. */
    package func capture() async {
        do {
            stage = .photo(try await dependencies.camera.capture())
        } catch {
            problem = .camera
        }
    }

    /** An image picked from the gallery (CAT-05c). */
    package func picked(_ data: Data, fileName: String?) {
        stage = .picked(data, fileName: fileName)
    }

    /** Foto Ulang, and Foto Ulang on the unreadable dialog. */
    package func retake() {
        problem = nil
        stage = .camera
    }

    /** Ketik Manual: the scanner closes and Catat Manual opens. */
    package func typeManually() {
        problem = nil
        onManual()
    }

    /** Baca Struk. */
    package func read() async {
        guard let image else { return }
        stage = .reading
        do {
            let reading = ReceiptTextParser.read(try await dependencies.receiptReader.lines(in: image))
            guard let reading, reading.isBalanced else {
                stage = .camera
                problem = .unreadable
                return
            }
            onRead(try await dependencies.service.sendReceipt(input(for: reading)))
        } catch {
            stage = .camera
            problem = .failed(RecordFailure(error))
        }
    }

    /** What is sent: text only, each item with the category its words name, else Belanja. */
    func input(for reading: ReceiptReading) -> ReceiptInput {
        let items = reading.items.map { line in
            let words = line.name.lowercased().split(separator: " ").map(String.init)
            let category = CategoryKeywords.category(of: words).flatMap { $0.type == .expense ? $0 : nil }
            return ReceiptItemInput(name: line.name, amount: line.amount, category: category ?? .shopping)
        }
        return ReceiptInput(
            clientId: dependencies.makeId(), storeName: reading.storeName ?? dependencies.receiptName,
            occurredAt: printedDate(reading.printedAt) ?? dependencies.clock.now, total: reading.total, items: items)
    }

    /** The printed date in WIB; a date without a time keeps the time of now. */
    private func printedDate(_ printed: ReceiptDate?) -> Date? {
        guard let printed else { return nil }
        let calendar = ChatTimeline.calendar
        let now = calendar.dateComponents([.hour, .minute], from: dependencies.clock.now)
        let components = DateComponents(
            year: printed.year, month: printed.month, day: printed.day, hour: printed.hour ?? now.hour,
            minute: printed.minute ?? now.minute)
        return calendar.date(from: components)
    }
}
