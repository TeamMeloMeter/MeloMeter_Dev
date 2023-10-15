//
//  ProfileInsertService.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import UIKit
import RxSwift

class ProfileInsertUseCase {
    
    // MARK: - Property
    private let userRepository: UserRepositoryP
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init(userRepository: UserRepositoryP) {
        self.userRepository = userRepository
    }
    
    func insertUserInfoService(userInfo: [String?]) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            if let name = userInfo[0], let birth = userInfo[1], let firstDay = userInfo[2] {
                guard let  birthD = Date.stringToDate(dateString: birth, type: .yearToDayHipen) else { return Disposables.create() }
                guard let firstDayD = Date.stringToDate(dateString: firstDay, type: .yearToDayHipen) else { return Disposables.create() }
                
                let userModel = UserModel(name: name, birth: birthD)
                let ddayModel = CoupleModel(firstDay: firstDayD, anniversaries: [DdayCellData(dateName: "\(name) 생일", date: birthD, countDdays: "")])
                
                self.userRepository.presetUserInfo(user: userModel, dDay: ddayModel)
                    .subscribe(onSuccess: {
                        single(.success(()))
                    },onFailure: { error in
                        single(.failure(error))
                    }).disposed(by: disposeBag)
                                  
            }
            return Disposables.create()
        }
    }
    
}
