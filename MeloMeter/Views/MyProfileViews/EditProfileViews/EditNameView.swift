//
//  EditNameView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class EditNameView: UIView {
    
    let exLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방에게 표시되는 이름이에요."
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let tv = UITextField()
        
        tv.text = "김소희"
        tv.backgroundColor = .gray5
        tv.textColor = .gray1
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        
        tv.keyboardType = .default
        tv.tintColor = .gray1
        tv.addLeftPadding()
        
        tv.layer.cornerRadius = 8
        tv.layer.masksToBounds = false
        return tv
    }()
    
    var nameTextCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = FontManager.shared.medium(ofSize: 13)
        label.textColor = .gray2
        return label
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
        [exLabel, nameTextField, nameTextCountLabel].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        nameTFViewConstraint()
    }
    
    
    private func nameTFViewConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            
            nameTextField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            nameTextCountLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextCountLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),

        ])
    }
    
}
