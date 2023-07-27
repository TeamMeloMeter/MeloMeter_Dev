//
//  AnswerViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

//자주묻는 질문 상세페이지
class AnswerViewController: UIViewController {
    

    private let answerView = AnswerView()
    
    override func loadView() {
        view = answerView
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
        navigationItem.title = ""
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        
    }
    
    //뒤로가기 버튼이벤트
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
    
}
