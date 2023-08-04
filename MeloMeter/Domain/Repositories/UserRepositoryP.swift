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
}
