//
//  MyProfileViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    let myProfileView = MyProfileView()
    let myProfileModel = MyProfileModel(name: "김소희", phoneNum: "+82 010-5912-3921", stateMessage: "오늘은 기분 좋은 날 :)")
    let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: MyProfileViewController.self, action: nil) // title 부분 수정
        
   
    
    
    override func loadView() {
        view = myProfileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        backBarButtonItem.tintColor = .black
        
        self.navigationItem.backBarButtonItem = backBarButtonItem
        setAlarmViewTouch()
        // Set label text
        myProfileView.nameLabel.text = myProfileModel.name
        myProfileView.phoneNumLabel.text = myProfileModel.phoneNum
        myProfileView.stateMessageLabel.text = myProfileModel.stateMessage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    func setAlarmViewTouch() {
        //클릭 가능하도록 설정
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
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
    @objc func dDayViewTapped() {
        let dDayViewController = DdayViewController()
        navigationController?.pushViewController(dDayViewController, animated: true)
    }
    @objc func hundredQnAViewTapped() {
        let alarmViewController = AlarmViewController()
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
}
