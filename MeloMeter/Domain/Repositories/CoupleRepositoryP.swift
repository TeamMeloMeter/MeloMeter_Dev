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
    func setAnniversaries(data: [String]) -> Single<Void>
    func disconnect() -> Single<Date>
    func recovery(deadlineDate: Date) -> Single<Bool>
    func withdrawalAlarm(otherUid: String) -> Single<Void>
}
