//
//  EditStatusMessageVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
//상태메세지 편집
class EditStatusMessageVC: UIViewController, UITextFieldDelegate {
    
    let editStatusMessageView = EditStatusMessageView()
    
    override func loadView() {
        view = editStatusMessageView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        editStatusMessageView.statusTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editStatusMessageView.statusTextField.becomeFirstResponder()
    }
    
    //텍스트 변경 시 이벤트
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationItem.rightBarButtonItem?.isEnabled = true //등록버튼 활성화
        
        guard let currentText = textField.text else { return true }
        
        let newLength = currentText.count + string.count - range.length
        if newLength > 20 {
            return false
        }
        editStatusMessageView.statusTextCountLabel.text = "\(newLength)/20"
        
        return true
    }
    
    // 뷰 터치 시 inputView 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editStatusMessageView.topView.endEditing(true)
    }
    
    //상태메세지 편집 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "상태메세지"
        
        let barButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: #selector(doneButtonTapped))
        let attributes = [NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        barButtonItem.setTitleTextAttributes(attributes, for: .normal)
        navigationItem.rightBarButtonItem = barButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem?.isEnabled = false
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        
    }
    
    //등록 버튼이벤트
    @objc func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    //뒤로가기 버튼이벤트
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
}
