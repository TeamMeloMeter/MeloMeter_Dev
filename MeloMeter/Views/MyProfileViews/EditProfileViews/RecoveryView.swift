//
//  RecoveryView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit

class RecoveryView: UIView {
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.addSubview(exView)
        view.addSubview(exLabel1)
        view.addSubview(namesLabel)
        view.addSubview(exLabel2)
        view.addSubview(exLabel3)
        view.addSubview(lineView)

        return view
    }()
    
    lazy var exView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), alpha: 0.25, x: 0, y: 2, blur: 8)
        
        
        return view
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    private let exLabel1: UILabel = {
        let label = UILabel()
        label.text = "상대방과 연결이 끊어졌어요"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()
    
    private let exLabel2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "• 연결 끊김 : 2023.05.15\n• 복구 가능한 기간 : 2023.06.15 까지"

        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 // 줄 사이 간격
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        label.font = FontManager.shared.semiBold(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    private let exLabel3: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        let labelText = "나와 상대방의 연결이 끊어지면 두 분이 업로드한 모든 자료(대화,기념일 등)의 열람이 차단되며, 기간 내 재연결을 하거나 백업 받은 파일로만 기존 자료를 확인 하실 수 있습니다.\n\n재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."
        let attributedString = NSMutableAttributedString(string: labelText)
        label.text = labelText
        let findString = ["재연결 시, 연결을 끊었던 계정으로 로그인 및 재연결을 해야만 합니다."]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7 // 줄 사이 간격
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        // 특정 문자열 범위 찾기
        for i in findString {
            if let range = label.text?.range(of: i) {
                // 특정 문자열에 대한 속성 정의
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.gray1,
                    .font: FontManager.shared.semiBold(ofSize: 14)
                ]
                
                // 속성 적용
                let nsRange = NSRange(range, in: labelText)
                attributedString.addAttributes(attributes, range: nsRange)
            }
        }
        label.attributedText = attributedString
        
        return label
    }()
    
    private let namesLabel: UILabel = {
        let label = UILabel()
        label.text = "소희&제훈"
        label.font = FontManager.shared.semiBold(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    let disconnectBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("자료 복구 하기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 18)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        
        return button
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
        [topView, disconnectBtn].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        disconnectConstraints()
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
    
    private func disconnectConstraints() {
        exView.translatesAutoresizingMaskIntoConstraints = false
        exLabel1.translatesAutoresizingMaskIntoConstraints = false
        exLabel2.translatesAutoresizingMaskIntoConstraints = false
        exLabel3.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        disconnectBtn.translatesAutoresizingMaskIntoConstraints = false
        namesLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            exView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 43),
            exView.widthAnchor.constraint(equalToConstant: 343),
            exView.heightAnchor.constraint(equalToConstant: 438),
            
            exLabel1.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            exLabel1.topAnchor.constraint(equalTo: exView.topAnchor, constant: 33),
            
            lineView.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            lineView.topAnchor.constraint(equalTo: exLabel1.bottomAnchor, constant: 19),
            lineView.widthAnchor.constraint(equalToConstant: 291),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            namesLabel.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            namesLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 23),

            exLabel2.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            exLabel2.topAnchor.constraint(equalTo: namesLabel.bottomAnchor, constant: 10),
            
            exLabel3.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            exLabel3.topAnchor.constraint(equalTo: exLabel2.bottomAnchor, constant: 33),
            exLabel3.widthAnchor.constraint(equalToConstant: 298),

            disconnectBtn.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            disconnectBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -70),
            disconnectBtn.widthAnchor.constraint(equalToConstant: 327),
            disconnectBtn.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
}
