import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {

    let session = CameraManager.shared.session

    func makeUIView(context: Context) -> UIView {

        let view = UIView()

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds

        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
