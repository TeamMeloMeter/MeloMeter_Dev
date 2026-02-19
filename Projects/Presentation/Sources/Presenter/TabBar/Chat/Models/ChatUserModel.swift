//
//  ChatUserModel.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
import MessageKit

public struct ChatUserModel: SenderType, Equatable {
    public var senderId: String
    public var displayName: String

    public init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
