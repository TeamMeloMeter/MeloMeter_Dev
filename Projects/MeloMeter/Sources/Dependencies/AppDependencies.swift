//
//  AppDependencies.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
#if canImport(Data)
import Data
#endif
#if canImport(Domain)
import Domain
#endif
#if canImport(Presentation)
import Presentation
#endif

final class AppDependencies: PresentationDependencyProviding {
    let firebaseService: FirebaseService
    let sharedDataRepo: SharedDataRepoP
    let pushNotificationService: PushNotificationServiceP
    let kakaoShareService: KakaoShareService

    init() {
        let firebaseService = DefaultFirebaseService()
        self.firebaseService = firebaseService
        self.sharedDataRepo = SharedDataRepo()
        self.pushNotificationService = PushNotificationService.shared
        self.kakaoShareService = KakaoService.shared
    }

    func makeChatRepository() -> ChatRepositoryP {
        return ChatRepository(firebaseService: firebaseService)
    }

    func makeUserRepository(chatRepository: ChatRepositoryP) -> UserRepositoryP {
        return UserRepository(firebaseService: firebaseService, chatRepository: chatRepository)
    }

    func makeCoupleRepository() -> CoupleRepositoryP {
        return CoupleRepository(firebaseService: firebaseService)
    }

    func makeLogInRepository() -> LogInRepositoryP {
        return LogInRepository(firebaseService: firebaseService)
    }

    func makeHundredQARepository() -> HundredQARepositoryP {
        return HundredQARepository(firebaseService: firebaseService)
    }

    func makeAlarmRepository() -> AlarmRepositoryP {
        return AlarmRepository(firebaseService: firebaseService)
    }

    func makeSearchRepository() -> SearchRepoP {
        return SearchRepo()
    }

    func makeCouplePlaceRepository() -> CouplePlaceRepoP {
        return CouplePlaceRepo(firebaseService: firebaseService)
    }

    func makeDatePlanRepository() -> DatePlanRepoP {
        return DatePlanRepo(firebaseService: firebaseService)
    }
}
