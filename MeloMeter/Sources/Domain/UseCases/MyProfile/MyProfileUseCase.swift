//
//  MyProfileUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/04.
//

import UIKit
import RxSwift
import RxRelay

class MyProfileUseCase {
    private let userRepository: UserRepositoryP
    private let coupleRepository: CoupleRepositoryP
    private let hundredQARepository: HundredQARepositoryP
    private var disposeBag: DisposeBag
    private var uid: String = ""
    
    required init(userRepository: UserRepositoryP,
                  coupleRepository: CoupleRepositoryP,
                  hundredQARepository: HundredQARepositoryP)
    {
        self.userRepository = userRepository
        self.coupleRepository = coupleRepository
        self.hundredQARepository = hundredQARepository
        self.disposeBag = DisposeBag()
        if let id = UserDefaults.standard.string(forKey: "uid") {
            self.uid = id
        }
    }
    
    func getUserInfo() -> Observable<UserModel> {
        return self.userRepository.getUserInfo(self.uid)
    }
    
    func getDdayInfo(otherUid: String) -> Single<[String]>{
        self.coupleRepository.getCoupleDocument()
            .flatMap{ coupleData -> Single<[String]> in
                let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
                let sinceDay = Calendar.current.dateComponents([.day], from: coupleData.firstDay, to: currentDate).day ?? 0
                return self.userRepository.getUserInfo(otherUid)
                    .asSingle()
                    .map{ userInfo -> [String] in
                        return [userInfo.name ?? "상대방", String(sinceDay)]
                    }
            }
    }
    
    func getProfileImage(url: String) -> Single<UIImage?> {
        return self.userRepository.downloadImage(url: url)
    }
    
    func getLastHundredQA() -> Single<Int> {
        return Single.create { [weak self] single in
            guard let self = self else{ return Disposables.create() }
            
            self.hundredQARepository.getCoupleID().subscribe(onSuccess: { coupleID in
                self.hundredQARepository.getAnswerList(coupleID: coupleID)
                    .subscribe(onSuccess: { list in
                        let result = list.map{ $0.toModel() }
                        single(.success(result.count-2))
                    },onFailure: { error in
                        single(.failure(error))
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    
    }
    
}
