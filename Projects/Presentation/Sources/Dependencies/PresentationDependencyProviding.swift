//
//  PresentationDependencyProviding.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
import Domain

public protocol KakaoShareService {
    func share(inviteCode: String)
}

public protocol PresentationDependencyProviding {
    var firebaseService: FirebaseService { get }
    var sharedDataRepo: SharedDataRepoP { get }
    var pushNotificationService: PushNotificationServiceP { get }
    var kakaoShareService: KakaoShareService { get }

    func makeChatRepository() -> ChatRepositoryP
    func makeUserRepository(chatRepository: ChatRepositoryP) -> UserRepositoryP
    func makeCoupleRepository() -> CoupleRepositoryP
    func makeLogInRepository() -> LogInRepositoryP
    func makeHundredQARepository() -> HundredQARepositoryP
    func makeAlarmRepository() -> AlarmRepositoryP
    func makeSearchRepository() -> SearchRepoP
    func makeCouplePlaceRepository() -> CouplePlaceRepoP
}

public extension PresentationDependencyProviding {
    func makeUserRepository() -> UserRepositoryP {
        return makeUserRepository(chatRepository: makeChatRepository())
    }
}
