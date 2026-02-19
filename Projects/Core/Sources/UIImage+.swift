//
//  UIImage+.swift
//  MeloMeter
//
//  Created by 양승완 on 4/6/25.
//

import UIKit

public extension UIImage {
    func normalizedImage() -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        let renderedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
        return renderedImage
    }

    func grayscaleImage() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let outputImage = filter.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
