//
//  EditBirthView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class EditBirthView: UIView {
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.addSubview(exLabel)
        view.addSubview(birthTextField)
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        return label
    }()
    
    lazy var birthTextField: UITextField = {
        let tv = UITextField()
        
        tv.backgroundColor = .white
        tv.textColor = .black
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.keyboardType = .default
        tv.tintColor = .black
        tv.inputView = datePicker
        tv.becomeFirstResponder()
        tv.addLeftPadding()
    
        return tv
    }()
    
    //datePicker
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.backgroundColor = UIColor.white
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        return datePicker
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
    }
    
    func addViews() {
        [topView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        birthViewConstraint()
    }
    
    private func topViewConstraint() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

        ])
    }
    
    private func birthViewConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        birthTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
            
            birthTextField.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            birthTextField.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            birthTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            birthTextField.heightAnchor.constraint(equalToConstant: 49),
            birthTextField.widthAnchor.constraint(equalToConstant: 140),

        ])
    }
    
}
