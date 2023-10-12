//
//  chatUserModel.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import Foundation
import MessageKit

struct ChatUserModel: SenderType, Equatable {
  var senderId: String //자신의 UUID
  var displayName: String //프로필 이름
}

