//
//  DdayRepositoryP.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import Foundation
import RxSwift

protocol CoupleRepositoryP {
    func getCoupleID() -> Single<String>
    func couplesObserver()
    func setAnniversaries(data: [String]) -> Single<Void>
}
