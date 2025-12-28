//
//  EditProfileUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import Foundation
import RxSwift
import RxRelay

public class EditProfileUseCase {
    private let userRepository: UserRepositoryP
    private var disposeBag: DisposeBag
    public var userData: PublishRelay<UserModel>
    
    public required init(userRepository: UserRepositoryP) {
        self.userRepository = userRepository
        self.userData = PublishRelay()
        self.disposeBag = DisposeBag()
    }
 
    public func getUserData() {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil))
            .bind(to: self.userData)
            .disposed(by: disposeBag)
    }
    
    public func editInfo(field: EditUserInfo, value: String) -> Single<Void> {
        return self.userRepository.updateUserInfo(value: [field.rawValue: value])
    }
    
    public func getProfileImage(url: String) -> Single<Data?> {
        return self.userRepository.downloadImage(url: url)
    }
    
    public func editProfileImage(data: Data) -> Single<Void> {
        return self.userRepository.updateProfileImage(imageData: data)
    }

}
