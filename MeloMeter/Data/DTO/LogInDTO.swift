//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/13.
//

import Foundation

struct LogInDTO: Codable {
    
    // MARK: - Properties
    let uid: String
    let phoneNumber: String
    let createdAt: String
    let inviteCode: String
    
    // MARK: - Methods
    func toModel() -> LogInModel {
        return LogInModel(
            uid: uid,
            phoneNumber: phoneNumber,
            createdAt: Date.fromStringOrNow(createdAt),
            inviteCode: inviteCode
        )
    }
}
