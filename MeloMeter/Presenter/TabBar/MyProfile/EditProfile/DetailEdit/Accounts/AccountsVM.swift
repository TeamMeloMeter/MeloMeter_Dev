//
//  DisconnectVM.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/18.
//

import UIKit
import RxSwift
import RxRelay

enum AccountsButton {
    case disconnect, recovery, withdrawal, cencel
}

class AccountsVM {

    weak var coordinator: MyProfileCoordinator?
    private var accountsUseCase: AccountsUseCase
    var deadlineDate = ""
    var recoveryErrorAlertTapEvent = PublishSubject<Bool>()
    
    struct Input {
        let backBtnTapEvent: Observable<Void>
        let excuteBtnEvent: Observable<AccountsButton>
    }
    
    struct Output {
        var recoveryFailed = PublishSubject<Bool>()
        var withdrawalFailed = PublishSubject<Bool>()
    }
    
    
    init(coordinator: MyProfileCoordinator, accountsUseCase: AccountsUseCase) {
        self.coordinator = coordinator
        self.accountsUseCase = accountsUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.backBtnTapEvent
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
            input.excuteBtnEvent
                .subscribe(onNext: {[weak self] btnType in
                    guard let self = self else{ return }
                    switch btnType {
                    case .disconnect:
                        self.accountsUseCase.excuteDisconnect()
                            .subscribe(onSuccess: { infoDic in
                                guard let disconnectDate = infoDic["disconnecteddate"],
                                      let deadlineDate = infoDic["deadlineDate"],
                                      let userName = infoDic["userName"],
                                      let otherUserName = infoDic["otherUserName"] else {
                                    return
                                }
                                self.coordinator?.showRecoveryVC(date: (disconnectDate, deadlineDate), names: (userName, otherUserName))
                            })
                            .disposed(by: disposeBag)
                        
                    case .recovery:
                        self.accountsUseCase.excuteRecovery(deadline: self.deadlineDate)
                            .subscribe(onSuccess: { success in
                                if success {
                                    self.coordinator?.recoverySuccess()
                                }else {
                                    self.recoveryErrorAlertTapEvent
                                        .subscribe(onNext: { tap in
                                            if tap {
                                                self.accountsUseCase.excuteWithdrawal()
                                                    .subscribe(onSuccess: { result in
                                                        if result {
                                                            self.accountsUseCase.excuteLogout()
                                                                .subscribe(onSuccess: {
                                                                    self.coordinator?.finish()
                                                                })
                                                                .disposed(by: disposeBag)
                                                        }else {
                                                            output.withdrawalFailed.onNext(true)
                                                        }
                                                    })
                                                    .disposed(by: disposeBag)
                                            }
                                        })
                                        .disposed(by: disposeBag)
                                    output.recoveryFailed.onNext(true)
                                }
                            })
                            .disposed(by: disposeBag)
                        
                    case .withdrawal:
                        self.accountsUseCase.excuteChangeAccessLevel()
                            .subscribe(onSuccess: { result in
                                if result {
                                    self.coordinator?.finish()
                                }else {
                                    output.withdrawalFailed.onNext(true)
                                }
                            })
                            .disposed(by: disposeBag)
                    case .cencel:
                        print("취소")
                    }
                    
                })
                .disposed(by: disposeBag)
        
        
        
        return output
    }
    
    
}
