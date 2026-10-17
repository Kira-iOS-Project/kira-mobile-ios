/**
 Scan Struk's camera: the back wide camera into a photo output, configured and run on its own queue,
 its torch for dim receipts. A photo is JPEG data in memory, never written to the library or disk.
 It focuses and exposes at the center, continuously and for near subjects (a receipt is close), and
 again whenever the scene changes; a tap focuses where it lands, then the center takes over after
 three seconds. `onFocus` tells the preview's focus box when the lens is focusing and when it is back
 at the center.
 */
import AVFoundation
import Features

nonisolated final class AVReceiptCamera: NSObject, ReceiptCapturing, @unchecked Sendable {
    /** Why the camera cannot be used. */
    enum Failure: Error {
        case denied, noCamera, noPhoto
    }

    /** What the focus box shows. */
    struct Focus: Equatable, Sendable {
        /** The lens is still moving to a sharp picture. */
        var isAdjusting: Bool
        /** Focus is at the center, continuously (not held at a tapped point). */
        var isCentered: Bool
    }

    /** The middle of the picture, in the device's 0…1 coordinates. */
    static let center = CGPoint(x: 0.5, y: 0.5)
    /** How long a tapped point holds before the center takes over again. */
    private static let tapHold: TimeInterval = 3

    /** Told on the main actor whenever the focus changes, for the focus box. */
    var onFocus: (@MainActor @Sendable (Focus) -> Void)?

    /** The session the preview layer shows. */
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "kira.receipt.camera")
    private var device: AVCaptureDevice?
    private var pending: CheckedContinuation<Data, any Error>?
    private var focus = Focus(isAdjusting: false, isCentered: true)
    private var adjusting: NSKeyValueObservation?
    private var sceneChanges: (any NSObjectProtocol)?
    private var recenter: DispatchWorkItem?

    func start() async throws {
        guard await AVCaptureDevice.requestAccess(for: .video) else { throw Failure.denied }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            queue.async {
                do {
                    try self.configure()
                    if !self.session.isRunning { self.session.startRunning() }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func stop() {
        queue.async {
            self.applyTorch(false)
            self.session.stopRunning()
        }
    }

    func capture() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                guard self.session.isRunning, self.pending == nil else {
                    continuation.resume(throwing: Failure.noPhoto)
                    return
                }
                self.pending = continuation
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                self.output.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    func setTorch(_ isOn: Bool) {
        queue.async { self.applyTorch(isOn) }
    }

    /** Adds the back camera and the photo output once. */
    private func configure() throws {
        guard device == nil else { return }
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw Failure.noCamera
        }
        let input = try AVCaptureDeviceInput(device: camera)
        session.beginConfiguration()
        session.sessionPreset = .photo
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
        device = camera
        if (try? camera.lockForConfiguration()) != nil {
            if camera.isAutoFocusRangeRestrictionSupported { camera.autoFocusRangeRestriction = .near }
            camera.isSubjectAreaChangeMonitoringEnabled = true
            camera.unlockForConfiguration()
        }
        aim(at: Self.center, isCentered: true)
        adjusting = camera.observe(\.isAdjustingFocus, options: [.new]) { [weak self] _, change in
            guard let self, let isAdjusting = change.newValue else { return }
            queue.async { self.report { $0.isAdjusting = isAdjusting } }
        }
        sceneChanges = NotificationCenter.default.addObserver(
            forName: AVCaptureDevice.subjectAreaDidChangeNotification, object: camera, queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            queue.async {
                self.recenter?.cancel()
                self.aim(at: Self.center, isCentered: true)
            }
        }
    }

    private func applyTorch(_ isOn: Bool) {
        guard let device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
        device.torchMode = isOn ? .on : .off
        device.unlockForConfiguration()
    }
}

/** Focus: the center, continuously, or a tapped point for a moment. */
extension AVReceiptCamera {
    /** Tap to focus: focuses and exposes at `point` (device coordinates), then at the center after three seconds. */
    func focus(at point: CGPoint) {
        queue.async {
            self.recenter?.cancel()
            self.aim(at: point, isCentered: false)
            let item = DispatchWorkItem { [weak self] in self?.aim(at: Self.center, isCentered: true) }
            self.recenter = item
            self.queue.asyncAfter(deadline: .now() + Self.tapHold, execute: item)
        }
    }

    /**
     Focuses and exposes at `point`: continuously at the center, once at a tapped point, so the lens
     holds there until the center takes over.
     */
    private func aim(at point: CGPoint, isCentered: Bool) {
        guard let device, (try? device.lockForConfiguration()) != nil else { return }
        if device.isFocusPointOfInterestSupported { device.focusPointOfInterest = point }
        let focusMode: AVCaptureDevice.FocusMode = isCentered ? .continuousAutoFocus : .autoFocus
        if device.isFocusModeSupported(focusMode) { device.focusMode = focusMode }
        if device.isExposurePointOfInterestSupported { device.exposurePointOfInterest = point }
        let exposureMode: AVCaptureDevice.ExposureMode = isCentered ? .continuousAutoExposure : .autoExpose
        if device.isExposureModeSupported(exposureMode) { device.exposureMode = exposureMode }
        device.isSubjectAreaChangeMonitoringEnabled = true
        device.unlockForConfiguration()
        report { $0.isCentered = isCentered }
    }

    /** Changes the focus state on the camera's queue and tells the box on the main actor. */
    private func report(_ change: (inout Focus) -> Void) {
        var next = focus
        change(&next)
        guard next != focus else { return }
        focus = next
        guard let onFocus else { return }
        Task { @MainActor in onFocus(next) }
    }
}

extension AVReceiptCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error _: (any Error)?) {
        let data = photo.fileDataRepresentation()
        queue.async {
            let continuation = self.pending
            self.pending = nil
            if let data {
                continuation?.resume(returning: data)
            } else {
                continuation?.resume(throwing: Failure.noPhoto)
            }
        }
    }
}
