/**
 The live picture of Scan Struk's camera, filling its frame, with the focus box: a pandan square
 where the camera focuses, that pulses while the lens focuses and settles once it is sharp. The box is
 placed by the preview layer itself (`layerPointConverted(fromCaptureDevicePoint:)`), so it sits
 exactly on the picture's center that the device's (0.5, 0.5) focus point means, and on a tapped
 point when a tap moves the focus; back to the center when the camera returns there. A camera
 without a session (previews, the simulator) leaves the frame's dark mask showing, with the box at the
 middle of the frame.
 */
import AVFoundation
import Features
import SwiftUI
import UIKit

struct CameraPreview: UIViewRepresentable {
    let camera: any ReceiptCapturing

    func makeUIView(context _: Context) -> PreviewLayerView {
        let view = PreviewLayerView()
        view.previewLayer.videoGravity = .resizeAspectFill
        let receiptCamera = camera as? AVReceiptCamera
        view.previewLayer.session = receiptCamera?.session
        view.onTap = { [weak receiptCamera] devicePoint in receiptCamera?.focus(at: devicePoint) }
        receiptCamera?.onFocus = { [weak view] focus in view?.show(focus) }
        return view
    }

    func updateUIView(_: PreviewLayerView, context _: Context) {}
}

/** A view whose layer is the camera's preview layer, with the focus box on it. */
final class PreviewLayerView: UIView {
    override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    /** Told the device point of a tap, to focus there. */
    var onTap: ((CGPoint) -> Void)?
    private let box = FocusBoxView()
    private var focusPoint = AVReceiptCamera.center

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(box)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    /** The layer, as the preview layer it is. */
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else { return AVCaptureVideoPreviewLayer() }
        return layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        box.center = place(focusPoint)
    }

    /** Shows the camera's focus: back to the center when it is there, the pulse while it adjusts. */
    func show(_ focus: AVReceiptCamera.Focus) {
        if focus.isCentered { focusPoint = AVReceiptCamera.center }
        box.center = place(focusPoint)
        box.setAdjusting(focus.isAdjusting)
    }

    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: gesture.location(in: self))
        focusPoint = devicePoint
        box.center = place(devicePoint)
        onTap?(devicePoint)
    }

    /** Where `devicePoint` falls on the visible picture; the frame's middle while there is no picture. */
    private func place(_ devicePoint: CGPoint) -> CGPoint {
        let point = previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint)
        guard point.x.isFinite, point.y.isFinite, bounds.contains(point) else {
            return CGPoint(x: bounds.midX, y: bounds.midY)
        }
        return point
    }
}

/** The focus box: a 72 pt rounded square, a 2 pt pandan line, no shadow; it pulses while focusing. */
private final class FocusBoxView: UIView {
    private static let side: CGFloat = 72

    override init(frame _: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Self.side, height: Self.side))
        isUserInteractionEnabled = false
        layer.borderColor = UIColor(Color.pandan).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = KiraRadius.medium
        layer.cornerCurve = .continuous
        isAccessibilityElement = true
        accessibilityLabel = String(localized: "record.scan.focusArea")
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (box: Self, _) in
            box.layer.borderColor = UIColor(Color.pandan).cgColor
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    /** A short pulse while the lens adjusts, a fade under Reduce Motion; settles once it is sharp. */
    func setAdjusting(_ isAdjusting: Bool) {
        if UIAccessibility.isReduceMotionEnabled {
            alpha = isAdjusting ? 0.6 : 1
            return
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
            self.transform = isAdjusting ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
        }
    }
}
