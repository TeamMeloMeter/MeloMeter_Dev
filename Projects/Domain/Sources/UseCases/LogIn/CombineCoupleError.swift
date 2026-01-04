//
//  CombineCoupleError.swift
//  MeloMeter
//
//  Created by Codex on 2025/01/02.
//

import Foundation

public enum CombineCoupleError: LocalizedError {
    case inviteCodeNotFound
    case sameAccount
    case otherFcmTokenMissing
    case myFcmTokenMissing
    case invalidData
    case unknown

    public var errorDescription: String? {
        switch self {
        case .inviteCodeNotFound:
            return "상대방 초대코드를 찾을 수 없습니다."
        case .sameAccount:
            return "같은 계정으로는 커플 연결이 불가합니다."
        case .otherFcmTokenMissing:
            return "상대방 기기의 알림 토큰이 없습니다. 상대방이 앱을 한 번 실행했는지 확인해주세요."
        case .myFcmTokenMissing:
            return "내 기기의 알림 토큰이 없습니다. 앱을 재시작한 뒤 다시 시도해주세요."
        case .invalidData:
            return "사용자 정보를 읽지 못했습니다. 다시 시도해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
