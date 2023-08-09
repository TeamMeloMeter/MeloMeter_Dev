//
//  ChatVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//

import UIKit
import RxSwift

// MARK: - LoginViewModel
class ChatVM {
    weak var coordinator: ChatCoordinator?
    private let disposeBag = DisposeBag()
    
    // MARK: Input
    
    init(coordinator: ChatCoordinator) {
        self.coordinator = coordinator
    }
}
    
