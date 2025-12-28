//
//  TabBarPageCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import UIKit
import Domain
import Core

public enum TabBarPageCase: Int, CaseIterable {
    case chat, main = 1, myPage

    // MARK: - Properties
    public var pageOrderNumber: Int {
        return self.rawValue
    }

    // MARK: - Methods
    public func tabIcon() -> UIImage {
        switch self {
        case .chat:
            return UIImage(named: "chatIcon")!
        case .main:
            return UIImage(named: "mapIcon")!
        case .myPage:
            return UIImage(named: "myPageIcon")!
        }
    }

    public func selectedTabIcon() -> UIImage {
        switch self {
        case .chat:
            return UIImage(named: "chatIconSelect")!
        case .main:
            return UIImage(named: "mapIconSelect")!
        case .myPage:
            return UIImage(named: "myPageIconSelect")!
        }
    }
}
