//
//  TabBarPageCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import UIKit

enum TabBarPageCase: Int, CaseIterable {
    case chat, main = 1, myPage

    // MARK: - Properties
    var pageOrderNumber: Int {
        return self.rawValue
    }

    // MARK: - Methods
    func tabIcon() -> UIImage {
        switch self {
        case .chat:
            return UIImage(named: "chatIcon")!
        case .main:
            return UIImage(named: "mapIcon")!
        case .myPage:
            return UIImage(named: "myPageIcon")!
        }
    }

    func selectedTabIcon() -> UIImage {
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
