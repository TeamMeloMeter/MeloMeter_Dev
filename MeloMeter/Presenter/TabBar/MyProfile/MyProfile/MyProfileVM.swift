//
//  MyProfileVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MyProfileVM {

    weak var coordinator: MyProfileCoordinator?
    private var myProfileUseCase: MyProfileUseCase
    private var alarmUseCase: AlarmUseCase

    struct Input {
        let viewWillApearEvent: Observable<Void>
        let editProfileBtnTapEvent: Observable<Void>
        let alarmViewTapEvent: Observable<Void>
        let dDayViewTapEvent: Observable<Void>
        let hundredQAViewTapEvent: Observable<Void>
        let noticeViewTapEvent: Observable<Void>
        let qnAViewTapEvent: Observable<Void>
    }
    
    struct Output {
        var profileImage = PublishRelay<UIImage?>()
        var userName = PublishRelay<String>()
        var coupleUserName = PublishRelay<String>()
        var userPhoneNumber = PublishRelay<String>()
        var stateMessage = PublishRelay<String?>()
        var sinceFirstDay = PublishRelay<String>()
        var lastHundredQA = PublishRelay<String>()
        var alarmTitle = PublishRelay<String>()
        var alarmSubtitle = PublishRelay<String>()
        var alarmImage = PublishRelay<String>()
    }
    
    
    init(coordinator: MyProfileCoordinator, myProfileUseCase: MyProfileUseCase, alarmUseCase: AlarmUseCase) {
        self.coordinator = coordinator
        self.myProfileUseCase = myProfileUseCase
        self.alarmUseCase = alarmUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.viewWillApearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else{ return }
                self.myProfileUseCase.getUserInfo()
                    .subscribe(onNext: { user in
                        self.myProfileUseCase.getProfileImage(url: user.profileImage ?? "")
                            .subscribe(onSuccess: { image in
                                output.profileImage.accept(image)
                            })
                            .disposed(by: disposeBag)
                        guard let name = user.name, let phoneNumber = user.phoneNumber, let otherUid = user.otherUid else{ return }
                        self.myProfileUseCase.getDdayInfo(otherUid: otherUid)
                            .subscribe(onSuccess: { dDayInfo in
                                output.coupleUserName.accept("\(name) & \(dDayInfo[0])")
                                output.sinceFirstDay.accept("\(dDayInfo[1])일째 함께하는 중")
                            })
                            .disposed(by: disposeBag)
                        output.userName.accept(name)
                        var number = phoneNumber.map{ String($0) }
                        number.insert(" 0", at: 3)
                        number.insert("-", at: 6)
                        number.insert("-", at: 11)
                        self.myProfileUseCase.getLastHundredQA()
                            .subscribe(onSuccess: { number in
                                output.lastHundredQA.accept("\(number)번째 백문백답 완료!")
                            })
                            .disposed(by: disposeBag)
                        output.userPhoneNumber.accept(number.joined())
                        output.stateMessage.accept(user.stateMessage)
                        
                    })
                    .disposed(by: disposeBag)
                
                self.alarmUseCase.getAlarmService()
                    .subscribe(onNext: { alarmList in
            
                        output.alarmSubtitle.accept(alarmList.last?.text ?? "아직 추가된 알림이 없어요!")
                        
                        output.alarmTitle.accept(self.daysPassedSinceDate(alarmList.last?.date ?? Date()))
                        
                        // 아이콘은 type을 기준으로 (생일) / (주년/100일단위/기념일) / 프로필
                        let icon: String
                        switch alarmList.last?.type {
                        case .birthDay:
                            icon = "birthDayIcon"
                        case .hundredAnni,.yearAnni,.customAnni:
                            icon = "heartIcon"
                        case .profile,.hundredQA:
                            icon = "alarmIcon"
                        default:
                            icon = "alarmIcon"
                        }
                        output.alarmImage.accept(icon)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.alarmViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showAlarmFlow()
            })
            .disposed(by: disposeBag)
        
        input.dDayViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showDdayFlow()
            })
            .disposed(by: disposeBag)
        
        input.hundredQAViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showHundredQAFlow()
            })
            .disposed(by: disposeBag)
        
        input.editProfileBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showEditProfileVC()
            })
            .disposed(by: disposeBag)
        
        input.noticeViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showNoticeVC()
            })
            .disposed(by: disposeBag)
        
        input.qnAViewTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.showQnAVC()
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func daysPassedSinceDate(_ inputDate: Date) -> String {
        let calendar = Calendar.current
        let currentDate = Date()
        var oldDay = 0
        var day = ""
        // 입력받은 날짜와 현재 날짜 사이의 날짜 차이 계산
        let components = calendar.dateComponents([.day], from: inputDate, to: currentDate)
        
        // 날짜 차이를 Int로 반환
        if let days = components.day {
            oldDay = days
        } else {
            oldDay = 0
        }
        
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
        
        return day
    }
    
}
