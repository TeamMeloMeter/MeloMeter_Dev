//
//  TabBarController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

class TabBarController: UITabBarController {
    //탭바 타이틀 없애기
    let titles = ["", "", ""]
    //탭바 기본 아이콘
    let defaultImages = [UIImage(named: "chatIcon"), UIImage(named: "mapIcon"), UIImage(named: "myPageIcon")]
    let mapVC = MapViewController()
    let chatVC = AlarmViewController() // 채팅뷰 임시
    let myProfileVC = MyProfileViewController()
    
    
    //let views = [AlarmViewController(), MainViewController(), MyProfileViewController()]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 탭바에 네비게이션 컨트롤러 추가
        let mapNav = UINavigationController(rootViewController: mapVC)
        //let chatNav = UINavigationController(rootViewController: chatVC)
        let myProfileNav = UINavigationController(rootViewController: myProfileVC)
        
        //탭바 프레임
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 83
        tabFrame.origin.y = self.view.frame.size.height - 83
        self.tabBar.frame = tabFrame
        mapNav.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "mapIcon"), selectedImage: UIImage(named: "mapIconSelect"))
        chatVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "chatIcon"), selectedImage: UIImage(named: "chatIconSelect"))
        myProfileNav.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "myPageIcon"), selectedImage: UIImage(named: "myPageIconSelect"))

        let appearance = UITabBarAppearance()
        let tabBar = UITabBar()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
      
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        viewControllers = [chatVC, mapNav, myProfileNav]
        
        selectedIndex = 1
    }
}
extension CALayer {
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.1,
        x: CGFloat = 2,
        y: CGFloat = 2,
        blur: CGFloat = 20
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
}

extension UITabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용가능
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
}
