//
//  File.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import Foundation
import RxSwift

protocol ProfileInsertRepositoryP {
    func insertUserInfo(user: UserModel) -> Single<Void>
}
