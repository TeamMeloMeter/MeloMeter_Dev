//
//  MyProfileView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/29.
//

import UIKit

// 마이페이지 UI View
class MyProfileView: UIView {
    
    
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "topBackgroundColor")
        view.addSubview(nameLabel)
        view.addSubview(phoneNumLabel)
        view.addSubview(stateMessageView)
        view.addSubview(stateMessageLabel)
        view.addSubview(profileImageView)
        view.addSubview(profileEditButton)
        view.addSubview(stackView)
        return view
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.semiBold(ofSize: 20)
        return label
    }()
    
    let phoneNumLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .black
        return label
    }()
    private lazy var stateMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profileTest")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    let profileEditButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "profileEdit"), for: .normal)
        
        return button
    }()
    
    let alarmButton: UIButton = {
        let button = UIButton()
        let stackButtonTitleColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        button.backgroundColor = .white
        button.setImage(UIImage(named: "alarmIcon"), for: .normal)
        button.setTitle("D-7", for: .normal)
        button.set = "00님의 생일까지 7일이 남았어요"
        button.setTitleColor(stackButtonTitleColor, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 13)
        button.contentHorizontalAlignment = .left
    
        button.sizeToFit()

        return button
    }()
    
    let dDayButton: UIButton = {
        let button = UIButton()
        let stackButtonTitleColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        button.backgroundColor = .white
        button.setImage(UIImage(named: "calIcon"), for: .normal)
        button.setTitle("D-7", for: .normal)
        button.setTitleColor(stackButtonTitleColor, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 13)
        button.contentHorizontalAlignment = .left
        
        button.sizeToFit()

        return button
    }()
    
    let hundredQButton: UIButton = {
        let button = UIButton()
        let stackButtonTitleColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        button.backgroundColor = .white
        button.setImage(UIImage(named: "heartIcon"), for: .normal)
        button.setTitle("백문백답", for: .normal)
        button.setTitleColor(stackButtonTitleColor, for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 13)
        button.contentHorizontalAlignment = .left
       
        button.sizeToFit()

        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [alarmButton, dDayButton, hundredQButton])
        stview.spacing = 16
        stview.axis = .vertical
        stview.distribution = .fillEqually
        stview.alignment = .fill
        return stview
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
        nameLabelConstraint()
        phoneNumLabelConstraint()
        stateMessageViewConstraint()
        stateMessageLabelConstraint()
        profileImageViewConstraint()
        profileEditButtonConstraint()
        stackViewConstraints()
    }
    
    
    private func topViewConstraint() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 444)
           
        ])
    }
    
    private func nameLabelConstraint() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
       // nameLabel.font = fontManager.bold(ofSize: 14)

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -298),
            nameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 47),
            nameLabel.widthAnchor.constraint(equalToConstant: 52),
            nameLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func phoneNumLabelConstraint() {
        phoneNumLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
            phoneNumLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -239),
            phoneNumLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 70),
            phoneNumLabel.widthAnchor.constraint(equalToConstant: 111),
            phoneNumLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    private func stateMessageViewConstraint() {
        stateMessageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateMessageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 25),
            stateMessageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -202),
            stateMessageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 106),
            stateMessageView.widthAnchor.constraint(equalToConstant: 110),
            stateMessageView.heightAnchor.constraint(equalToConstant: 28)
           
        ])
    }
    
    private func stateMessageLabelConstraint() {
        stateMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateMessageLabel.leadingAnchor.constraint(equalTo: stateMessageView.leadingAnchor, constant: 0),
            stateMessageLabel.trailingAnchor.constraint(equalTo: stateMessageView.trailingAnchor, constant: 0),
            stateMessageLabel.topAnchor.constraint(equalTo: stateMessageView.topAnchor),
            stateMessageLabel.bottomAnchor.constraint(equalTo: stateMessageView.bottomAnchor),
            stateMessageLabel.widthAnchor.constraint(equalToConstant: 120),
            stateMessageLabel.heightAnchor.constraint(equalToConstant: 28)
            
            
        ])
    }
    
    private func profileImageViewConstraint() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 265),
            profileImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 43),
            profileImageView.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -310),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.heightAnchor.constraint(equalToConstant: 90)
            
            
        ])
    }
    
    private func profileEditButtonConstraint() {
        profileEditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileEditButton.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 69),
            profileEditButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            profileEditButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 66),
            profileEditButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 1),
            profileEditButton.widthAnchor.constraint(equalToConstant: 25),
            profileEditButton.heightAnchor.constraint(equalToConstant: 25)
            
            
        ])
    }
    
    private func stackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 171),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 236)
        ])
    }
}
