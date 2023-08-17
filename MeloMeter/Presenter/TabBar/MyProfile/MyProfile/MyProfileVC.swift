//
//  MyProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class MyProfileVC: UIViewController {
    
    private let viewModel: MyProfileVM?
    let disposeBag = DisposeBag()
    
    init(viewModel: MyProfileVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: Binding
    func setBindings() {

        self.infoStackView.rx.tapGesture().when(.ended)
            .subscribe(onNext: {[weak self] _ in
                self?.showInfoAlert()
            })
            .disposed(by: disposeBag)
        
        let input = MyProfileVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            editProfileBtnTapEvent: self.profileEditButton.rx.tap
                .map({ _ in })
                .asObservable(),
            dDayViewTapEvent: self.dDayView.rx.tapGesture().when(.ended)
                .map({ _ in })
                .asObservable(),
            noticeViewTapEvent: self.noticeStackView.rx.tapGesture().when(.ended)
                .map({ _ in })
                .asObservable(),
            qnAViewTapEvent: self.qnAStackView.rx.tapGesture().when(.ended)
                .map({ _ in })
                .asObservable()
        )
            
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.profileImage
            .asDriver(onErrorJustReturn: UIImage(named: "defaultProfileImage"))
            .drive(onNext: { image in
                if let profileImage = image {
                    self.profileImageView.image = profileImage
                }else {
                    self.profileImageView.image = UIImage(named: "defaultProfileImage")
                }
            })
            .disposed(by: disposeBag)
        
        output.userName
            .asDriver(onErrorJustReturn: "이름")
            .drive(onNext: { [weak self] name in
                self?.nameLabel.text = name
            })
            .disposed(by: disposeBag)
        
        output.userPhoneNumber
            .asDriver(onErrorJustReturn: "+82 010-????-????")
            .drive(onNext: { [weak self] number in
                self?.phoneNumLabel.text = number
            })
            .disposed(by: disposeBag)
        
        output.stateMessage
            .asDriver(onErrorJustReturn: "상태메세지를 변경해보세요!")
            .drive(onNext: { [weak self] message in
                if let text = message {
                    self?.stateMessageLabel.textColor = .gray1
                    self?.stateMessageLabel.text = text
                }else {
                    self?.stateMessageLabel.textColor = .gray2
                    self?.stateMessageLabel.text = "상태메세지를 변경해보세요!"
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: configure
    func configure() {
        view.backgroundColor = .white
        [topView, nameLabel, phoneNumLabel, stateMessageView, stateMessageLabel, profileEditButton, topStackView,
         bottomStackView].forEach { view.addSubview($0) }
    }
    

    
    // MARK: Event
    func showInfoAlert() {
        AlertManager(viewController: self)
            .setTitle("정보")
            .setMessage("버전 정보: 1.0.0\nProduced by Team Melometer")
            .addActionConfirm("확인")
            .showCustomAlert()
    }
    
    // MARK: UI
    //마이페이지 상단 배경 뷰
    lazy var topView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "topView")
        view.addSubview(profileImageView)

        return view
    }()
    
    // 사용자 이름
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        return label
    }()
    
    // 사용자 전화번호
    let phoneNumLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 12)
        label.textColor = .gray1
        return label
    }()
    
    // 상태메시지 View
    private lazy var stateMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    // 상태메시지 Label
    let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        label.textAlignment = .center
        return label
    }()
    //프로필사진
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 45
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
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "D-7"
        return label
    }()
    
    let alarmSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
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
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "00 & 00"
        return label
    }()
    
    let dDaySubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
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
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 13)
        label.text = "백문백답"
        return label
    }()
    
    let hundredQnASubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "1234번째 백문백답 완료!"
        return label
    }()
    
    let hundredQnAImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hundredQA")
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
        label.textColor = .gray1
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
        label.textColor = .gray1
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
        label.textColor = .gray1
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
        view.backgroundColor = .gray45
        return view
    }()
    
    let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray45
        return view
    }()
    
    //하단 스택뷰(공지사항, 자주묻는 질문, 정보, 구분선 포함)
    private lazy var bottomStackView: UIStackView = {
        let stview = UIStackView(arrangedSubviews: [noticeStackView, lineView1, qnAStackView, lineView2, infoStackView])
        stview.backgroundColor = .white
        stview.axis = .vertical
        //stview.spacing = 16
        return stview
    }()
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        topViewConstraints()
        nameLabelConstraints()
        phoneNumLabelConstraints()
        stateMessageViewConstraints()
        stateMessageLabelConstraints()
        profileImageViewConstraints()
        profileEditButtonConstraints()
        alarmViewConstraints()
        dDayViewConstraints()
        hundredQnAViewConstraints()
        topStackViewConstraints()
        noticeConstraints()
        qnAConstraints()
        infoConstraints()
        bottomStackViewConstraints()
    }
    
    
    private func topViewConstraints() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 444)
           
        ])
    }
    
    private func nameLabelConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            nameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 47),
            nameLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
  
    private func phoneNumLabelConstraints() {
        phoneNumLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            phoneNumLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 70),
            phoneNumLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    private func stateMessageViewConstraints() {
        stateMessageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateMessageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            stateMessageView.trailingAnchor.constraint(equalTo: stateMessageLabel.trailingAnchor, constant: 19),
            stateMessageView.topAnchor.constraint(equalTo: stateMessageLabel.topAnchor, constant: -1),
            stateMessageView.bottomAnchor.constraint(equalTo: stateMessageLabel.bottomAnchor, constant: 1),
        ])
    }
    
    private func stateMessageLabelConstraints() {
        stateMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stateMessageLabel.leadingAnchor.constraint(equalTo: stateMessageView.leadingAnchor, constant: 19),
            stateMessageLabel.topAnchor.constraint(equalTo: phoneNumLabel.bottomAnchor, constant: 9),
            stateMessageLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func profileImageViewConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            profileImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 43),
            profileImageView.widthAnchor.constraint(equalToConstant: 90),
            profileImageView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func profileEditButtonConstraints() {
        profileEditButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileEditButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 4),
            profileEditButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            profileEditButton.widthAnchor.constraint(equalToConstant: 26),
            profileEditButton.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    
    //alarmView에 포함된 label, image Constraints
    private func alarmViewConstraints() {
        alarmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alarmTitleLabel.leadingAnchor.constraint(equalTo: alarmImageView.trailingAnchor, constant: 21),
            alarmTitleLabel.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 10),
            alarmTitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            alarmSubtitleLabel.leadingAnchor.constraint(equalTo: alarmImageView.trailingAnchor, constant: 21),
            alarmSubtitleLabel.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: -9),
            alarmSubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            alarmImageView.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 25),
            alarmImageView.centerYAnchor.constraint(equalTo: alarmView.centerYAnchor),
            alarmImageView.widthAnchor.constraint(equalToConstant: 24),
            alarmImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }

    private func dDayViewConstraints() {
        dDayTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dDaySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dDayImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dDayTitleLabel.leadingAnchor.constraint(equalTo: dDayImageView.trailingAnchor, constant: 21),
            dDayTitleLabel.topAnchor.constraint(equalTo: dDayView.topAnchor, constant: 10),
            dDayTitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            dDaySubtitleLabel.leadingAnchor.constraint(equalTo: dDayImageView.trailingAnchor, constant: 21),
            dDaySubtitleLabel.bottomAnchor.constraint(equalTo: dDayView.bottomAnchor, constant: -9),
            dDaySubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            dDayImageView.leadingAnchor.constraint(equalTo: dDayView.leadingAnchor, constant: 25),
            dDayImageView.centerYAnchor.constraint(equalTo: dDayView.centerYAnchor),
            dDayImageView.widthAnchor.constraint(equalToConstant: 24),
            dDayImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }
    
    private func hundredQnAViewConstraints() {
        hundredQnATitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hundredQnASubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hundredQnAImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hundredQnATitleLabel.leadingAnchor.constraint(equalTo: hundredQnAImageView.trailingAnchor, constant: 21),
            hundredQnATitleLabel.topAnchor.constraint(equalTo: hundredQnAView.topAnchor, constant: 10),
            hundredQnATitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            hundredQnASubtitleLabel.leadingAnchor.constraint(equalTo: hundredQnAImageView.trailingAnchor, constant: 21),
            hundredQnASubtitleLabel.bottomAnchor.constraint(equalTo: hundredQnAView.bottomAnchor, constant: -9),
            hundredQnASubtitleLabel.heightAnchor.constraint(equalToConstant: 28),
            
            hundredQnAImageView.leadingAnchor.constraint(equalTo: hundredQnAView.leadingAnchor, constant: 25),
            hundredQnAImageView.centerYAnchor.constraint(equalTo: hundredQnAView.centerYAnchor),
            hundredQnAImageView.widthAnchor.constraint(equalToConstant: 24),
            hundredQnAImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }
    
    private func topStackViewConstraints() {
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            topStackView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 171),
            topStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
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

            bottomStackView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 29),
            bottomStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bottomStackView.widthAnchor.constraint(equalToConstant: 343),
            bottomStackView.heightAnchor.constraint(equalToConstant: 168),
            
            lineView1.topAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: 56),
            lineView1.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor),
            lineView1.heightAnchor.constraint(equalToConstant: 1),
            
            lineView2.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: -56),
            lineView2.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor),
            lineView2.heightAnchor.constraint(equalToConstant: 1)

        ])
    }
}
