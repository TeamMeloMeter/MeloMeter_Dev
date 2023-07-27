//
//  EditStateMassageView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class EditStatusMessageView: UIView {
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.addSubview(exLabel)
        view.addSubview(statusTextField)
        view.addSubview(statusTextCountLabel)
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 기분을 표현해보세요."
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var statusTextField: UITextField = {
        let tv = UITextField()
        // 플레이스홀더에 표시할 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray3,
            .font: FontManager.shared.medium(ofSize: 16)
        ]
        tv.attributedPlaceholder = NSAttributedString(string: "원하는 말을 적어보세요!", attributes: attributes)
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
    
    
    var statusTextCountLabel: UILabel = {
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
        [topView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        statusViewConstraint()
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
    
    private func statusViewConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        statusTextField.translatesAutoresizingMaskIntoConstraints = false
        statusTextCountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),
            
            statusTextField.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            statusTextField.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            statusTextField.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 17),
            statusTextField.heightAnchor.constraint(equalToConstant: 50),
          
            
            statusTextCountLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            statusTextCountLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 40),

            

        ])
    }
    
}
