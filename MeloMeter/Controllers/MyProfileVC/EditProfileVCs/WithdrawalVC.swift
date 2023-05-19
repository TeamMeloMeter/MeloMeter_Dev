//
//  WithdrawalVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit
//연결끊기 후 데이터 복구 화면
class WithdrawalVC: UIViewController {
    
    let withdrawalView = WithdrawalView()
    
    override func loadView() {
        view = withdrawalView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }
   
    
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "회원탈퇴"
        navigationItem.rightBarButtonItem?.tintColor = .black
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
}
