//
//  StartVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/22.
//

import Foundation

import UIKit
//시작 뷰
class StartVC: UIViewController {
    
    let startView = StartView()
    
    override func loadView() {
        view = startView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startView.startBtn.addTarget(self, action: #selector(startBtnTapped), for: .touchUpInside)
    }
   
    // 시작하기 버튼 클릭
    @objc func startBtnTapped() {
        let phoneCertifiedVC = PhoneCertifiedVC()
        phoneCertifiedVC.modalPresentationStyle = .fullScreen
        dismiss(animated: true, completion: nil)
        self.present(phoneCertifiedVC, animated: true, completion: nil)
    }
}
