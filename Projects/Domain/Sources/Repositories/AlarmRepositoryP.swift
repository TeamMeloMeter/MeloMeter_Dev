//
//  AlarmRepositoryP.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation
import RxSwift

public protocol AlarmRepositoryP {
    func getAlarm() -> Observable<[AlarmDTO]>
    func convertToAlarmDTOArray(from dictionaries: [[String: Any]]) -> [AlarmDTO]
}
