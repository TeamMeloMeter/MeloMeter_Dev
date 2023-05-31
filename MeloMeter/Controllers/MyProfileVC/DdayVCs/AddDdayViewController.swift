//
//  AddDdayViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit

class AddDdayViewController: UIViewController, UITextFieldDelegate {
    
    let addDdayView = AddDdayView()
    private let dateFormatter = DateFormatter()
    
    override func loadView() {
        
        view = addDdayView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addDdayView.titleTextView.delegate = self
        addDdayView.dateTextField.delegate = self
       

        addDdayView.xButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        
        
    }
    
    // 뷰 터치 시 inputView 내림
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addDdayView.containerView.endEditing(true)
    }
    // 창 닫기
    @objc func xButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //데이트피커 날짜 변경 시 실행
    @objc func dateChanged(datePicker: UIDatePicker) {
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        addDdayView.dateTextField.text = dateFormatter.string(from: datePicker.date)
        addDdayView.saveButton.isEnabled = true
        addDdayView.saveButton.alpha = 1.0

    }

    //날짜 텍스트필드 활성화 시 실행
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        addDdayView.datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        addDdayView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        guard let addAni = addDdayView.titleTextView.text else { return }
        guard let addDate = addDdayView.dateTextField.text else { return }
        Model.shared.addDdayArray.append([addAni, addDate])
        self.dismiss(animated: true, completion: nil)
    }
    
    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddDdayViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        //text 변경 시 placeholder 숨김
        addDdayView.textPlaceHolderLabel.isHidden = !textView.text.isEmpty
        //입력 글자 수 label 표시
        addDdayView.textCountLabel.text = "\(addDdayView.titleTextView.text.count)/10"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 현재 텍스트 길이와 입력하려는 텍스트 길이의 합이 최대 길이를 초과하면 false 반환
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 10
    }
    
}
