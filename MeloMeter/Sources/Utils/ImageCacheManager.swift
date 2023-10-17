//
//  ImageCacheManager.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/14.
//

import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
