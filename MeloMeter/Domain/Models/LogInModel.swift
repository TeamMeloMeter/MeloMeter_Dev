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

struct LogInModel: Equatable, Hashable {
    let fcmToken: String?
    let uid: String
    let phoneNumber: String
    let createdAt: Date
    let inviteCode: String
}
