import AVFoundation
import UIKit

final class CameraManager: NSObject {

    static let shared = CameraManager()

    let session = AVCaptureSession()

    var onFrame: ((UIImage) -> Void)?
    var onAIResult: ((String) -> Void)?   // 🔥 MISSING LINK FIX

    private let output = AVCaptureVideoDataOutput()
    private let ciContext = CIContext()

    private var lastAIRequestTime: CFTimeInterval = 0
    private let aiCooldown: CFTimeInterval = 0.8

    override init() {
        super.init()
        configure()
    }

    private func configure() {

        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back) else {
            print("No camera")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            print("Camera error:", error)
            return
        }

        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_32BGRA
        ]

        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cam.queue"))

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func start() {
        if !session.isRunning {
            session.startRunning()
        }
    }
}

// MARK: - Frame Processing
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: buffer)

        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

        let image = UIImage(cgImage: cgImage)

        DispatchQueue.main.async {

            // 1. UI preview frame
            self.onFrame?(image)

            // 2. motion gate
            guard MotionDetector.shared.detectMotion(current: image) else {
                return
            }

            // 3. throttle AI
            let now = CACurrentMediaTime()
            guard now - self.lastAIRequestTime > self.aiCooldown else { return }
            self.lastAIRequestTime = now

            // 4. AI call
            OpenAIService.shared.analyze(frame: image) { result in

                print("🧠 AI:", result)

                DispatchQueue.main.async {
                    self.onAIResult?(result)   // 🔥 UI now gets updates
                }

                // 5. BLE output (still here, correct)
                let command: String

                if result.contains("CAR") {
                    command = "C"
                } else if result.contains("DANGER") {
                    command = "D"
                } else {
                    command = "S"
                }

                BLEManager.shared.send(command)

                FramePipeline.shared.push(image)
            }
        }
    }
}
