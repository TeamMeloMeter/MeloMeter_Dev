//
//  DdayViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

// 기념일 화면의 뷰컨트롤러
class DdayViewController: UIViewController{

    let dDayView = DdayView()
     override func loadView() {
         view = dDayView
         
     }
     override func viewDidLoad() {
         super.viewDidLoad()
         navigationBarCustom()
     }
     
     private func navigationBarCustom() {
         navigationController?.navigationBar.isHidden = false
         navigationItem.title = "기념일"
         
         let appearance = UINavigationBarAppearance()
         appearance.configureWithOpaqueBackground()
         appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
         
         navigationController?.navigationBar.standardAppearance = appearance
         navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
         
     }

}
