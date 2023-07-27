//
//  DisconnectVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit
//연결 끊기
class DisconnectVC: UIViewController {
    
    let disconnetView = DisconnetView()
    
    override func loadView() {
        view = disconnetView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        disconnetView.disconnectBtn.addTarget(self, action: #selector(disconnectBtnTapped), for: .touchUpInside)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }
   
    //데이터 복구 화면으로
    @objc func disconnectBtnTapped() {
        let VC = RecoveryVC()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "연결끊기"
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
