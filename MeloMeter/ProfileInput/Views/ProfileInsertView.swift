//
//  ProfileInsertView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/03.
//

import UIKit

//사용자 정보 입력 뷰
class ProfileInsertView: UIView {
   
    private let progressImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "progress4")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "연결 완료!\n멜로미터 시작 전\n프로필을 입력해주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var nameTF: UITextField = {
        let tv = UITextField()
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "이름 or 원하는 닉네임을 입력해주세요", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .default
        tv.tintColor = .gray1
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()

    private let birthLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var birthTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "만 14세 이상 입력이 가능합니다", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        tv.keyboardType = .default
        tv.tintColor = .gray1
        
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()
    
    private let firstDayLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 만난 날"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    lazy var firstDayTF: UITextField = {
        let tv = UITextField()
        
        tv.textColor = .gray1
        tv.font = FontManager.shared.semiBold(ofSize: 18)
        tv.autocorrectionType = .no // 자동수정 X
        tv.spellCheckingType = .no // 맞춤법 체크 X
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.medium(ofSize: 18),
            .foregroundColor: UIColor.gray2
        ]
        let attributedPlaceholder = NSAttributedString(string: "처음 만난 날을 입력해주세요", attributes: attributes)
        tv.attributedPlaceholder = attributedPlaceholder
        //tv.keyboardType = .default
        tv.tintColor = .gray1
        tv.inputAccessoryView = nextInputView //다음버튼 추가
        return tv
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 정보는 서비스 최적화를 위해서만 사용됩니다"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
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
    
    let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
    }()
    
    let lineView3: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        
        return view
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
        [progressImage, titleLabel, nameLabel, nameTF, lineView1,
         birthLabel, birthTF, lineView2,
        firstDayLabel, firstDayTF, lineView3, exLabel].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        progressConstraint()
        titleLabelConstraint()
        textFieldsConstraint()
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
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: progressImage.bottomAnchor, constant: 51),
        ])
    }
    
    private func textFieldsConstraint() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTF.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false

        birthLabel.translatesAutoresizingMaskIntoConstraints = false
        birthTF.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        
        firstDayLabel.translatesAutoresizingMaskIntoConstraints = false
        firstDayTF.translatesAutoresizingMaskIntoConstraints = false
        lineView3.translatesAutoresizingMaskIntoConstraints = false
        
        exLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //이름
            nameLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),

            nameTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTF.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            
            lineView1.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView1.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView1.topAnchor.constraint(equalTo: nameTF.bottomAnchor, constant: 9),
            lineView1.heightAnchor.constraint(equalToConstant: 1),
            
            //생일
            birthLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            birthLabel.topAnchor.constraint(equalTo: lineView1.bottomAnchor, constant: 34),

            birthTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            birthTF.topAnchor.constraint(equalTo: birthLabel.bottomAnchor, constant: 9),
            
            lineView2.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView2.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView2.topAnchor.constraint(equalTo: birthTF.bottomAnchor, constant: 9),
            lineView2.heightAnchor.constraint(equalToConstant: 1),
            
            //처음 만난 날
            firstDayLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            firstDayLabel.topAnchor.constraint(equalTo: lineView2.bottomAnchor, constant: 34),

            firstDayTF.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            firstDayTF.topAnchor.constraint(equalTo: firstDayLabel.bottomAnchor, constant: 9),
            
            lineView3.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            lineView3.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            lineView3.topAnchor.constraint(equalTo: firstDayTF.bottomAnchor, constant: 9),
            lineView3.heightAnchor.constraint(equalToConstant: 1),
            
            //설명
            exLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: lineView3.bottomAnchor, constant: 22),


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

