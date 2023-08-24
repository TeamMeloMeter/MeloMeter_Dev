//
//  PermissionVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/26.
//

import UIKit
import RxSwift

class PermissionVM {

    weak var coordinator: PresetCoordinator?
    private let disposeBag = DisposeBag()
    private var mainUseCase: MainUseCase
    
    struct Input1 {
        let startBtnTapped1: Observable<Void>
    }
    
    struct Input2 {
        let viewDidApearEvent: Observable<Void>
        let startBtnTapped2: Observable<Void>
    }

    init(coordinator: PresetCoordinator, mainUseCase: MainUseCase) {
        
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        
    }
    
    func transform1(input: Input1, disposeBag: DisposeBag) {
        input.startBtnTapped1
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showPermissionVC2()
            })
            .disposed(by: disposeBag)
    }
    
    func transform2(input: Input2, disposeBag: DisposeBag) {
        
        input.viewDidApearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.mainUseCase.requestAuthorization()
                self?.registerForPushNotifications()
            })
            .disposed(by: disposeBag)
        
        input.startBtnTapped2
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.finish()
            })
            .disposed(by: disposeBag)
    
    }
    
    func registerForPushNotifications() {
        // 1 - UNUserNotificationCenter는 푸시 알림을 포함하여 앱의 모든 알림 관련 활동을 처리합니다.
        UNUserNotificationCenter.current()
        // 2 -알림을 표시하기 위한 승인을 요청합니다. 전달된 옵션은 앱에서 사용하려는 알림 유형을 나타냅니다. 여기에서 알림(alert), 소리(sound) 및 배지(badge)를 요청합니다.
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                // 3 - 완료 핸들러는 인증이 성공했는지 여부를 나타내는 Bool을 수신합니다. 인증 결과를 표시합니다.
                print("Permission granted: \(granted)")
            }
    }
}
