//
//  EditNameViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
//이름 편집
class EditNameViewController: UIViewController, UITextFieldDelegate {
    
    let editNameView = EditNameView()
    
    override func loadView() {
        view = editNameView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editNameView.nameTextField.delegate = self
        editNameView.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editNameView.nameTextField.becomeFirstResponder()
    }

    // This function will be called when the text in the text field changes
    @objc func textFieldDidChange(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // 뷰 터치 시 inputView 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editNameView.topView.endEditing(true)
    }
    
    //이름편집 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "이름"

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
