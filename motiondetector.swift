import UIKit
import CoreImage

final class MotionDetector {

    static let shared = MotionDetector()

    private var previousAverage: CGFloat = 0
    private var lastTriggerTime: CFTimeInterval = 0
    private let cooldown: CFTimeInterval = 0.7

    func detectMotion(current: UIImage) -> Bool {

        guard let cgImage = current.cgImage else { return false }

        let ciImage = CIImage(cgImage: cgImage)

        let extent = ciImage.extent
        let inputExtent = CIVector(x: extent.origin.x,
                                   y: extent.origin.y,
                                   z: extent.size.width,
                                   w: extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage") else {
            return false
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(inputExtent, forKey: kCIInputExtentKey)

        guard let output = filter.outputImage else { return false }

        var bitmap = [UInt8](repeating: 0, count: 4)

        let context = CIContext()

        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        let r = CGFloat(bitmap[0])
        let g = CGFloat(bitmap[1])
        let b = CGFloat(bitmap[2])

        let currentAvg = (r + g + b) / 3.0
        let diff = abs(currentAvg - previousAverage)
        previousAverage = currentAvg

        let now = CACurrentMediaTime()

        if diff > 5 {   // <-- stable threshold for real motion
            if now - lastTriggerTime > cooldown {
                lastTriggerTime = now
                return true
            }
        }

        return false
    }
}
