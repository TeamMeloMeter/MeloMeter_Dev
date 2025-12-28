//
//  File.swift
//  MeloMeter
//
//  Created by 양승완 on 5/23/25.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UITextField {
    public var textOrEmpty: ControlProperty<String> {
        return  self.text.orEmpty
    }
}

public extension ObservableType {
    public func flatMapCompletable(_ selector: @escaping (Element) -> Completable) -> Completable {
        return self
            .flatMap { selector($0).asObservable() }
            .ignoreElements()
            .asCompletable()
    }
}
