//
//  MessageType.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/01.
//
//매시지 타입 정의

import Foundation
import MessageKit

public protocol MessageType {

    var sender: Sender { get }

    var messageId: String { get }

    var sentDate: Date { get }

    var kind: MessageKind { get }
}
