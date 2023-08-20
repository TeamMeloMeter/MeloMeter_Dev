//
//  UserRepositoryP.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/05.
//

import Foundation
import RxSwift

protocol UserRepositoryP {
    func presetUserInfo(user: UserModel, dDay: CoupleModel) -> Single<Void>
    func getUserInfo(_ uid: String) -> Observable<UserModel>
    func updateUserInfo(value: [String: String]) -> Single<Void>
    func updateProfileImage(image: UIImage) -> Single<Void>
    func downloadImage(url: String) -> Single<UIImage?>
    func userAccessLevelObserver()
    func signOut() -> Single<Void>
    func dropOut() -> Single<Void>
    func withdrawal(uid: String, coupleID: String) -> Single<Void>
}
