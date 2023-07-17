//
//  CoupleConnectView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/27.
//

import UIKit
//커플등록 뷰
class CoupleConnectView: UIView {
   
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress3")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "커플 연결을 위해\n서로의 초대코드를 입력해주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    let user1Label: UILabel = {
        let label = UILabel()
        label.text = "내 초대코드(23:59:59)"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    //내 코드 표시
    let myCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "03318779"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 18)
        return label
    }()
    
    lazy var lineView1: UIView = {
        let view = UIView()
        return view
    }()
    
    let shareBtn: UIButton = {
        let button = UIButton()
        button.setTitle("공유", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.9971519113, green: 0.4873556495, blue: 0.9974393249, alpha: 0.22)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        return button
    }()
    
    let user2Label: UILabel = {
        let label = UILabel()
        label.text = "상대방 초대코드"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var codeTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "상대방 초대 코드 입력", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .numberPad
        tv.tintColor = .gray1
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    private let questLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.text = "연결에 문제가 있나요?"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    //문의버튼
    let contactBtn: UIButton = {
        let button = UIButton()
        button.setTitle("문의하기", for: .normal)
        button.setTitleColor(.gray1, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        return button
    }()
    
    // 다음버튼
    lazy var nextInputView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 52))
        view.addSubview(nextBtn)
        
        return view
    }()
    let nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.applyShadow(color: .primary1, alpha: 0.4, x: 4, y: 0, blur: 10)
        button.isEnabled = true
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
        [progressImage, titleLabel, user1Label, myCodeLabel, shareBtn, lineView1,
        user2Label, codeTF, lineView2,
        questLabel, contactBtn].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        progressConstraints()
        titleLabelConstraints()
        myCodeConstraints()
        user2Constraints()
        contactConstraints()
        nextInputViewConstraints()
    }
    
    private func progressConstraints() {
        progressImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 167),
            progressImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            progressImage.widthAnchor.constraint(equalToConstant: 42),
            progressImage.heightAnchor.constraint(equalToConstant: 5)
            
        ])
    }
    
    private func titleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 18),
            titleLabel.topAnchor.constraint(equalTo: progressImage.bottomAnchor, constant: 51),
        ])
    }
    
    private func myCodeConstraints() {
        user1Label.translatesAutoresizingMaskIntoConstraints = false
        myCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        shareBtn.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            user1Label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            user1Label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            
            myCodeLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            myCodeLabel.topAnchor.constraint(equalTo: user1Label.bottomAnchor, constant: 15),
            
            shareBtn.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            shareBtn.bottomAnchor.constraint(equalTo: myCodeLabel.bottomAnchor),
            shareBtn.widthAnchor.constraint(equalToConstant: 54),
            shareBtn.heightAnchor.constraint(equalToConstant: 32),
            
            lineView1.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView1.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView1.topAnchor.constraint(equalTo: shareBtn.bottomAnchor, constant: 12),
            lineView1.heightAnchor.constraint(equalToConstant: 1.5),
        ])
    }
    
    private func user2Constraints() {
        user2Label.translatesAutoresizingMaskIntoConstraints = false
        codeTF.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            user2Label.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            user2Label.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 40),
            
            codeTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            codeTF.topAnchor.constraint(equalTo: user2Label.bottomAnchor, constant: 15),
            
            lineView2.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView2.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView2.topAnchor.constraint(equalTo: codeTF.bottomAnchor, constant: 10),
            lineView2.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
    private func contactConstraints() {
        questLabel.translatesAutoresizingMaskIntoConstraints = false
        contactBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            questLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            questLabel.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 22),
            
            contactBtn.leadingAnchor.constraint(equalTo: questLabel.trailingAnchor, constant: 9),
            contactBtn.topAnchor.constraint(equalTo: questLabel.topAnchor),
            contactBtn.widthAnchor.constraint(equalToConstant: 49),
            contactBtn.heightAnchor.constraint(equalToConstant: 17)
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
