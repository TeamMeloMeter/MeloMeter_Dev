//
//  AlarmVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/21.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

struct AlarmData {
    let icon: String
    let day: String
    let text: String
}

class AlarmVM {

    weak var coordinator: AlarmCoordinator?
    private var alarmUseCase: AlarmUseCase
    
    struct Input {
        let viewWillApearEvent: Observable<Void>
        let backBtnTapEvent: Observable<Void>
    }
    
    struct Output {
        var alarmList = PublishRelay<[AlarmData]>()
    }
    
    init(coordinator: AlarmCoordinator, alarmUseCase: AlarmUseCase) {
        self.alarmUseCase = alarmUseCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.finish()
            })
            .disposed(by: disposeBag)
        
        input.viewWillApearEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.alarmUseCase.getAlarmService()
                    .subscribe( onNext: { alarmModelList in
                        output.alarmList.accept(self.convertAlarmData(alarmModelList: alarmModelList))
                })
                .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func convertAlarmData(alarmModelList: [AlarmModel]) -> [AlarmData] {
            alarmModelList.map({ alarmModel in
            // 텍스트는 body바로 삽입
                let text: String = alarmModel.text
            
            // 아이콘은 type을 기준으로 (생일) / (주년/100일단위/기념일) / 프로필
                let icon: String
                
                switch alarmModel.type {
                case .birthDay:
                    icon = "cakeIcon"
                case .hundredAnni,.yearAnni,.customAnni:
                    icon = "heartIcon"
                case .profile,.hundredQA:
                    icon = "alarmIcon"
                default:
                    icon = ""
                }
                
            // date기준으로, 몇일남았는지 ( 하루전, 7일까지는 일단위, 7일 이후부터 30일 사이까지는 주단위, 이후 달단위.)
                var day: String = ""
                let oldDay: Int = daysPassedSinceDate(alarmModel.date)
                
                if oldDay == 0 {
                    day = "오늘"
                }else if oldDay == 1 {
                    day = "하루전"
                }else if 1 < oldDay && oldDay < 7 {
                    day = "\(oldDay)일전"
                }else if 7 <= oldDay && oldDay < 30 {
                    day = "\(oldDay / 7)주전"
                }else if 30 <= oldDay{
                    day = "\(oldDay / 30)달전"
                }
                
                return AlarmData(icon: icon, day: day, text: text)
        })
    }
    
    func daysPassedSinceDate(_ inputDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 입력받은 날짜와 현재 날짜 사이의 날짜 차이 계산
        let components = calendar.dateComponents([.day], from: inputDate, to: currentDate)
        
        // 날짜 차이를 Int로 반환
        if let days = components.day {
            return days
        } else {
            return 0
        }
    }
    
}
