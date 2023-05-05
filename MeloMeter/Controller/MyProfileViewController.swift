//
//  MyProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    let myProfileView = MyProfileView()
    
    //모델 사용자 정보 불러오기
    let myProfileModel = MyProfileModel(name: "김소희", phoneNum: "+82 010-5912-3921", stateMessage: "오늘은 기분 좋은 날 :)")
    
    override func loadView() {
        view = myProfileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarButton()
        setAlarmViewTouch()
        myProfileView.nameLabel.text = myProfileModel.name
        myProfileView.phoneNumLabel.text = myProfileModel.phoneNum
        myProfileView.stateMessageLabel.text = myProfileModel.stateMessage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    //네비게이션바 커스텀
    func setUpBarButton() {
        
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
        myProfileView.alarmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alarmViewTapped)))
        myProfileView.dDayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dDayViewTapped)))
        myProfileView.hundredQnAView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hundredQnAViewTapped)))
    }
    
    @objc func alarmViewTapped() {
        let alarmViewController = AlarmViewController()
        alarmViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
    @objc func dDayViewTapped() {
        let dDayViewController = DdayViewController()
        dDayViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(dDayViewController, animated: true)
        
    }
    @objc func hundredQnAViewTapped() {
        let alarmViewController = AlarmViewController()
        alarmViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmViewController, animated: true)
    }

}
