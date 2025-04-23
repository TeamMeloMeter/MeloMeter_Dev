//
//  UIImage+.swift
//  MeloMeter
//
//  Created by 양승완 on 4/6/25.
//

import UIKit

extension UIImage {
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
}
