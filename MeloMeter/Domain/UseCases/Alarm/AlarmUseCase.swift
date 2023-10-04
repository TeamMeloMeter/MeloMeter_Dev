//
//  AlarmUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import UIKit
import Firebase
import RxSwift
import RxRelay

class AlarmUseCase {
    
    // MARK: - Property
    private let alarmRepository: AlarmRepository
    private let disposeBag = DisposeBag()

    var recieveAlarmService = PublishRelay<[AlarmModel]?>()
    
    // MARK: Initializers
    init(alarmRepository: AlarmRepository)
    {
        self.alarmRepository = alarmRepository
    }
    
//     MARK: - Methods
    func getAlarmService() -> Observable<[AlarmModel]>{
        return self.alarmRepository.getAlarm()
            .map { alarmDTOList in
                
                return alarmDTOList.map { $0.toModel() }
            }
    }
  
}
