//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/13.
//

import Foundation
#if canImport(Domain)
import Domain
#endif

public struct LogInDTO: Codable {
    
    // MARK: - Properties
    public let fcmToken: String?
    public let uid: String
    public let phoneNumber: String
    public let createdAt: String
    public let inviteCode: String
    public var stateMessage: String

    public init(fcmToken: String?, uid: String, phoneNumber: String, createdAt: String, inviteCode: String, stateMessage: String = "") {
        self.fcmToken = fcmToken
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.inviteCode = inviteCode
        self.stateMessage = stateMessage
    }

    // MARK: - Methods
    public func toModel() -> LogInModel {
        return LogInModel(
            fcmToken: fcmToken,
            uid: uid,
            phoneNumber: phoneNumber,
            createdAt: Date.fromStringOrNow(createdAt, .timeStamp),
            inviteCode: inviteCode
        )
    }
}
