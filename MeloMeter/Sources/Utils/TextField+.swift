//
//  TextField+.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/10.
//

import UIKit

//텍스트 입력 좌측 패딩 13
extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
