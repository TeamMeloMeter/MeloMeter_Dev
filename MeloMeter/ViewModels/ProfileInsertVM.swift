//
//  ProfileInsertViewModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/03.
//

import UIKit

class ProfileInsertVM {
    
    weak var coordinator: LogInCoordinator?
    
    // MARK: - Init
    init(coordinator: LogInCoordinator) {
        self.coordinator = coordinator
    }
    
}

