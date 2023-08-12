//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/06.
//

import UIKit
import Firebase
import RxSwift
import RxRelay

enum LogInServiceError: Error {
    case sendNumberFailure
    case logInDenied
}

// MARK: - 로그인 로직
class LogInUseCase {
    
    // MARK: - Property
    private let logInRepository: LogInRepository
    private let disposeBag = DisposeBag()
    private let userRepository: UserRepository
    var isCombined: PublishRelay<Bool>
    
    // MARK: Initializers
    init(logInRepository: LogInRepository, userRepository: UserRepository) {
        self.logInRepository = logInRepository
        self.userRepository = userRepository
        self.isCombined = PublishRelay()
    }
    
    // MARK: - Methods
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
    func inputVerificationCodeService(code: String?) -> Single<String> {
        return Single.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            self.logInRepository.inputVerificationCode(verificationCode: code)
                .subscribe(onSuccess: { inviteCode in
                    let code = "\(inviteCode.prefix(4)) \(inviteCode.suffix(4))"
                    single(.success(code))
                }, onFailure: { error in
                    single(.failure(error))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    // 초대코드 발급 요청
    func inviteCodeRequest() -> Single<LogInModel> {
        return logInRepository.userInFirestore()
            .flatMap({ _ -> Single<LogInModel> in
                return self.logInRepository.getUserLoginInfo()
                    .map{ logInModel -> LogInModel in
                        guard let model = logInModel else{ return LogInModel(uid: "", phoneNumber: "", createdAt: Date(), inviteCode: "")}
                        return model
                    }
            })
         
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
    
    func combineCheckObserver() {
        self.userRepository.userAccessLevelObserver()
        self.userRepository.combineCheck
            .bind(to: self.isCombined)
            .disposed(by: disposeBag)
    }
    
}
