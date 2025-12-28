//
//  TabBarPageType.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/27.
//

import UIKit
import Domain
import Core

public enum TabBarPageType: Int, CaseIterable {
    case chat, main = 1, myPage
    
    public var tabBarItem: UITabBarItem {
        switch self {
        case .chat:
            return UITabBarItem(
                title: "",
                image: UIImage(named: "chatIcon"),
                selectedImage: UIImage(named: "chatIconSelect")
            )
        case .main:
            return UITabBarItem(
                title: "",
                image: UIImage(named: "mapIcon"),
                selectedImage: UIImage(named: "mapIconSelect")
            )
        case .myPage:
            return UITabBarItem(
                title: "",
                image: UIImage(named: "myPageIcon"),
                selectedImage: UIImage(named: "myPageIconSelect")
            )
        }
    }
}
