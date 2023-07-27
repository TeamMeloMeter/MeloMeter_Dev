//
//  LogInRepository.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import Foundation
import RxSwift

protocol LogInRepositoryP {
    func sendNumber(phoneNumber: String?) -> Single<LogInStatus>
    func inputVerificationCode(verificationCode: String?) -> Single<String>
    func userInFirestore() -> Single<String>
    func getUserLoginInfo() -> Single<LogInModel?>
    func combineCouple(code: String) -> Single<Void>
}
