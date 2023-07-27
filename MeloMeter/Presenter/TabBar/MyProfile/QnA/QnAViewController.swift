//
//  QnAViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

class QnAViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    private let qnAView = QnAView()
    private var radioBtnArray: [UIButton] = []
    override func loadView() {
        view = qnAView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        qnAView.qnATableView.delegate = self
        qnAView.qnATableView.dataSource = self
        radioBtnArray = [qnAView.radioBtn, qnAView.radioBtn1, qnAView.radioBtn2, qnAView.radioBtn3, qnAView.radioBtn4, qnAView.radioBtn5]
        
        for button in radioBtnArray {
            button.addTarget(self, action: #selector(radioBtnTapped), for: .touchUpInside)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }
    @objc func radioBtnTapped(_ sender: UIButton) {
        radioBtnArray.forEach { $0.isSelected = false; $0.backgroundColor = .gray5
            $0.titleLabel?.font = FontManager.shared.medium(ofSize: 14)}
        
        sender.isSelected = true
        sender.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        sender.backgroundColor = .primary1
    }
    
    //셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    //적용할 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QnATableViewCell", for: indexPath) as? QnATableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    // 셀 선택 이벤트 구현
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answerViewController = AnswerViewController()
        answerViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(answerViewController, animated: true)
    }
    
    
    //공지사항 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "자주묻는 질문"
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
