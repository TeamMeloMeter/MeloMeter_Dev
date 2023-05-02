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
    @objc func alarmViewTapped() {
        let alarmViewController = AlarmViewController()
        navigationController?.pushViewController(alarmViewController, animated: true)
    }
    
    func setAlarmViewTouch() {
        //어떤 버튼 눌렸는지 구분하기 위함
        myProfileView.alarmView.tag = 1004
        //클릭 가능하도록 설정
        myProfileView.alarmView.isUserInteractionEnabled = true
        //제쳐스 추가
        myProfileView.alarmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alarmViewTapped)))
    }
}
