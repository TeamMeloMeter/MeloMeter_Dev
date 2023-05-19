//
//  EditProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit
//프로필 편집
class EditProfileViewController: UIViewController {
    
    let editProfileView = EditProfileView()
    private var photoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private var genderAlert = UIAlertController(title: "성별", message: nil, preferredStyle: .actionSheet)

    override func loadView() {
        view = editProfileView
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createPhotoAlert()
        createGenderAlert()
        setEditViewTouch()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationBarCustom()
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
            self.editProfileView.userGenderLabel.text = "남"
        }
        let female = UIAlertAction(title: "여성", style: .default) { action in
            self.editProfileView.userGenderLabel.text = "여"
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        genderAlert.addAction(male)
        genderAlert.addAction(female)
        genderAlert.addAction(cancel)
    }
    
    func setEditViewTouch() {
        //터치 가능하도록 설정
        editProfileView.nameView.isUserInteractionEnabled = true
        editProfileView.stateMessageView.isUserInteractionEnabled = true
        editProfileView.birthDateLabel.isUserInteractionEnabled = true
        editProfileView.userGenderLabel.isUserInteractionEnabled = true
        editProfileView.disconnectLabel.isUserInteractionEnabled = true
        editProfileView.logoutLabel.isUserInteractionEnabled = true
        editProfileView.withdrawalLabel.isUserInteractionEnabled = true

        //제스쳐 추가
        editProfileView.cameraButton.addTarget(self, action: #selector(showPhotoAlert), for: .touchUpInside)
        editProfileView.nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nameViewTapped)))
        editProfileView.stateMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.statusViewTapped)))
        editProfileView.birthDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.birthDateLabelTapped)))
        editProfileView.userGenderLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGenderAlert)))
        editProfileView.disconnectLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(disconnectLabelTapped)))
        editProfileView.logoutLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLogoutAlert)))
        editProfileView.withdrawalLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(withdrawalLabelTapped)))

    }
    //사진 편집 alert 표시
    @objc func showPhotoAlert() {
        self.present(photoAlert, animated: true, completion: nil)
    }
    
    //이름편집 화면으로
    @objc func nameViewTapped() {
        let VC = EditNameViewController()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //상태메세지 편집 화면으로
    @objc func statusViewTapped() {
        let VC = EditStatusMessageVC()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //생일 편집 화면으로
    @objc func birthDateLabelTapped() {
        let VC = EditBirthViewController()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //성별 편집 alert 표시
    @objc func showGenderAlert() {
        self.present(genderAlert, animated: true, completion: nil)
    }
    
    
    //연결끊기 화면으로
    @objc func disconnectLabelTapped() {
        let VC = DisconnectVC()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //로그아웃 alert
    @objc func showLogoutAlert() {
        let alertController = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까? 추후 같은 아이디로\n로그인하면 상대방과 연결을 다시 진행할 수 있\n습니다.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            // 로그아웃 처리 로직을 여기에 작성
            // 예: 세션 종료, 사용자 정보 초기화 등
            self.logout()
        }
        alertController.addAction(logoutAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func logout() {
        // 로그아웃 처리 로직을 여기에 작성
        // 예: 세션 종료, 사용자 정보 초기화 등
        
        // 로그아웃 완료 후 필요한 동작 수행
        // 예: 홈 화면으로 이동, 로그인 화면 표시 등
    }
    
    @objc func withdrawalLabelTapped() {
        let VC = WithdrawalVC()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    private func navigationBarCustom() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "프로필 편집"
        navigationItem.rightBarButtonItem?.tintColor = .black
        let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func backButtonTapped() {
        // 네비게이션 pop 동작
        navigationController?.popViewController(animated: true)
    }
}


