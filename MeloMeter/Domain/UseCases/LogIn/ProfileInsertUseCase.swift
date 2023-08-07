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
    private let profileInsertRepository: ProfileInsertRepository
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init(profileInsertRepository: ProfileInsertRepository) {
        self.profileInsertRepository = profileInsertRepository
    }
    
    func insertUserInfoService(userInfo: [String?]) -> Single<Void> {
        return Single<Void>.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            // 3가지 값이 모두 있을경우
            if let name = userInfo[0], let birth = userInfo[1], let firstDay = userInfo[2] {
                //스트링 -> 데이트
                guard let  birthD = Date.stringToDate(dateString: birth, type: .yearToDayHipen) else { return Disposables.create() }
                guard let firstDayD = Date.stringToDate(dateString: firstDay, type: .yearToDayHipen) else { return Disposables.create() }
                
                //데이터를 담은 모델 객체 생성
                let userModel = UserModel(name: name, birth: birthD)
                let ddayModel = DdayModel(firstDay: firstDayD, anniversaries: [birthD])
                //레파지토리로 넘기기
                profileInsertRepository.insertUserInfo(user: userModel, dDay: ddayModel)
                    .subscribe(onSuccess: {
                        //데이터베이스 입력성공
                        single(.success(()))
                    },onFailure: { error in
                        //데이터베이스 실패
                        single(.failure(error))
                    }).disposed(by: disposeBag)
            }
            return Disposables.create()
        }
    }
}
