//
//  ColorAssets.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/24.
//

import UIKit

// MARK: Color Assets
extension UIColor {
    static let gray1 = UIColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    static let gray2 = UIColor(#colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1))
    static let gray3 = UIColor(#colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1))
    static let gray4 = UIColor(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1))
    static let gray45 = UIColor(#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1))
    static let gray5 = UIColor(#colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1))
    static let primary1 = UIColor(#colorLiteral(red: 0.9843137255, green: 0.3607843137, blue: 0.9960784314, alpha: 1))
    static let primary2 = UIColor(#colorLiteral(red: 0.9803921569, green: 0.1137254902, blue: 1, alpha: 1))
    static let point1 = UIColor(#colorLiteral(red: 1, green: 0.8549019608, blue: 0.3490196078, alpha: 1))

}

// MARK: 그라데이션 배경 View
extension UIView {
    func setGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
extension CALayer {
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.1,
        x: CGFloat = 2,
        y: CGFloat = 2,
        blur: CGFloat = 20
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
}

extension UITabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용가능
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
}
