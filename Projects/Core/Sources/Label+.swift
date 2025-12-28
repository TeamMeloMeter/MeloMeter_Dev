//
//  Label+.swift
//  MeloMeter
//
//  Created by 양승완 on 2/5/25.
//

import UIKit

public extension UILabel {
    public func highlightText(_ targetText: String, highlightColor: UIColor = .primary1) {
        guard let fullText = self.text, !fullText.isEmpty else { return }
        
        let attributedString = NSMutableAttributedString(string: fullText)
        var searchRange = NSRange(location: 0, length: fullText.utf16.count)

        while let range = (fullText as NSString).range(of: targetText, options: [], range: searchRange).toOptional(),
              range.location != NSNotFound {
            
            attributedString.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: highlightColor,
                .foregroundColor: highlightColor
            ], range: range)
            
            // 다음 검색을 위해 searchRange 업데이트
            searchRange = NSRange(location: range.location + range.length,
                                  length: fullText.utf16.count - (range.location + range.length))
        }
        
        
            attributedString.addAttribute(.font, value: self.font!, range: NSRange(location: 0, length: attributedString.length))
        

        self.attributedText = attributedString
    }
}

// NSRange를 안전하게 변환하는 Extension
extension NSRange {
    func toOptional() -> NSRange? {
        return self.location == NSNotFound ? nil : self
    }
}
