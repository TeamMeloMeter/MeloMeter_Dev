//
//  WithdrawalView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit

class WithdrawalView: UIView {
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.addSubview(exView)
        view.addSubview(exLabel1)
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
        label.text = "멜로미터 탈퇴 전 확인해주세요"
        label.font = FontManager.shared.semiBold(ofSize: 18)
        label.textColor = .gray1
        return label
    }()
    
    
    private let exLabel3: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        let labelText = "더 이상 멜로미터 사용을 원하지 않을 경우,\n먼저 연결을 끊어야 합니다. 멜로미터 앱 내에서\n<마이페이지 - 프로필 편집 - 상대방과 연결 끊기> 를\n통해 상대방과 연결을 끊을 수 있습니다.\n\n연결이 끊어지면 기존 자료에 대한 접근이 차단됩니다.\n연결을 끊은 후, 모든 자료를 영구히 삭제하고 싶다면,\n아래 버튼을 통해 계정 삭제 절차를 밟아야 합니다.\n\n계정 삭제 후에는 데이터가 완전히 파기되므로,\n복구 및 재연결이 불가능합니다. 동일한 계정으로 재가\n입한 경우에도 복구가 불가능 하니, 신중하게 결정해\n주세요!"
        let attributedString = NSMutableAttributedString(string: labelText)
        label.text = labelText
        let findString = ["<마이페이지 - 프로필 편집 - 상대방과 연결 끊기> 를\n통해 상대방과 연결을 끊을 수 있습니다.", "계정 삭제 후에는 데이터가 완전히 파기되므로,\n복구 및 재연결이 불가능합니다. 동일한 계정으로 재가\n입한 경우에도 복구가 불가능 하니, 신중하게 결정해\n주세요!"]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7 // 줄 사이 간격
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        // 특정 문자열 범위 찾기
        for i in findString {
            if let range = label.text?.range(of: i) {
                // 특정 문자열에 대한 속성 정의
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.black,
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
    
    let withdrawalBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("멜로미터 탈퇴하기", for: .normal)
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
        [topView, withdrawalBtn].forEach { addSubview($0) }
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
        exLabel3.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        withdrawalBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            exView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 43),
            exView.widthAnchor.constraint(equalToConstant: 343),
            exView.heightAnchor.constraint(equalToConstant: 469),
            
            exLabel1.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            exLabel1.topAnchor.constraint(equalTo: exView.topAnchor, constant: 40),
            
            lineView.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            lineView.topAnchor.constraint(equalTo: exLabel1.bottomAnchor, constant: 19),
            lineView.widthAnchor.constraint(equalToConstant: 291),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            exLabel3.leadingAnchor.constraint(equalTo: exView.leadingAnchor, constant: 23),
            exLabel3.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 17),
            exLabel3.widthAnchor.constraint(equalToConstant: 298),

            withdrawalBtn.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            withdrawalBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -70),
            withdrawalBtn.widthAnchor.constraint(equalToConstant: 327),
            withdrawalBtn.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
}
