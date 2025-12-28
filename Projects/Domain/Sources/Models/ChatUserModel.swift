//
//  chatUserModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import Foundation
import MessageKit

public struct ChatUserModel: SenderType, Equatable {
  public var senderId: String //자신의 UUID
  public var displayName: String //프로필 이름

  public init(senderId: String, displayName: String) {
    self.senderId = senderId
    self.displayName = displayName
  }
}
