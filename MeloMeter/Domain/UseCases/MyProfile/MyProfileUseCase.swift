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
    private let userRepository: UserRepository
    private var disposeBag: DisposeBag
    private let uid: String
    
    required init(userRepository: UserRepository) {
        self.userRepository = userRepository
        self.disposeBag = DisposeBag()
        if let id = UserDefaults.standard.string(forKey: "uid") {
            self.uid = id
        }else {
            self.uid = ""
        }
    }
    
    func getUserInfo() -> Observable<UserModel> {
        return self.userRepository.getUserInfo(self.uid)
            .map{ $0.toModel() }
    }
    
    func getProfileImage(url: String) -> Single<UIImage?> {
        return self.userRepository.downloadImage(url: url)
    }
    
}
