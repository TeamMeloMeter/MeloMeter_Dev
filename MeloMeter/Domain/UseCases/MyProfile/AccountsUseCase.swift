//
//  DisconnectUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/18.
//

import UIKit
import RxSwift

class AccountsUseCase {
    private let userRepository: UserRepositoryP
    private let coupleRepository: CoupleRepositoryP
    
    private var disposeBag: DisposeBag
    
    required init(userRepository: UserRepositoryP, coupleRepository: CoupleRepositoryP) {
        self.userRepository = userRepository
        self.coupleRepository = coupleRepository
        self.disposeBag = DisposeBag()
    }
    
    func excuteDisconnect() -> Single<[String: String]> {
        return self.coupleRepository.disconnect()
            .flatMap{ disconnecteddate -> Single<[String: String]> in
                guard let deadlineDate = Calendar.current.date(byAdding: .day, value: 30, to: disconnecteddate),
                      let uid = UserDefaults.standard.string(forKey: "uid"),
                      let otherUid = UserDefaults.standard.string(forKey: "otherUid")
                else {
                    return Single.just([:])
                }
                
                return self.userRepository.getUserInfo(uid)
                    .flatMap{ userInfo -> Single<[String: String]> in
                        return self.userRepository.getUserInfo(otherUid)
                            .map{ otherUserInfo in
                                return ["disconnecteddate": disconnecteddate.toString(type: .yearToDay),
                                        "deadlineDate": deadlineDate.toString(type: .yearToDay),
                                        "userName": userInfo.name ?? "",
                                        "otherUserName": otherUserInfo.name ?? ""]
                            }
                            .asSingle()
                    }
                    .asSingle()
                
            }
    }
    
    func excuteRecovery(deadline: String) -> Single<Bool> {
        let deadlineDate = Date.fromStringOrNow(deadline, .yearToDay)
        return self.coupleRepository.recovery(deadlineDate: deadlineDate)
    }
    
    func excuteLogout() -> Single<Void> {
        self.userRepository.signOut()
    }
    
    func disconnectionNoti() -> Single<Void> {
        if let uid = UserDefaults.standard.string(forKey: "uid") {
            return self.userRepository.getUserInfo(uid)
                .asSingle()
                .flatMap{ userInfo in
                    return self.coupleRepository.withdrawalAlarm(otherUid: userInfo.otherUid ?? "")
                }
        }
        return Single.just(())
    }
    
    func excuteWithdrawal() -> Single<Bool> {
        guard let uid = UserDefaults.standard.string(forKey: "uid")
        else{ return Single.just(false) }
        
        return self.userRepository.getUserInfo(uid)
            .asSingle()
            .flatMap{[weak self] userInfo in
                guard let self = self else{ return Single.just(false)}
                return self.coupleRepository.withdrawalAlarm(otherUid: userInfo.otherUid ?? "")
                    .flatMap{ _ in
                        return self.userRepository.withdrawal(uid: userInfo.uid ?? "")
                            .flatMap{
                                return self.userRepository.dropOut()
                                    .map{ true }
                                    .catchAndReturn(false)
                            }
                            .catchAndReturn(false)
                    }
                    .catchAndReturn(false)
            }
            .catchAndReturn(false)
    }
    
    func excuteChangeAccessLevel() -> Single<Bool> {
        guard let otherUid = UserDefaults.standard.string(forKey: "otherUid")
        else{ return Single.just(false) }
        let changedMine = self.userRepository.changeAccessLevel(otherUid: otherUid)
            .map({ _ in
                return true
            })
            .catchAndReturn(false)
        let changedOther = self.userRepository.changeAccessLevel(otherUid: otherUid)
            .map({ _ in
                return true
            })
            .catchAndReturn(false)
        return Single.zip(changedMine, changedOther)
            .map{ mine, other in
                if mine && other { return true }
                else{ return false }
            }
            .catchAndReturn(false)
    }
    
}
