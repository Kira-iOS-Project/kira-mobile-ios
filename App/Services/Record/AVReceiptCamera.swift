/**
 Scan Struk's camera: the back wide camera into a photo output, configured and run on its own queue,
 its torch for dim receipts. A photo is JPEG data in memory, never written to the library or disk.
 */
import AVFoundation
import Domain
import Features

nonisolated final class AVReceiptCamera: NSObject, ReceiptCapturing, @unchecked Sendable {
    /** Why the camera cannot be used. */
    enum Failure: Error {
        case denied, noCamera, noPhoto
    }

    /** The session the preview layer shows. */
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "kira.receipt.camera")
    private var device: AVCaptureDevice?
    private var pending: CheckedContinuation<Data, any Error>?

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
    }

    private func applyTorch(_ isOn: Bool) {
        guard let device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
        device.torchMode = isOn ? .on : .off
        device.unlockForConfiguration()
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
