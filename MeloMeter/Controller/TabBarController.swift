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
    let mainVC = MainViewController()
    let chatVC = AlarmViewController() // 채팅뷰 임시
    let myProfileVC = MyProfileViewController()
    
    
    //let views = [AlarmViewController(), MainViewController(), MyProfileViewController()]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapIcon = UIImage(named: "mapIcon")?.withRenderingMode(.alwaysOriginal)
        let chatIcon = UIImage(named: "chatIcon")?.withRenderingMode(.alwaysOriginal)
        let myPageIcon = UIImage(named: "myPageIcon")?.withRenderingMode(.alwaysOriginal)
        //아이콘 사이즈 조정
        let newSize = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let mapIconResized = renderer.image { context in
            mapIcon?.draw(in: CGRect(origin: .zero, size: newSize))
        }
        let chatIconResized = renderer.image { context in
            chatIcon?.draw(in: CGRect(origin: .zero, size: newSize))
        }
        let myPageIconResized = renderer.image { context in
            myPageIcon?.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        /// 탭바에 네비게이션 컨트롤러 추가
        //let mainNav = UINavigationController(rootViewController: mainVC)
        //let chatNav = UINavigationController(rootViewController: chatVC)
        let myProfileNav = UINavigationController(rootViewController: myProfileVC)
        
        //탭바 프레임
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 83
        tabFrame.origin.y = self.view.frame.size.height - 83
        self.tabBar.frame = tabFrame
        
        
        if let tabBar = tabBarController?.tabBar {
            UITabBar.clearShadow()
        }
        mainVC.tabBarItem = UITabBarItem(title: "", image: mapIconResized, tag: 0)
        chatVC.tabBarItem = UITabBarItem(title: "", image: chatIconResized, tag: 1)
        myProfileNav.tabBarItem = UITabBarItem(title: "", image: myPageIconResized, tag: 2)
        
        let appearance = UITabBarAppearance()
        let tabBar = UITabBar()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
      
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        viewControllers = [chatVC, mainVC, myProfileNav]
        
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
