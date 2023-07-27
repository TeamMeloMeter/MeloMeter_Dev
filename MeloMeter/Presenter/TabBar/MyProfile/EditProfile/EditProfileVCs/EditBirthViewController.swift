//
//  EditBirthViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
//생일 편집
class EditBirthViewController: UIViewController, UITextFieldDelegate {
    
    let editBirthView = EditBirthView()
    
    override func loadView() {
        view = editBirthView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBirthView.birthTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
    }
    
    //데이트피커 날짜 변경 시 실행
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        editBirthView.birthTextField.text = dateFormatter.string(from: datePicker.date)
        navigationItem.rightBarButtonItem?.isEnabled = true //등록버튼 활성화
    }

    //날짜 텍스트필드 활성화 시 실행
    func textFieldDidBeginEditing(_ textField: UITextField) {

        editBirthView.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
    }
    
    // 뷰 터치 시 inputView 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        editBirthView.topView.endEditing(true)
    }
    
    //상태메세지 편집 네비게이션바 설정
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "생일"
        
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
