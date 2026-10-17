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
        box.fit(width: bounds.width)
        box.center = place(AVReceiptCamera.center)
    }

    /** Shows the camera's focus: back to the center when it is there, the pulse while it adjusts. */
    func show(_ focus: AVReceiptCamera.Focus) {
        box.setAdjusting(focus.isAdjusting)
    }

    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        onTap?(previewLayer.captureDevicePointConverted(fromLayerPoint: gesture.location(in: self)))
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

/**
 The receipt guide: four rounded pandan corner brackets around a portrait 3:4 frame, 70% of the
 preview's width, with the status pill above it ("Arahkan struk ke dalam bingkai", "Memfokuskan…",
 "Siap Difoto"). The brackets are soft until the lens is sharp, then solid, with one light tap of the
 haptic engine per lock; under Reduce Motion they change without animating.
 */
private final class FocusBoxView: UIView {
    private let corners = CAShapeLayer()
    private let pill = UILabel()
    private var hasFocused = false
    private var isReady = false
    private var width: CGFloat = 0

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        corners.fillColor = UIColor.clear.cgColor
        corners.lineWidth = 3.5
        corners.lineCap = .round
        layer.addSublayer(corners)
        pill.font = .preferredFont(forTextStyle: .footnote).withWeight(.semibold)
        pill.adjustsFontForContentSizeCategory = true
        pill.textAlignment = .center
        pill.layer.cornerRadius = 17
        pill.layer.masksToBounds = true
        addSubview(pill)
        isAccessibilityElement = true
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: Self, _) in view.paint() }
        paint()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { nil }

    /** Sizes the frame to 70% of `width`, 3:4, and draws its corners. */
    func fit(width: CGFloat) {
        self.width = width
        let frameWidth = (width * 0.7).rounded()
        bounds = CGRect(x: 0, y: 0, width: frameWidth, height: (frameWidth * 4 / 3).rounded())
        corners.path = Self.brackets(in: bounds, length: 32, radius: 16)
        let text = pill.intrinsicContentSize
        pill.frame = CGRect(
            x: (bounds.width - text.width - 28) / 2, y: -text.height - 26, width: text.width + 28,
            height: text.height + 14)
    }

    /** Follows the lens: focusing, then ready once it settles (one light haptic per lock). */
    func setAdjusting(_ isAdjusting: Bool) {
        if isAdjusting {
            hasFocused = true
            isReady = false
        } else if hasFocused, !isReady {
            isReady = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        let change = { self.paint() }
        if UIAccessibility.isReduceMotionEnabled {
            change()
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: change)
        }
    }

    private func paint() {
        corners.strokeColor = UIColor(Color.pandan).withAlphaComponent(isReady ? 1 : 0.55).cgColor
        pill.backgroundColor = UIColor(Color.surfaceRaised)
        pill.textColor = UIColor(isReady ? Color.pandan : Color.ink)
        let status: String
        if isReady {
            status = String(localized: "record.scan.sharp")
        } else if hasFocused {
            status = String(localized: "record.scan.focusing")
        } else {
            status = String(localized: "record.scan.aim")
        }
        pill.text = status
        accessibilityLabel = String(localized: "record.scan.focusArea")
        accessibilityValue = status
        fit(width: width)
    }

    /** Four corner brackets, `length` long, rounded `radius`, at the corners of `rect`. */
    private static func brackets(in rect: CGRect, length: CGFloat, radius: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let inset = rect.insetBy(dx: 1.75, dy: 1.75)
        for (corner, alongX, alongY) in [
            (CGPoint(x: inset.minX, y: inset.minY), 1.0, 1.0), (CGPoint(x: inset.maxX, y: inset.minY), -1.0, 1.0),
            (CGPoint(x: inset.maxX, y: inset.maxY), -1.0, -1.0), (CGPoint(x: inset.minX, y: inset.maxY), 1.0, -1.0),
        ] {
            path.move(to: CGPoint(x: corner.x, y: corner.y + alongY * length))
            path.addLine(to: CGPoint(x: corner.x, y: corner.y + alongY * radius))
            path.addQuadCurve(
                to: CGPoint(x: corner.x + alongX * radius, y: corner.y), controlPoint: corner)
            path.addLine(to: CGPoint(x: corner.x + alongX * length, y: corner.y))
        }
        return path.cgPath
    }
}

extension UIFont {
    /** The same font at `weight`, keeping its Dynamic Type size. */
    fileprivate func withWeight(_ weight: UIFont.Weight) -> UIFont {
        UIFont.systemFont(ofSize: pointSize, weight: weight)
    }
}
