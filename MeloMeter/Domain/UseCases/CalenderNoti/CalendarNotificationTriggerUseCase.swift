//
//  CalendarNotificationTriggerUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/09/05.
//

import UIKit
import Firebase
import RxSwift
import RxRelay

class CalendarNotificationTriggerUseCase {
    
    // MARK: - Property
    private let userRepository: UserRepository
    private let coupleRepository: CoupleRepository
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    init(userRepository: UserRepository, coupleRepository: CoupleRepository) {
        self.userRepository = userRepository
        self.coupleRepository = coupleRepository
    }
    
    // MARK: - Methods
    // 내생일, 상대방생일, 처음만난날, 기념일 목록가져오기
    func getCalendarNotificationInfo () {
        //
    }
    
    
    
}
