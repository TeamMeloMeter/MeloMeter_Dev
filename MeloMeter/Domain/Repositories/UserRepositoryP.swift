//
//  UserRepositoryP.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/05.
//

import Foundation
import RxSwift

protocol UserRepositoryP {
    func getUserInfo(_ uid: String) -> Observable<UserDTO>
    func updateUserInfo(value: [String: String]) -> Single<Void>
    func updateProfileImage(image: UIImage) -> Single<Void>
    func downloadImage(url: String) -> Single<UIImage?>
    func userAccessLevelObserver()
}
