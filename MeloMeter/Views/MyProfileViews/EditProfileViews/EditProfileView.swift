//
//  EditProfileView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class EditProfileView: UIView {
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        
        view.addSubview(profileImageView)
        view.addSubview(cameraButton)
        view.addSubview(nameLabel)
        view.addSubview(nameView)
        view.addSubview(stateMessageLabel)
        view.addSubview(stateMessageView)
        view.addSubview(birthGenderView)
        view.addSubview(bottomView)
        return view
    }()
    
    let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "profileTest")
            imageView.contentMode = .scaleAspectFit
            imageView.layer.borderColor = UIColor.clear.cgColor
            return imageView
        }()
    
    let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cameraIcon"), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        return label
    }()
    
    lazy var nameView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(userNameLabel)
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김소희"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "상태메세지"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        return label
    }()
    
    lazy var stateMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(userStateMessageLabel)
        return view
    }()
    
    let userStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘은 기분좋은 날:)"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    lazy var birthGenderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(birthLabel)
        view.addSubview(birthDateLabel)
        view.addSubview(lineView1)
        view.addSubview(genderLabel)
        view.addSubview(userGenderLabel)
        return view
    }()
    
    let birthLabel: UILabel = {
        let label = UILabel()
        label.text = "생일"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let birthDateLabel: UILabel = {
        let label = UILabel()
        label.text = "1998.03.10"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    
    let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    let userGenderLabel: UILabel = {
        let label = UILabel()
        label.text = "남"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(disconnectLabel)
        view.addSubview(lineView2)
        view.addSubview(logoutLabel)
        view.addSubview(lineView3)
        view.addSubview(withdrawalLabel)
        return view
    }()
    
    let disconnectLabel: UILabel = {
        let label = UILabel()
        label.text = "상대방과 연결 끊기"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    private let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    let logoutLabel: UILabel = {
        let label = UILabel()
        label.text = "로그아웃"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let lineView3: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    
    let withdrawalLabel: UILabel = {
        let label = UILabel()
        label.text = "회원탈퇴"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        setConstraints()
        
    }
    
    func setup() {
        backgroundColor = .white
    }
    
    func addViews() {
        [topView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        profileImageViewConstraint()
        cameraButtonConstraint()
        nameStateMessageConstraint()
        birthGenderConstraint()
        bottomViewConstraint()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    private func profileImageViewConstraint() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 37),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 118),
            profileImageView.heightAnchor.constraint(equalToConstant: 118),
        ])
    }
    
    private func cameraButtonConstraint() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 84),
            cameraButton.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 91),
            cameraButton.widthAnchor.constraint(equalToConstant: 35),
            cameraButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func nameStateMessageConstraint() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameView.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        stateMessageView.translatesAutoresizingMaskIntoConstraints = false
        stateMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        userStateMessageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 185),
            
            nameView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            nameView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 17),
            nameView.widthAnchor.constraint(equalToConstant: 343),
            nameView.heightAnchor.constraint(equalToConstant: 46),
            
            userNameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor, constant: 11),
            userNameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            stateMessageLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            stateMessageLabel.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 22),
            
            stateMessageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            stateMessageView.topAnchor.constraint(equalTo: stateMessageLabel.bottomAnchor, constant: 17),
            stateMessageView.widthAnchor.constraint(equalToConstant: 343),
            stateMessageView.heightAnchor.constraint(equalToConstant: 46),

            userStateMessageLabel.leadingAnchor.constraint(equalTo: stateMessageView.leadingAnchor, constant: 11),
            userStateMessageLabel.centerYAnchor.constraint(equalTo: stateMessageView.centerYAnchor),
        ])
    }
    
    private func birthGenderConstraint() {
        birthGenderView.translatesAutoresizingMaskIntoConstraints = false
        birthLabel.translatesAutoresizingMaskIntoConstraints = false
        birthDateLabel.translatesAutoresizingMaskIntoConstraints = false
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        userGenderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            birthGenderView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            birthGenderView.topAnchor.constraint(equalTo: stateMessageView.bottomAnchor, constant: 36),
            birthGenderView.widthAnchor.constraint(equalToConstant: 343),
            birthGenderView.heightAnchor.constraint(equalToConstant: 88),
            
            birthLabel.leadingAnchor.constraint(equalTo: birthGenderView.leadingAnchor, constant: 11),
            birthLabel.topAnchor.constraint(equalTo: birthGenderView.topAnchor, constant: 14),
            
            birthDateLabel.trailingAnchor.constraint(equalTo: birthGenderView.trailingAnchor, constant: -11),
            birthDateLabel.topAnchor.constraint(equalTo: birthGenderView.topAnchor, constant: 14),
            birthDateLabel.widthAnchor.constraint(equalToConstant: 100),
            
            lineView1.centerXAnchor.constraint(equalTo: birthGenderView.centerXAnchor),
            lineView1.centerYAnchor.constraint(equalTo: birthGenderView.centerYAnchor),
            lineView1.widthAnchor.constraint(equalToConstant: 321),
            lineView1.heightAnchor.constraint(equalToConstant: 0.5),
            
            genderLabel.leadingAnchor.constraint(equalTo: birthGenderView.leadingAnchor, constant: 11),
            genderLabel.bottomAnchor.constraint(equalTo: birthGenderView.bottomAnchor, constant: -13),
            
            userGenderLabel.trailingAnchor.constraint(equalTo: birthGenderView.trailingAnchor, constant: -11),
            userGenderLabel.bottomAnchor.constraint(equalTo: birthGenderView.bottomAnchor, constant: -14),
            userGenderLabel.widthAnchor.constraint(equalToConstant: 87)


        ])
    }
    
    private func bottomViewConstraint() {
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        disconnectLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView2.translatesAutoresizingMaskIntoConstraints = false
        logoutLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView3.translatesAutoresizingMaskIntoConstraints = false
        withdrawalLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomView.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            bottomView.topAnchor.constraint(equalTo: birthGenderView.bottomAnchor, constant: 36),
            bottomView.widthAnchor.constraint(equalToConstant: 343),
            bottomView.heightAnchor.constraint(equalToConstant: 132),
            
            disconnectLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 11),
            disconnectLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 14),
            
            lineView2.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            lineView2.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 44),
            lineView2.widthAnchor.constraint(equalToConstant: 321),
            lineView2.heightAnchor.constraint(equalToConstant: 0.5),
            
            logoutLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 11),
            logoutLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            
            lineView3.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            lineView3.topAnchor.constraint(equalTo: lineView2.topAnchor, constant: 44),
            lineView3.widthAnchor.constraint(equalToConstant: 321),
            lineView3.heightAnchor.constraint(equalToConstant: 0.5),
            
            withdrawalLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 11),
            withdrawalLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -13),
            


        ])
    }
    
}
