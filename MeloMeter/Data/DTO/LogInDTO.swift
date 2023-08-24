//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/13.
//

import Foundation

struct LogInDTO: Codable {
    
    // MARK: - Properties
    let fcmToken: String?
    let uid: String
    let phoneNumber: String
    let createdAt: String
    let inviteCode: String
    
    // MARK: - Methods
    func toModel() -> LogInModel {
        return LogInModel(
            fcmToken: fcmToken,
            uid: uid,
            phoneNumber: phoneNumber,
            createdAt: Date.fromStringOrNow(createdAt, .timeStamp),
            inviteCode: inviteCode
        )
    }
}
