//
//  ProfileInsertDTO.swift
//  MeloMeter
//
//  Created by LTS on 2023/07/24.
//

import Foundation

struct ProfileInsertDTO: Codable {
    
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
