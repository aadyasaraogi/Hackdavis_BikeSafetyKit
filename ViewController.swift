//import UIKit
import AVFoundation
import UIKit

class ViewController: UIViewController {

    let camera = CameraManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPreview()
        camera.start()
    }

    private func setupPreview() {

        let layer = AVCaptureVideoPreviewLayer(session: camera.session)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(layer)
    }
}
