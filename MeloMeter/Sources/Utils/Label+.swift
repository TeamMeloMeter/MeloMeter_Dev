//
//  Label+.swift
//  MeloMeter
//
//  Created by 양승완 on 2/5/25.
//

import UIKit

extension UILabel {
    func highlightText(_ targetText: String, highlightColor: UIColor = .primary1) {
            guard let fullText = self.text else { return }
            
            let attributedString = NSMutableAttributedString(string: fullText)
            
        
            if let range = fullText.range(of: targetText) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttributes([
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: highlightColor,
                    .foregroundColor: highlightColor
                ], range: nsRange)
                
            }
        
        attributedString.addAttribute(.font, value: self.font!, range: NSRange(location: 0, length: fullText.count))
        
        
        
            self.attributedText = attributedString
        }
}
