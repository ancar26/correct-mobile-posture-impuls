import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewLayerView {
        PreviewLayerView(session: session)
    }

    func updateUIView(_ uiView: PreviewLayerView, context: Context) {}
}

final class PreviewLayerView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) { fatalError() }
}
