/**
 The live picture of Scan Struk's camera, filling its frame, with the focus box: a pandan square at
 the center that pulses while the lens focuses and settles once it is sharp. A tap focuses where it
 lands and the box follows it, back to the center when the camera returns there. A camera without a
 session (previews, the simulator) leaves the frame's dark mask showing.
 */
import AVFoundation
import Features
import SwiftUI
import UIKit

struct CameraPreview: View {
    let camera: any ReceiptCapturing
    @State private var focus = AVReceiptCamera.Focus(isAdjusting: false, isCentered: true)
    @State private var tapped: CGPoint?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CameraLayer(camera: camera) { point in tapped = point }
                FocusBox(isAdjusting: focus.isAdjusting)
                    .position(
                        focus.isCentered ? CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2) : tapped ?? .zero)
            }
        }
        .onAppear {
            (camera as? AVReceiptCamera)?.onFocus = { focus = $0 }
        }
    }
}

/** The focus box: a 72 pt rounded square, a 2 pt pandan line, no shadow; it pulses while focusing. */
private struct FocusBox: View {
    let isAdjusting: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
            .stroke(.pandan, lineWidth: 2)
            .frame(width: 72, height: 72)
            .scaleEffect(isAdjusting && !reduceMotion ? 1.12 : 1)
            .opacity(isAdjusting && reduceMotion ? 0.6 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: isAdjusting)
            .allowsHitTesting(false)
            .accessibilityElement()
            .accessibilityLabel(Text("record.scan.focusArea"))
    }
}

/** The camera's preview layer, with a tap that focuses where it lands (in the device's coordinates). */
private struct CameraLayer: UIViewRepresentable {
    let camera: any ReceiptCapturing
    let onTap: (CGPoint) -> Void

    func makeUIView(context: Context) -> PreviewLayerView {
        let view = PreviewLayerView()
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = (camera as? AVReceiptCamera)?.session
        view.isAccessibilityElement = false
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:))))
        return view
    }

    func updateUIView(_: PreviewLayerView, context: Context) {
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    /** Turns a tap on the layer into a focus point for the camera and a place for the box. */
    final class Coordinator: NSObject {
        var parent: CameraLayer

        init(parent: CameraLayer) {
            self.parent = parent
        }

        @objc func tap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? PreviewLayerView, let camera = parent.camera as? AVReceiptCamera else {
                return
            }
            let point = gesture.location(in: view)
            camera.focus(at: view.previewLayer.captureDevicePointConverted(fromLayerPoint: point))
            parent.onTap(point)
        }
    }
}

/** A view whose layer is the camera's preview layer. */
final class PreviewLayerView: UIView {
    override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    /** The layer, as the preview layer it is. */
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else { return AVCaptureVideoPreviewLayer() }
        return layer
    }
}
