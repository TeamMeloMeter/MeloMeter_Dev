//
//  AddScheduleVC.swift
//  Presentation
//
//  Created by OpenCode on 2026/01/14.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Domain
import Core

public class AddScheduleVC: UIViewController {
    
    private let disposeBag = DisposeBag()
    public var onSave: ((DatePlanModel) -> Void)?
    
    // UI Components
    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "일정 제목"
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let memoField: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels // 달력 오해 방지 위해 휠 스타일 사용
        return picker
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("일정 추가하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 18)
        button.backgroundColor = .primary1
        button.layer.cornerRadius = 25
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.3, x: 0, y: 4, blur: 10)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
        setupKeyboardDismiss()
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleField)
        view.addSubview(datePicker)
        view.addSubview(memoField)
        view.addSubview(saveButton)
        
        titleField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        memoField.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(memoField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func bind() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let title = self.titleField.text, !title.isEmpty else { return }
                
                let date = self.datePicker.date
                let dateString = date.toString(type: .yearToSecond)
                
                let plan = DatePlanModel(
                    uuid: UUID().uuidString,
                    name: title,
                    memo: self.memoField.text ?? "",
                    mapX: 0.0,
                    mapY: 0.0,
                    roadAddress: "",
                    address: "",
                    scheduledAt: dateString,
                    createdAt: Date().toString(type: .yearToSecond),
                    createdBy: UserDefaults.standard.string(forKey: "uid") ?? "",
                    notifyEnabled: true
                )
                
                self.onSave?(plan)
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
