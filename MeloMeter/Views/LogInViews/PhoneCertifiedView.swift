//
//  PhoneCertifiedView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/22.
//

import UIKit
//전화번호 입력 뷰
class PhoneCertifiedView: UIView {
   
    let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "멜로미터 시작을 위하여\n휴대폰 번호를 입력해 주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        
        return label
    }()
    
    lazy var phoneNumTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        tv.placeholder = "휴대폰 번호 입력"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "휴대폰 번호 입력", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        tv.becomeFirstResponder()
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    lazy var nextInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(nextBtn)
        
        return view
    }()
    
    // 다음버튼
    let nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        button.layer.applyShadow(color: #colorLiteral(red: 0.9341433644, green: 0.9341433644, blue: 0.9341433644, alpha: 1), alpha: 1.0, x: 4, y: 0, blur: 10)
        
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "‘다음’을 누르시면, 입력한 번호로 인증번호가 전송됩니다\n이미 계정이 있으신 경우, 번호 입력->인증을 재진행 해주세요"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let range = NSRange(location: 46, length: 15)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.semiBold(ofSize: 12),
            .foregroundColor: UIColor.gray1
        ]
        attributedString.addAttributes(attributes, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    let cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.backgroundColor = .white
        button.isHidden = true
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
        [progressImage, titleLabel, phoneNumTF, lineView, exLabel, cancelBtn].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        progressConstraint()
        titleLabelConstraint()
        phoneNumConstraint()
        exLabelConstraint()
        nextInputViewConstraints()
    }
    
    private func progressConstraint() {
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 167),
            progressImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            progressImage.widthAnchor.constraint(equalToConstant: 42),
            progressImage.heightAnchor.constraint(equalToConstant: 5)
            
        ])
    }
    
    private func titleLabelConstraint() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: progressImage.bottomAnchor, constant: 51),
        ])
    }
    
    private func phoneNumConstraint() {
        phoneNumTF.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            phoneNumTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            phoneNumTF.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            lineView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView.topAnchor.constraint(equalTo: phoneNumTF.bottomAnchor, constant: 12),
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            
            cancelBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -3),
            cancelBtn.bottomAnchor.constraint(equalTo: lineView.topAnchor),
            cancelBtn.widthAnchor.constraint(equalToConstant: 44),
            cancelBtn.heightAnchor.constraint(equalToConstant: 44),

        ])
    }
    
    private func exLabelConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
        ])
    }
    private func nextInputViewConstraints() {
        nextBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            nextBtn.leadingAnchor.constraint(equalTo: nextInputView.leadingAnchor),
            nextBtn.trailingAnchor.constraint(equalTo: nextInputView.trailingAnchor),
            nextBtn.heightAnchor.constraint(equalToConstant: 52)

        ])
    }
}
