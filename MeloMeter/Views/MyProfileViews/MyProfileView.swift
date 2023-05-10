//
//  MyProfileView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/29.
//

import UIKit

// 마이페이지 UI View
class MyProfileView: UIView {
    
    
    //마이페이지 상단 배경 뷰
     lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        view.addSubview(nameLabel)
        view.addSubview(phoneNumLabel)
        view.addSubview(stateMessageView)
        view.addSubview(stateMessageLabel)
        view.addSubview(profileImageView)
        view.addSubview(profileEditButton)
        view.addSubview(topStackView)
        
        return view
    }()
    
    // 사용자 이름
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.semiBold(ofSize: 20)
        return label
    }()
    
    // 사용자 전화번호
    let phoneNumLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .black
        return label
    }()
    
    // 상태메시지 View
    private lazy var stateMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    // 상태메시지 Label
    let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    //프로필사진
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
    //프로필 편집 버튼
    let profileEditButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "profileEdit"), for: .normal)
        
        return button
    }()
    
    // 알림
     lazy var alarmView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.shadowColor = #colorLiteral(red: 0.5137254902, green: 0.5058823529, blue: 0.5058823529, alpha: 0.1)
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 10
        view.addSubview(alarmTitleLabel)
        view.addSubview(alarmSubtitleLabel)
        view.addSubview(alarmImageView)
        return view
    }()
    
    let alarmTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "D-7"
        return label
    }()
    
    let alarmSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "00님의 생일까지 7일이 남았어요"
        return label
    }()
    
    let alarmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "alarmIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    //기념일
    lazy var dDayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.shadowColor = #colorLiteral(red: 0.5137254902, green: 0.5058823529, blue: 0.5058823529, alpha: 0.1)
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 10
        view.addSubview(dDayTitleLabel)
        view.addSubview(dDaySubtitleLabel)
        view.addSubview(dDayImageView)
        
        return view
    }()
    
    let dDayTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "00 & 00"
        return label
    }()
    
    let dDaySubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "1234일째 함께하는 중"
        return label
    }()
    
    let dDayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "calIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    //백문백답
    lazy var hundredQnAView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.shadowColor = #colorLiteral(red: 0.5137254902, green: 0.5058823529, blue: 0.5058823529, alpha: 0.1)
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 10
        view.addSubview(hundredQnATitleLabel)
        view.addSubview(hundredQnASubtitleLabel)
        view.addSubview(hundredQnAImageView)
        
        return view
    }()
    
    let hundredQnATitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "백문백답"
        return label
    }()
    
    let hundredQnASubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "1234번째 백문백답 완료!"
        return label
    }()
    
    let hundredQnAImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "heartIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    //상단 스택뷰 (알림, 기념일, 백문백답)
    private lazy var topStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [alarmView, dDayView, hundredQnAView])
        stview.spacing = 16
        stview.axis = .vertical
        stview.distribution = .fillEqually
        
        return stview
    }()
    //공지사항
    //공지사항 이미지
    let noticeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noticeIcon")
        imageView.contentMode = .left
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 24, height: 24)
        
        return imageView
    }()
    
    let noticeTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        label.text = "공지사항"
        return label
    }()
    
    //화살표 이미지
    let noticeArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowIcon")
        imageView.contentMode = .right
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 18, height: 18)
        return imageView
    }()
    
    lazy var noticeStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [noticeImageView, noticeTextLabel, noticeArrowImageView])
        stview.backgroundColor = .white
        stview.axis = .horizontal
        return stview
    }()
    
    //QnA 자주묻는질문
    //QnA 이미지
    let qnAImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "qAIcon")
        imageView.contentMode = .left
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 24, height: 24)
        
        return imageView
    }()
    
    let qnALabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        label.text = "자주묻는 질문"
        return label
    }()
    
    //화살표 이미지
    let qnAArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowIcon")
        imageView.contentMode = .right
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 18, height: 18)
        return imageView
    }()
    
    lazy var qnAStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [qnAImageView, qnALabel, qnAArrowImageView])
        stview.backgroundColor = .white
        stview.axis = .horizontal
        return stview
    }()
    
    //정보
    //정보이미지
    let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "infoIcon")
        imageView.contentMode = .left
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 24, height: 24)

        return imageView
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        label.text = "정보"
        return label
    }()
    
    //화살표 이미지
    let infoArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowIcon")
        imageView.contentMode = .right
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 18, height: 18)
        return imageView
    }()
    
    lazy var infoStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [infoImageView, infoLabel, infoArrowImageView])
        stview.backgroundColor = .white
        stview.axis = .horizontal
        
        return stview
    }()
    
    let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    
    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8797428012, green: 0.8797428012, blue: 0.8797428012, alpha: 1)
        return view
    }()
    
    //하단 스택뷰(공지사항, 자주묻는 질문, 정보, 구분선 포함)
    private lazy var bottomStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [noticeStackView, lineView1, qnAStackView, lineView2, infoStackView])
        stview.backgroundColor = .white
        stview.axis = .vertical
        //stview.distribution = .fillEqually
        stview.spacing = 16
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
        [topView, bottomStackView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        nameLabelConstraint()
        phoneNumLabelConstraint()
        stateMessageViewConstraint()
        stateMessageLabelConstraint()
        profileImageViewConstraint()
        profileEditButtonConstraint()
        alarmViewConstraints()
        dDayViewConstraints()
        hundredQnAViewConstraints()
        topStackViewConstraints()
        noticeConstraints()
        qnAConstraints()
        infoConstraints()
        bottomStackViewConstraints()
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
    
    
    //alarmView에 포함된 label, image Constraints
    private func alarmViewConstraints() {
        alarmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alarmTitleLabel.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 70),
            alarmTitleLabel.trailingAnchor.constraint(equalTo: alarmView.trailingAnchor, constant: -223),
            alarmTitleLabel.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 10),
            alarmTitleLabel.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: -30),
            alarmTitleLabel.widthAnchor.constraint(equalToConstant: 50),
            alarmTitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            alarmSubtitleLabel.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 70),
            alarmSubtitleLabel.trailingAnchor.constraint(equalTo: alarmView.trailingAnchor, constant: -85),
            alarmSubtitleLabel.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: -9),
            alarmSubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            alarmImageView.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 21),
            alarmImageView.trailingAnchor.constraint(equalTo: alarmSubtitleLabel.leadingAnchor, constant: -25),
            alarmImageView.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 24),
            alarmImageView.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: -20),
            alarmImageView.widthAnchor.constraint(equalToConstant: 24),
            alarmImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }

    private func dDayViewConstraints() {
        dDayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dDaySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dDayImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dDayTitleLabel.leadingAnchor.constraint(equalTo: dDayView.leadingAnchor, constant: 70),
            dDayTitleLabel.trailingAnchor.constraint(equalTo: dDayView.trailingAnchor, constant: -223),
            dDayTitleLabel.topAnchor.constraint(equalTo: dDayView.topAnchor, constant: 10),
            dDayTitleLabel.bottomAnchor.constraint(equalTo: dDayView.bottomAnchor, constant: -30),
            dDayTitleLabel.widthAnchor.constraint(equalToConstant: 50),
            dDayTitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            dDaySubtitleLabel.leadingAnchor.constraint(equalTo: dDayView.leadingAnchor, constant: 70),
            dDaySubtitleLabel.trailingAnchor.constraint(equalTo: dDayView.trailingAnchor, constant: -85),
            dDaySubtitleLabel.bottomAnchor.constraint(equalTo: dDayView.bottomAnchor, constant: -9),
            dDaySubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            dDayImageView.leadingAnchor.constraint(equalTo: dDayView.leadingAnchor, constant: 21),
            dDayImageView.trailingAnchor.constraint(equalTo: dDaySubtitleLabel.leadingAnchor, constant: -25),
            dDayImageView.topAnchor.constraint(equalTo: dDayView.topAnchor, constant: 24),
            dDayImageView.bottomAnchor.constraint(equalTo: dDayView.bottomAnchor, constant: -20),
            dDayImageView.widthAnchor.constraint(equalToConstant: 24),
            dDayImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }
    
    private func hundredQnAViewConstraints() {
        hundredQnATitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hundredQnASubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hundredQnAImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hundredQnATitleLabel.leadingAnchor.constraint(equalTo: hundredQnAView.leadingAnchor, constant: 70),
            hundredQnATitleLabel.trailingAnchor.constraint(equalTo: hundredQnAView.trailingAnchor, constant: -223),
            hundredQnATitleLabel.topAnchor.constraint(equalTo: hundredQnAView.topAnchor, constant: 10),
            hundredQnATitleLabel.bottomAnchor.constraint(equalTo: hundredQnAView.bottomAnchor, constant: -30),
            hundredQnATitleLabel.widthAnchor.constraint(equalToConstant: 50),
            hundredQnATitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            hundredQnASubtitleLabel.leadingAnchor.constraint(equalTo: hundredQnAView.leadingAnchor, constant: 70),
            hundredQnASubtitleLabel.trailingAnchor.constraint(equalTo: hundredQnAView.trailingAnchor, constant: -85),
            hundredQnASubtitleLabel.bottomAnchor.constraint(equalTo: hundredQnAView.bottomAnchor, constant: -9),
            hundredQnASubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            hundredQnAImageView.leadingAnchor.constraint(equalTo: hundredQnAView.leadingAnchor, constant: 21),
            hundredQnAImageView.trailingAnchor.constraint(equalTo: hundredQnASubtitleLabel.leadingAnchor, constant: -25),
            hundredQnAImageView.topAnchor.constraint(equalTo: hundredQnAView.topAnchor, constant: 24),
            hundredQnAImageView.bottomAnchor.constraint(equalTo: hundredQnAView.bottomAnchor, constant: -20),
            hundredQnAImageView.widthAnchor.constraint(equalToConstant: 24),
            hundredQnAImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }
    
    private func topStackViewConstraints() {
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topStackView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 171),
            topStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topStackView.heightAnchor.constraint(equalToConstant: 236)
        ])
    }
    private func noticeConstraints() {
        noticeImageView.translatesAutoresizingMaskIntoConstraints = false
        noticeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        noticeArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeImageView.leadingAnchor.constraint(equalTo: noticeStackView.leadingAnchor),
            noticeImageView.centerYAnchor.constraint(equalTo: noticeStackView.centerYAnchor),
            
            noticeTextLabel.leadingAnchor.constraint(equalTo: noticeImageView.leadingAnchor, constant: 44),
            noticeTextLabel.centerYAnchor.constraint(equalTo: noticeStackView.centerYAnchor),
            
            noticeArrowImageView.trailingAnchor.constraint(equalTo: noticeStackView.trailingAnchor),
            noticeArrowImageView.centerYAnchor.constraint(equalTo: noticeStackView.centerYAnchor),

        ])
    }

    
    private func qnAConstraints() {
        qnAImageView.translatesAutoresizingMaskIntoConstraints = false
        qnALabel.translatesAutoresizingMaskIntoConstraints = false
        qnAArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            qnAImageView.leadingAnchor.constraint(equalTo: qnAStackView.leadingAnchor),
            qnAImageView.centerYAnchor.constraint(equalTo: qnAStackView.centerYAnchor),
            
            qnALabel.leadingAnchor.constraint(equalTo: qnAStackView.leadingAnchor, constant: 44),
            qnALabel.centerYAnchor.constraint(equalTo: qnAStackView.centerYAnchor),
            
            qnAArrowImageView.trailingAnchor.constraint(equalTo: qnAStackView.trailingAnchor),
            qnAArrowImageView.centerYAnchor.constraint(equalTo: qnAStackView.centerYAnchor),

        ])
    }

    
    private func infoConstraints() {
        infoImageView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            infoImageView.leadingAnchor.constraint(equalTo: infoStackView.leadingAnchor),
            infoImageView.centerYAnchor.constraint(equalTo: infoStackView.centerYAnchor),
            
            infoLabel.leadingAnchor.constraint(equalTo: infoStackView.leadingAnchor, constant: 44),
            infoLabel.centerYAnchor.constraint(equalTo: infoStackView.centerYAnchor),
            
            infoArrowImageView.trailingAnchor.constraint(equalTo: infoStackView.trailingAnchor),
            infoArrowImageView.centerYAnchor.constraint(equalTo: infoStackView.centerYAnchor),

        ])
    }

    
    private func bottomStackViewConstraints() {
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        lineView1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([

            bottomStackView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 36),
            bottomStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 21),
            bottomStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -26),
            bottomStackView.widthAnchor.constraint(equalToConstant: 328),
            bottomStackView.heightAnchor.constraint(equalToConstant: 136),
            
            lineView1.topAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: 40),
            lineView1.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            lineView1.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor),
            lineView1.widthAnchor.constraint(equalToConstant: 343),
            lineView1.heightAnchor.constraint(equalToConstant: 0.5),
            
            lineView2.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: -40),
            lineView2.leadingAnchor.constraint(equalTo: bottomStackView.leadingAnchor),
            lineView2.trailingAnchor.constraint(equalTo: bottomStackView.trailingAnchor),
            lineView2.widthAnchor.constraint(equalToConstant: 343),
            lineView2.heightAnchor.constraint(equalToConstant: 0.5)

        ])
    }
}

