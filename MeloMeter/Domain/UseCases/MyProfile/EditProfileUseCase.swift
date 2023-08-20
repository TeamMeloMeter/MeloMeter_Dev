//
//  EditProfileUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import UIKit
import RxSwift
import RxRelay

class EditProfileUseCase {
    private let userRepository: UserRepository
    private var disposeBag: DisposeBag
    var userData: PublishSubject<UserModel>
    
    required init(userRepository: UserRepository) {
        self.userRepository = userRepository
        self.userData = PublishSubject()
        self.disposeBag = DisposeBag()
    }
 
    func getUserData() {
        guard let uid = UserDefaults.standard.string(forKey: "uid") else{ return }
        self.userRepository.getUserInfo(uid)
            .catchAndReturn(UserModel(name: nil, birth: nil))
            .bind(to: self.userData)
            .disposed(by: disposeBag)
    }
    
    func editInfo(field: EditUserInfo, value: String) -> Single<Void> {
        return self.userRepository.updateUserInfo(value: [field.rawValue: value])
    }
    
    func getProfileImage(url: String) -> Single<UIImage?> {
        return self.userRepository.downloadImage(url: url)
    }
    
    func editProfileImage(image: UIImage) -> Single<Void> {
        return self.userRepository.updateProfileImage(image: image)
    }

}
