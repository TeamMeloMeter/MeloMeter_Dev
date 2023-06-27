//
//  AuthNumView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/24.
//

import UIKit
//인증번호 입력 뷰
class AuthNumView: UIView {
   
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "인증번호를\n입력하세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    lazy var authNumTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "인증 번호 입력", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        
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
        button.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
        button.isEnabled = true
        return button
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "전송된 인증번호는 10분 안에 인증이 만료됩니다"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
    }()
    
    let cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.backgroundColor = .white
        //button.isHidden = true
        return button
    }()
    
    //시간 표시
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "09:59"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    //재전송 버튼
    let retransBtn: UIButton = {
        let button = UIButton()
        button.setTitle("재전송 받기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
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
        [progressImage, titleLabel, authNumTF, lineView, exLabel, cancelBtn, timeLabel, retransBtn].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        progressConstraint()
        titleLabelConstraint()
        authNumTFConstraint()
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
    
    private func authNumTFConstraint() {
        authNumTF.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            authNumTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            authNumTF.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            lineView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView.topAnchor.constraint(equalTo: authNumTF.bottomAnchor, constant: 12),
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            
            cancelBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -3),
            cancelBtn.bottomAnchor.constraint(equalTo: lineView.topAnchor),
            cancelBtn.widthAnchor.constraint(equalToConstant: 44),
            cancelBtn.heightAnchor.constraint(equalToConstant: 44),

        ])
    }
    
    private func exLabelConstraint() {
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        retransBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            exLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 22),
            
            timeLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 11),

            retransBtn.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 9),
            retransBtn.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 10),
            retransBtn.widthAnchor.constraint(equalToConstant: 64),
            retransBtn.heightAnchor.constraint(equalToConstant: 20)
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
