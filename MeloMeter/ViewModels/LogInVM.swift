//
//  PhoneCertifiedViewModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/04.
//

import UIKit
import Firebase
import RxSwift
import RxCocoa

// MARK: - LoginViewModel
class LogInVM {
    
    var userInfoModel = UserInfoModel()
    let logInService = LogInService()
    let disposeBag = DisposeBag()
    private var timerSubscription: Disposable? // 타이머 해제할 Disposable
    weak var coordinator: LogInCoordinator?
    
    // MARK: - Input
    var phoneNumberInput = PublishSubject<String?>()
    var verificationCode = PublishSubject<String?>()
    var startCoupleConnectVC = PublishSubject<Bool>()
    var inviteCodeInput = PublishSubject<String?>()
    
    // MARK: - Output
    var sendNumRequest = PublishSubject<Bool>()
    var logInRequest = PublishSubject<Bool>()
    var myCode = PublishSubject<String>()
    var combineRequest = PublishSubject<Bool>()
    var timerString = PublishSubject<String>()
    var timerDisposed = PublishSubject<Bool>()
    
    // MARK: - Init
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
        
        //전화번호 입력 -> 인증 요청 -> 응답
        phoneNumberInput.subscribe(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInService.sendNumberService(text: text)
                .subscribe(onSuccess: {
                    coordinator.showAuthNumVC()
                }, onFailure: { error in
                    self.sendNumRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        
        //인증번호 입력 -> 로그인 요청 -> 응답
        verificationCode.subscribe(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInService.inputVerificationCodeService(code: text)
                .subscribe(onSuccess: {
                    coordinator.showCoupleComvineVC()
                }, onFailure: { error in
                    self.logInRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        
        //내 커플코드 받아오기
        startCoupleConnectVC.subscribe(onNext: { [weak self] result in
            guard let self = self else{ return }
            self.logInService.getUserLoginInfo()
                .subscribe(onSuccess: { logInModel in
                    let inviteCode = "\(logInModel.inviteCode.prefix(4)) \(logInModel.inviteCode.suffix(4))"
                    self.myCode.onNext(inviteCode)
                }, onFailure: { error in
                    self.myCode.onError(error)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        
        //초대코드 입력 -> 커플연결
        inviteCodeInput.subscribe(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInService.combineCoupleService(text)
                .subscribe(onSuccess: {
                    coordinator.showProfileInsertVC()
                }, onFailure: { error in
                    self.combineRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
    }
    
    func verificationCodeTimer() {
        let countdownDuration = 299
        
        timerSubscription = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(countdownDuration)
            .subscribe(onNext: { secondsElapsed in
                self.timerDisposed.onNext(false)
                let remainingSeconds = countdownDuration - secondsElapsed
                let minutes = remainingSeconds / 60
                let seconds = remainingSeconds % 60
                self.timerString.onNext(String(format: "%02d:%02d", minutes, seconds))
            }, onCompleted: {
                self.timerDisposed.onNext(true)
            })
    }
    
    func inviteCodeTimer() {
        let countdownDuration = 5
        
        timerSubscription = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .take(countdownDuration)
            .subscribe(onNext: { secondsElapsed in
                self.timerDisposed.onNext(false)
                let remainingSeconds = countdownDuration - secondsElapsed
                let hours = remainingSeconds / 3600
                let minutes = (remainingSeconds % 3600) / 60
                let seconds = (remainingSeconds % 3600) % 60
                self.timerString.onNext(String(format: "내 초대코드(%02d:%02d:%02d)", hours, minutes, seconds))
                
            }, onCompleted: {
                self.timerDisposed.onNext(true)
            })
           
    }
    
    func stopTimer() {
        timerSubscription?.dispose()
        timerSubscription = nil
    }

}
