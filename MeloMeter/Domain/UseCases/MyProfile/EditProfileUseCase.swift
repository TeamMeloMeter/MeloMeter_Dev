//
//  EditProfileUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/11.
//

import UIKit
import RxSwift

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
            .map{ $0.toModel() }
            .asDriver(onErrorJustReturn: UserModel(name: "", birth: Date()))
            .drive(self.userData)
            .disposed(by: disposeBag)
    }
}
