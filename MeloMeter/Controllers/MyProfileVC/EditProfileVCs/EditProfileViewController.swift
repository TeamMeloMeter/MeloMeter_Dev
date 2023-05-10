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

        //제스쳐 추가
        editProfileView.cameraButton.addTarget(self, action: #selector(showPhotoAlert), for: .touchUpInside)
        editProfileView.nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nameViewTapped)))
        editProfileView.stateMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.statusViewTapped)))
        editProfileView.birthDateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.birthDateLabelTapped)))
        editProfileView.userGenderLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showGenderAlert)))

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


