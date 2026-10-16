/**
 The live picture of Scan Struk's camera, filling its frame. A camera without a session (previews,
 the simulator) leaves the frame's dark mask showing.
 */
import AVFoundation
import Domain
import Features
import SwiftUI
import UIKit

struct CameraPreview: UIViewRepresentable {
    let camera: any ReceiptCapturing

    func makeUIView(context _: Context) -> PreviewLayerView {
        let view = PreviewLayerView()
        view.previewLayer.videoGravity = .resizeAspectFill
        view.previewLayer.session = (camera as? AVReceiptCamera)?.session
        view.isAccessibilityElement = false
        return view
    }

    func updateUIView(_: PreviewLayerView, context _: Context) {}
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
