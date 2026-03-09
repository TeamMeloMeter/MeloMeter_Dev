//
//  PermissionVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/26.
//

import UIKit
import RxSwift
import AVFoundation
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public class PermissionVM {

    weak var coordinator: PresetCoordinator?
    private let disposeBag = DisposeBag()
    private var mainUseCase: MainUseCase
    private let pushNotificationService: PushNotificationServiceP
    
    public struct Input1 {
        let startBtnTapped1: Observable<Void>
    }
    
    public struct Input2 {
        let viewDidApearEvent: Observable<Void>
        let startBtnTapped2: Observable<Void>
    }

    public init(coordinator: PresetCoordinator, mainUseCase: MainUseCase, pushNotificationService: PushNotificationServiceP) {
        
        self.coordinator = coordinator
        self.mainUseCase = mainUseCase
        self.pushNotificationService = pushNotificationService
        
    }
    
    public func transform1(input: Input1, disposeBag: DisposeBag) {
        input.startBtnTapped1
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.showPermissionVC2()
            })
            .disposed(by: disposeBag)
    }
    
    public func transform2(input: Input2, disposeBag: DisposeBag) {
        
        input.viewDidApearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.mainUseCase.requestAuthorization()
                self?.pushNotificationService.registerForPushNotifications()
                self?.requestCameraPermission()
            })
            .disposed(by: disposeBag)
        
        input.startBtnTapped2
            .subscribe(onNext: {[weak self] _ in
                self?.coordinator?.finish()
            })
            .disposed(by: disposeBag)
    
    }
    
  
    
    public func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                print("카메라 권한이 허용되었습니다.")
            } else {
                print("카메라 권한이 거부되었습니다.")
            }
        }
    }

}
