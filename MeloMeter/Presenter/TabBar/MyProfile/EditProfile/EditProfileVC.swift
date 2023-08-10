//
//  EditProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
import RxSwift
import RxCocoa

class EditProfileVC: UIViewController {
    
    private var photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private var genderAlert = UIAlertController(title: "성별", message: nil, preferredStyle: .actionSheet)
    
    private let viewModel: EditProfileVM?
    private let disposeBag = DisposeBag()
    let tapDdayGesture = UITapGestureRecognizer()
    
    init(viewModel: EditProfileVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar()
    }
    
    func setBindings() {
        let input = EditProfileVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            backBtnTapEvent: self.backBarButton.rx.tap
                .map({ _ in })
                .asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else{ return }
        
        output.userName
            .bind(onNext: {[weak self] name in
                print("이름",name)
                self?.userNameLabel.text = name
            })
            .disposed(by: disposeBag)
        
        output.stateMessage
            .bind(onNext: {[weak self] stateMessage in
                self?.userStateMessageLabel.text = stateMessage
            })
            .disposed(by: disposeBag)
        
        output.birth
            .bind(onNext: {[weak self] birth in
                self?.birthDateLabel.text = birth
            })
            .disposed(by: disposeBag)
        
//        output.gender
//            .bind(onNext: {[weak self] gender in
//                self?.userNameLabel.text = gender
//            })
//            .disposed(by: disposeBag)
        
    }
    
    //프사 편집 alert 생성
    func createPhotoAlert() {
        
        let takePhoto = UIAlertAction(title: "사진찍기", style: .default) { action in
            // alert 터치이벤트
//            let cameraViewController = CameraViewController()
//            cameraViewController.cameraModel.launchCamera()
        }
        let selectPhoto = UIAlertAction(title: "앨범에서 선택하기", style: .default, handler: nil)
        let deleteProfile = UIAlertAction(title: "프로필 사진 지우기", style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        photoAlert.addAction(takePhoto)
        photoAlert.addAction(selectPhoto)
        photoAlert.addAction(deleteProfile)
        photoAlert.addAction(cancel)
    }
    
    //성별 편집 alert 생성
    func createGenderAlert() {
        
        let male = UIAlertAction(title: "남성", style: .default) { action in
            self.userGenderLabel.text = "남"
        }
        let female = UIAlertAction(title: "여성", style: .default) { action in
            self.userGenderLabel.text = "여"
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        genderAlert.addAction(male)
        genderAlert.addAction(female)
        genderAlert.addAction(cancel)
    }
    
//    //사진 편집 alert 표시
//    @objc func showPhotoAlert() {
//        self.present(photoAlert, animated: true, completion: nil)
//    }

//
//    //성별 편집 alert 표시
//    @objc func showGenderAlert() {
//        self.present(genderAlert, animated: true, completion: nil)
//    }
//
//

//
//    //로그아웃 alert
//    @objc func showLogoutAlert() {
//        let alertController = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까? 추후 같은 아이디로\n로그인하면 상대방과 연결을 다시 진행할 수 있\n습니다.", preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//
//        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
//            // 로그아웃 처리 로직을 여기에 작성
//            // 예: 세션 종료, 사용자 정보 초기화 등
//            self.logout()
//        }
//        alertController.addAction(logoutAction)
//
//        present(alertController, animated: true, completion: nil)
//    }

    func logout() {
        // 로그아웃 처리 로직을 여기에 작성
        // 예: 세션 종료, 사용자 정보 초기화 등
        
        // 로그아웃 완료 후 필요한 동작 수행
        // 예: 홈 화면으로 이동, 로그인 화면 표시 등
    }
    
    
    // MARK: NavigationBar
    private func setNavigationBar() {
        navigationItem.title = "프로필 편집"
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    private lazy var backBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "backIcon"),
                                     style: .plain,
                                     target: self,
                                     action: nil)
        return button
    }()

    
    // MARK: UI
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
        label.textColor = .gray2
        return label
    }()
    
    lazy var nameView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(userNameLabel)
        return view
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김소희"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private let stateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "상태메세지"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray2
        return label
    }()
    
    lazy var stateMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.addSubview(userStateMessageLabel)
        return view
    }()
    
    let userStateMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘은 기분좋은 날:)"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    lazy var birthGenderView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
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
        label.textColor = .gray1
        return label
    }()
    
    let birthDateLabel: UILabel = {
        let label = UILabel()
        label.text = "1998.03.10"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        label.textAlignment = .right
        return label
    }()
    
    private let lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = .gray4
        return view
    }()
    
    let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    let userGenderLabel: UILabel = {
        let label = UILabel()
        label.text = "남"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        label.textAlignment = .right
        return label
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
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
        label.textColor = .gray1
        return label
    }()
    private let lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = .gray4
        return view
    }()
    let logoutLabel: UILabel = {
        let label = UILabel()
        label.text = "로그아웃"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        return label
    }()
    
    private let lineView3: UIView = {
        let view = UIView()
        view.backgroundColor = .gray4
        return view
    }()
    
    let withdrawalLabel: UILabel = {
        let label = UILabel()
        label.text = "회원탈퇴"
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textColor = .gray1
        return label
    }()


    func configure() {
        view.backgroundColor = .white
        [profileImageView,
         cameraButton,
         nameLabel,
         nameView,
         stateMessageLabel,
         stateMessageView,
         birthGenderView,
         bottomView].forEach { view.addSubview($0) }
    }
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        profileImageViewConstraint()
        cameraButtonConstraint()
        nameStateMessageConstraint()
        birthGenderConstraint()
        bottomViewConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func profileImageViewConstraint() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 37),
            profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 118),
            profileImageView.heightAnchor.constraint(equalToConstant: 118),
        ])
    }
    
    private func cameraButtonConstraint() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 84),
            cameraButton.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: 91),
            cameraButton.widthAnchor.constraint(equalToConstant: 34),
            cameraButton.heightAnchor.constraint(equalToConstant: 34)
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
            nameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 185),
            
            nameView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            nameView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 17),
            nameView.widthAnchor.constraint(equalToConstant: 343),
            nameView.heightAnchor.constraint(equalToConstant: 46),
            
            userNameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor, constant: 11),
            userNameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            stateMessageLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stateMessageLabel.topAnchor.constraint(equalTo: nameView.bottomAnchor, constant: 22),
            
            stateMessageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
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
            birthGenderView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
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
            bottomView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
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


