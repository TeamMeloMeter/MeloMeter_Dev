//
//  ProfileInsertViewModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/03.
//

import UIKit
import RxSwift

// MARK: - LoginViewModel
class ProfileInsertVM {
    
    let profileInsertUseCase: ProfileInsertUseCase
//    let dDayUseCase: DdayUseCase
    let disposeBag = DisposeBag()
    weak var coordinator: PresetCoordinator?
    
    // MARK: - Input
    var userInput = PublishSubject<[String?]>()
    
    // MARK: - Output
    var sendProfileInsertRequest = PublishSubject<Bool>()
    
    // MARK: - Init
    init(coordinator: PresetCoordinator, profileInsertUseCase: ProfileInsertUseCase) {
        self.coordinator = coordinator
        self.profileInsertUseCase = profileInsertUseCase
        
        //nameInput값 변경 감지
        userInput.bind(onNext: { [weak self] info in
            guard let self = self else{ return }
            self.profileInsertUseCase.insertUserInfoService(userInfo: info)
                .subscribe(onSuccess: {
//                    self.dDayUseCase?.createDdayList
                    self.coordinator?.showPermissionVC1()
                }, onFailure: { error in
                    self.sendProfileInsertRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func checkFormat(info: [String?]) -> Single<Bool> {
        return Single<Bool>.create { single in
            guard let birth = info[1] else { single(.success(false)); return Disposables.create()}
            guard let firstDay = info[2] else { single(.success(false)); return Disposables.create()}
            
            if Date.stringToDate(dateString: birth, type: .yearToDayHipen) == nil || Date.stringToDate(dateString: firstDay, type: .yearToDayHipen) == nil {
                single(.success(false))
            } else{
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
}

