//
//  alarmViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

class AlarmViewController: UIViewController {
    
   let alarmView = AlarmView()
    override func loadView() {
        view = alarmView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarCustom()
    }
    
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "알림"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
}
