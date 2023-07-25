//
//  PermissionVM.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/26.
//

import UIKit
import RxSwift

class PermissionVM {

    weak var coordinator: LogInCoordinator?
    private let disposeBag = DisposeBag()
    // MARK: Input
    
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
    }
    
}
