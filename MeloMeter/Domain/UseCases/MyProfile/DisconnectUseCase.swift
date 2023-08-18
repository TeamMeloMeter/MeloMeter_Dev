//
//  DisconnectUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/18.
//

import UIKit
import RxSwift

class DisconnectUseCase {
    private let userRepository: UserRepository
    private var disposeBag: DisposeBag
    
    required init(userRepository: UserRepository) {
        self.userRepository = userRepository
        self.disposeBag = DisposeBag()
    }
 
}
