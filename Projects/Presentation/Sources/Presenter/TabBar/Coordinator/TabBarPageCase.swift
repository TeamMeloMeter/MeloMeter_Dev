//
//  TabBarPageCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import UIKit
#if canImport(Domain)
import Domain
#endif
#if canImport(Core)
import Core
#endif

public enum TabBarPageCase: Int, CaseIterable {
    case chat, main = 1, calendar, myPage

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
        case .calendar:
            return UIImage(systemName: "calendar")!
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
        case .calendar:
            return UIImage(systemName: "calendar")! // 선택된 아이콘도 일단 동일하게
        case .myPage:
            return UIImage(named: "myPageIconSelect")!
        }
    }
}
