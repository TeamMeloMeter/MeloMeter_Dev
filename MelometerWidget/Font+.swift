//
//  Font+.swift
//  MeloMeter
//
//  Created by 양승완 on 4/26/25.
//

import SwiftUI

final class FontManager {
    
    static let shared = FontManager()
    
    func medium(ofSize size: CGFloat) -> Font {
        return Font(UIFont(name: "Pretendard-Medium", size: size)!)
    }

}

