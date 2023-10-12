//
//  MockSocket.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/07.
//

import MessageKit
import UIKit

final class MockSocket {
  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  static var shared = MockSocket()

  @discardableResult
  func disconnect() -> Self {
    timer?.invalidate()
    timer = nil
    onTypingStatusCode = nil
    onNewMessageCode = nil
    return self
  }

  @discardableResult
  func onNewMessage(code: @escaping (MockMessage) -> Void) -> Self {
    onNewMessageCode = code
    return self
  }

  @discardableResult
  func onTypingStatus(code: @escaping () -> Void) -> Self {
    onTypingStatusCode = code
    return self
  }

  // MARK: Private

  private var timer: Timer?

  private var queuedMessage: MockMessage?

  private var onNewMessageCode: ((MockMessage) -> Void)?

  private var onTypingStatusCode: (() -> Void)?

  private var connectedUsers: [MockUser] = []

}
