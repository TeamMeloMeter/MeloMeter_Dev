//
//  MockUser.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import Foundation
import MessageKit

struct MockUser: SenderType, Equatable {
  var senderId: String
  var displayName: String
}
