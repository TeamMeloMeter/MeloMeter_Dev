//
//  AuthUser.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation

public struct AuthUser {
    public let uid: String
    public let phoneNumber: String?

    public init(uid: String, phoneNumber: String?) {
        self.uid = uid
        self.phoneNumber = phoneNumber
    }
}
