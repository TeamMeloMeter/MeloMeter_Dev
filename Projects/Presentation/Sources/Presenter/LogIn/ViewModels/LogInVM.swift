//
//  PhoneCertifiedViewModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/04.
//

import UIKit
import RxSwift
import RxRelay
import Domain
import Core
// MARK: - LoginViewModel
public class LogInVM {
    
    private let logInUseCase: LogInUseCase
    private let kakaoShareService: KakaoShareService
    public let disposeBag = DisposeBag()
    private var timerSubscription: Disposable?
    weak var coordinator: LogInCoordinator?
    public var phoneNumber: String?
    
    // MARK: - Input
    public var phoneNumberInput = PublishSubject<String?>()
    public var verificationCode = PublishSubject<String?>()
    public var inviteCodeInput = PublishSubject<String?>()
    public var alertBtnTapped = PublishSubject<Void>()
    public var resendBtnTapped = PublishSubject<Void>()
    public var coupleCombineViewDidLoadEvent = PublishSubject<Void>()
    
    // MARK: - Output
    public var sendNumRequest = PublishSubject<Bool>()
    public var logInRequest = PublishSubject<Bool>()
    public var myCode = PublishSubject<String>()
    public var combineRequest = PublishSubject<Bool>()
    public var timerString = PublishSubject<String>()
    public var timerDisposed = PublishSubject<Bool>()
    
    // MARK: - Init
    public init(coordinator: LogInCoordinator, logInUseCase: LogInUseCase, kakaoShareService: KakaoShareService) {
        self.coordinator = coordinator
        self.logInUseCase = logInUseCase
        self.kakaoShareService = kakaoShareService
        
        //전화번호 입력 -> 인증 요청 -> 응답
        phoneNumberInput.subscribe(onNext: { [weak self] text in
            guard let self else{ return }
            self.phoneNumber = text
            self.logInUseCase.sendNumberService(text: text)
                .subscribe(onSuccess: {
                    self.coordinator?.showAuthNumVC(phoneNumber: text)
                }, onFailure: { error in
                  print("::: sendNumberService \(error)")
                    self.sendNumRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
        
        //MARK: 인증번호 입력 -> 로그인 요청 -> 응답
        verificationCode.bind(onNext: { [weak self] text in
            guard let self = self else{ return }
            self.logInUseCase.inputVerificationCodeService(code: text)
                .subscribe(onSuccess: { [weak self] inviteCode in
                    guard let self else {return}
                    if let code = inviteCode {
                        if let otherInviteCode = UserDefaults.standard.string(forKey: "otherInviteCode") {
                            self.coordinator?.showCoupleCombineVC(inviteCode: code, otherInviteCode: otherInviteCode)
                        } else {
                            self.coordinator?.showCoupleCombineVC(inviteCode: code)
                        }
                    } else {
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
                    guard let self else {return}
                    self.stopTimer()
                    self.verificationCodeTimer()
                }, onFailure: {[weak self] error in
                    self?.sendNumRequest.onNext(false)
                }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
        
        coupleCombineViewDidLoadEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.logInUseCase.combineCheckObserver()
                self.logInUseCase.accessLevel
                    .subscribe(onNext: {[weak self] accessLevel in
                        guard let self = self else{ return }
                        if accessLevel == .coupleCombined {
                            self.coordinator?.finish()
                            return
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
    public func inviteCodeRequest() {
        self.logInUseCase.inviteCodeRequest()
            .subscribe(onSuccess: { logInModel in
                let inviteCode = "\(logInModel.inviteCode.prefix(4)) \(logInModel.inviteCode.suffix(4))"
                self.myCode.onNext(inviteCode)
            }, onFailure: { error in
                self.myCode.onError(error)
            }).disposed(by: disposeBag)
    }

    public func verificationCodeTimer() {
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
    
    public func inviteCodeTimer() {
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
    
    public func stopTimer() {
        timerSubscription?.dispose()
        timerSubscription = nil
    }
    
    public func shareKakao(inviteCode: String) {
        kakaoShareService.share(inviteCode: inviteCode)
    }

}
