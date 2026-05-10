//
//  framepipeline.swift
//  bikesystem
//
//  Created by Kavi Rajesh on 5/9/26.
//

import UIKit

final class FramePipeline {

    static let shared = FramePipeline()

    private var frames: [UIImage] = []
    private let maxSize = 10

    private let queue = DispatchQueue(label: "frame.pipeline")

    func push(_ frame: UIImage) {

        queue.async {

            if self.frames.count > self.maxSize {
                self.frames.removeFirst()
            }

            self.frames.append(frame)

            print("📦 Frame queued")
        }
    }

    func pop() -> UIImage? {

        queue.sync {
            return frames.isEmpty ? nil : frames.removeFirst()
        }
    }
}
