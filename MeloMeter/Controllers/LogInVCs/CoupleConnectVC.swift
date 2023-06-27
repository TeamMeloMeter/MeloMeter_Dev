//
//  CoupleConnectVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/27.
//

import UIKit
// 커플 등록
class CoupleConnectVC: UIViewController {
    
    let coupleConnectView = CoupleConnectView()
    
    override func loadView() {
        view = coupleConnectView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        coupleConnectView.lineView1.setGradientBackground(colors: [.primary1, .white])
    }
   
}
