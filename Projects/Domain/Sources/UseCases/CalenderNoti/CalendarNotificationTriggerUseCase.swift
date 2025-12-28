//
//  CalendarNotificationTriggerUseCase.swift
//  MeloMeter
//
//  Created by LTS on 2023/09/05.
//

import Foundation
import RxSwift
import RxRelay

public class CalendarNotificationTriggerUseCase {
    
    // MARK: - Property
    private let userRepository: UserRepositoryP
    private let coupleRepository: CoupleRepositoryP
    private let disposeBag = DisposeBag()
    
    // MARK: Initializers
    public init(userRepository: UserRepositoryP, coupleRepository: CoupleRepositoryP) {
        self.userRepository = userRepository
        self.coupleRepository = coupleRepository
    }
    
    // MARK: - Methods
    // 내생일, 상대방생일, 처음만난날, 기념일 목록가져오기
    public func getCalendarNotificationInfo () {
        //
    }
    
    
    
}
