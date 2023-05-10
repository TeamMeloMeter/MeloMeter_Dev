//
//  MyProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

class MyProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let myProfileView = MyProfileView()
    
    //모델 사용자 정보 불러오기
    let myProfileModel = MyProfileModel(name: "김소희", phoneNum: "+82 010-5912-3921", stateMessage: "오늘은 기분 좋은 날 :)")
    
    override func loadView() {
        view = myProfileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAlarmViewTouch()
        myProfileView.nameLabel.text = myProfileModel.name
        myProfileView.phoneNumLabel.text = myProfileModel.phoneNum
        myProfileView.stateMessageLabel.text = myProfileModel.stateMessage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
        setUpBarButton()
    }
    //네비게이션바 커스텀
    func setUpBarButton() {
        //스와이프 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        //타이틀 속성 조정 - 폰트, 배경
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // 뷰 터치 설정
    func setAlarmViewTouch() {
        //터치 가능하도록 설정
        myProfileView.alarmView.isUserInteractionEnabled = true
        myProfileView.dDayView.isUserInteractionEnabled = true
        myProfileView.hundredQnAView.isUserInteractionEnabled = true
        myProfileView.noticeStackView.isUserInteractionEnabled = true
        myProfileView.qnAStackView.isUserInteractionEnabled = true
        myProfileView.infoStackView.isUserInteractionEnabled = true
        
        //제스쳐 추가
        myProfileView.profileEditButton.addTarget(self, action: #selector(editProfileBtnTapped), for: .touchUpInside)
        myProfileView.alarmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alarmViewTapped)))
        myProfileView.dDayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dDayViewTapped)))
        myProfileView.hundredQnAView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hundredQnAViewTapped)))
        myProfileView.noticeStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.noticeViewTapped)))
        myProfileView.qnAStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.qnAViewTapped)))
        
    }
    
    //프로필편집 화면으로
    @objc func editProfileBtnTapped(){
        let editProfileVC = EditProfileViewController()
        editProfileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    //알림 화면으로
    @objc func alarmViewTapped() {
        let alarmViewController = AlarmViewController()
        alarmViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
    //기념일 화면으로
    @objc func dDayViewTapped() {
        let dDayViewController = DdayViewController()
        dDayViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(dDayViewController, animated: true)
        
    }
    
    //백문백답 화면으로 - 임시
    @objc func hundredQnAViewTapped() {
        let alarmViewController = AlarmViewController()
        alarmViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
    
    // 공지사항 화면으로
    @objc func noticeViewTapped() {
        let noticeViewController = NoticeViewController()
        noticeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(noticeViewController, animated: true)
    }
    
    // 자주묻는 질문 화면으로
    @objc func qnAViewTapped() {
        let qnAViewController = QnAViewController()
        qnAViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(qnAViewController, animated: true)
    }
}
