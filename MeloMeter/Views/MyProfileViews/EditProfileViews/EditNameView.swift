//
//  EditNameView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class EditNameView: UIView {
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.addSubview(exLabel)
        view.addSubview(nameTextField)
        view.addSubview(nameTextCountLabel)
        return view
    }()
    
    let exLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방에게 표시되는 이름이에요."
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        return label
    }()
    
    lazy var nameTextField: UITextField = {
        let tv = UITextField()
        
        tv.text = "김소희"
        tv.backgroundColor = .white
        tv.textColor = .black
        tv.font = FontManager.shared.medium(ofSize: 16)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        
        tv.keyboardType = .default
        tv.tintColor = .black
        tv.addLeftPadding()
        return tv
    }()
    
    var nameTextCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.font = FontManager.shared.medium(ofSize: 13)
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
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
        [topView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        nameTFViewConstraint()
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
    
    private func nameTFViewConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
            
            nameTextField.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            nameTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            nameTextCountLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            nameTextCountLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),

        ])
    }
    
}
