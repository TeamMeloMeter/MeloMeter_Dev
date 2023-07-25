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
    
    let profileInsertService = ProfileInsertService()
    let disposeBag = DisposeBag()
    weak var coordinator: LogInCoordinator?
    
    // MARK: - Input
    var userInput = PublishSubject<[String?]>()
    
    // MARK: - Output
    var sendProfileInsertRequest = PublishSubject<Bool>()
    
    // MARK: - Init
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
        
        //nameInput값 변경 감지
        userInput.bind(onNext: { [weak self] info in
            guard let self = self else{ return }
            self.profileInsertService.insertUserInfoService(userInfo: info)
                .subscribe(onSuccess: {
                    coordinator.showPermissionVC1()
                }, onFailure: { error in
                    self.sendProfileInsertRequest.onNext(false)
                }).disposed(by: disposeBag)
        }).disposed(by: disposeBag)
    }
    
    func checkFormat(info: [String?]) -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            guard let birth = info[1] else { single(.success(false)); return Disposables.create()}
            guard let firstDay = info[2] else { single(.success(false)); return Disposables.create()}
            
            if Date.stringToDate(dateString: birth, type: .yearToDayHipen) == nil || Date.stringToDate(dateString: firstDay, type: .yearToDayHipen) == nil {
                //실패
                //싱글 객채의 success에 true를 담는다!
                single(.success(false))
            } else{
                //성공
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
}

