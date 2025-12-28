//
//  LogInDTO.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/06.
//

import Foundation

public enum LogInStatus {
    case none                // 로그인전
    case errorOccurred       //error
    case requestCompleted    // 요청 완료
    case validationFailed    // 입력실패
    case loginDenied         // 로그인거절
    case authenticated       // 인증완료
}

public struct LogInModel: Equatable, Hashable {
    public let fcmToken: String?
    public let uid: String
    public let phoneNumber: String
    public let createdAt: Date
    public let inviteCode: String

    public init(fcmToken: String?, uid: String, phoneNumber: String, createdAt: Date, inviteCode: String) {
        self.fcmToken = fcmToken
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.inviteCode = inviteCode
    }
}
