//
//  File.swift
//  MeloMeter
//
//  Created by 양승완 on 5/23/25.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    var textOrEmpty: ControlProperty<String> {
        return  self.text.orEmpty
    }
}
