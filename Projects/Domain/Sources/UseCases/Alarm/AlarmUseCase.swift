//
//  AlarmUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import UIKit
import RxSwift
import RxRelay

public class AlarmUseCase {
    
    // MARK: - Property
    private let alarmRepository: AlarmRepositoryP
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    public init(alarmRepository: AlarmRepositoryP)
    {
        self.alarmRepository = alarmRepository
    }
    
    //   MARK: - Methods
    public func getAlarmService() -> Observable<[AlarmModel]>{
        return self.alarmRepository.getAlarm()
            .map { alarmDTOList in
                return alarmDTOList.map { $0.toModel() }
            }
    }
  
}
