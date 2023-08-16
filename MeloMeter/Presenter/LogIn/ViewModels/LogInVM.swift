//
//  PhoneCertifiedViewModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/04.
//

import UIKit
import RxSwift
import RxRelay
// MARK: - LoginViewModel
class LogInVM {
    
    private let logInUseCase: LogInUseCase
    let disposeBag = DisposeBag()
    private var timerSubscription: Disposable?
    weak var coordinator: LogInCoordinator?
    var phoneNumber: String?
    
    // MARK: - Input
    var phoneNumberInput = PublishSubject<String?>()
    var verificationCode = PublishSubject<String?>()
    var inviteCodeInput = PublishSubject<String?>()
    var alertBtnTapped = PublishSubject<Void>()
    var resendBtnTapped = PublishSubject<Void>()
    var coupleCombineViewDidLoadEvent = PublishSubject<Void>()
    
    // MARK: - Output
    var sendNumRequest = PublishSubject<Bool>()
    var logInRequest = PublishSubject<Bool>()
    var myCode = PublishSubject<String>()
    var combineRequest = PublishSubject<Bool>()
    var timerString = PublishSubject<String>()
    var timerDisposed = PublishSubject<Bool>()
    
    // MARK: - Init
    init(coordinator: LogInCoordinator, logInUseCase: LogInUseCase) {
        self.coordinator = coordinator
        self.logInUseCase = logInUseCase
        
        //전화번호 입력 -> 인증 요청 -> 응답
        phoneNumberInput.bind(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.phoneNumber = text
            self.logInUseCase.sendNumberService(text: text)
                .subscribe(onSuccess: {
                    self.coordinator?.showAuthNumVC(phoneNumber: text)
                }, onFailure: { error in
                    self.sendNumRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        //인증번호 입력 -> 로그인 요청 -> 응답
        verificationCode.bind(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInUseCase.inputVerificationCodeService(code: text)
                .subscribe(onSuccess: { inviteCode in
                    if let code = inviteCode {
                        if let otherInviteCode = UserDefaults.standard.string(forKey: "otherInviteCode") {
                            self.coordinator?.showCoupleComvineVC(inviteCode: code, otherInviteCode: otherInviteCode)
                        }else {
                            self.coordinator?.showCoupleComvineVC(inviteCode: code)
                        }
                    }else {
                        print("인증번호 입력-> 로그인플로우 finish()")
                        self.coordinator?.finish()
                    }
                    
                }, onFailure: { error in
                    self.logInRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        //인증번호 재발급
        resendBtnTapped.subscribe(onNext: {
            self.logInUseCase.sendNumberService(text: self.phoneNumber)
                .subscribe(onSuccess: {[weak self] _ in
                    self?.stopTimer()
                    self?.verificationCodeTimer()
                }, onFailure: {[weak self] error in
                    self?.sendNumRequest.onNext(false)
                }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
        
        coupleCombineViewDidLoadEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.logInUseCase.combineCheckObserver()
                self.logInUseCase.isCombined
                    .subscribe(onNext: {[weak self] isCombined in
                        guard let self = self else{ return }
                        if isCombined {
                            self.logInUseCase.uploadDefaultProfileImage()
                                .subscribe(onSuccess: {
                                    self.coordinator?.finish()
                                })
                                .disposed(by: self.disposeBag)
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        //초대코드 입력 -> 커플연결
        inviteCodeInput.bind(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInUseCase.combineCoupleService(text)
                .subscribe(onSuccess: {
                    self.coordinator?.finish()
                }, onFailure: { error in
                    self.combineRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        //인증번호 시간초과 alert 버튼 이벤트
        alertBtnTapped.subscribe(onNext: {[weak self] _ in
            self?.coordinator?.popViewController()
        }).disposed(by: disposeBag)
    }
    
    //초대코드 재발급 후 가져오기
    func inviteCodeRequest() {
        self.logInUseCase.inviteCodeRequest()
            .subscribe(onSuccess: { logInModel in
                let inviteCode = "\(logInModel.inviteCode.prefix(4)) \(logInModel.inviteCode.suffix(4))"
                self.myCode.onNext(inviteCode)
            }, onFailure: { error in
                self.myCode.onError(error)
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
        let countdownDuration = 86399
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
                self.inviteCodeRequest()
                self.timerDisposed.onNext(true)
            })
    }
    
    func stopTimer() {
        timerSubscription?.dispose()
        timerSubscription = nil
    }
    
    func shareKakao(inviteCode: String) {
        KakaoService.shared.shareWithKakaoTalk(inviteCode: inviteCode)
    }

}
