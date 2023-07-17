//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/06.
//

import UIKit
import Firebase
import RxSwift

enum LogInServiceError: Error {
    case sendNumberFailure
    case logInDenied
}

// MARK: - 로그인 로직
class LogInService {
    
    // MARK: - Property
    let logInRepository = LogInRepository()
    //var logInModel = LogInModel()
    let disposeBag = DisposeBag()
    
    var sendCheck = PublishSubject<Void>() //전화번호 전송 성공여부
    var codeResultCheck = PublishSubject<Void>() //인증번호 인증 성공여부
    var getMyCodeCheck = PublishSubject<String>() //내 커플코드 수신여부
    var combineCoupleCheck = PublishSubject<Void>() //커플 연결 여부
    
    
    // MARK: - Service Logic
    
    //전화번호 전송->인증번호 요청 서비스
    func sendNumberService(text: String?) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.logInRepository.sendNumber(phoneNumber: text)
                .subscribe(onSuccess: { result in
                    switch result {
                    case .requestCompleted:
                        single(.success(()))
                    default:
                        single(.failure(LogInServiceError.sendNumberFailure))
                    }
                }, onFailure: { error in
                    single(.failure(error))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
        
    }
    
    //로그인 요청 서비스
    func inputVerificationCodeService(code: String?) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.logInRepository.inputVerificationCode(verificationCode: code)
                .subscribe(onSuccess: { result in
                    if result == .authenticated {
                        single(.success(()))
                    }else {
                        single(.failure(LogInServiceError.logInDenied))
                    }
                }, onFailure: { error in
                    single(.failure(error))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    
    //내 정보 요청 서비스
    func getUserLoginInfo() -> Single<LogInModel> {
        return logInRepository.getUserLoginInfo()
            .map{ logInModel -> LogInModel in
                guard let model = logInModel else{ return LogInModel(uid: "", phoneNumber: "", createdAt: Date(), inviteCode: "")}
                return model
            }
    }

    //커플 연결 서비스
    func combineCoupleService(_ coupleCode: String?) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self, let code = coupleCode else{ return Disposables.create() }
            self.logInRepository.combineCouple(code: code)
                .subscribe(onSuccess: {
                    single(.success(()))
                }, onFailure: { error in
                    single(.failure(error))
                }).disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    
}
