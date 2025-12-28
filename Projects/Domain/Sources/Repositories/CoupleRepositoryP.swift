//
//  DdayRepositoryP.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/08.
//

import Foundation
import RxSwift

public protocol CoupleRepositoryP {
    var coupleModel: PublishSubject<CoupleModel?> { get }

    func getCoupleID() -> Single<String>
    func getCoupleDocument() -> Single<CoupleModel>
    func setAnniversaries(data: [String]) -> Single<Void>
    func couplesObserver()
    func disconnect() -> Single<Date>
    func recovery(deadlineDate: Date) -> Single<Bool>
    func withdrawalAlarm(otherUid: String) -> Single<Void>
}
