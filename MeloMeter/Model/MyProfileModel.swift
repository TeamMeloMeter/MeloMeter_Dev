//
//  MyProfileModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

// 마이페이지의 데이터 모델
class MyProfileModel {
    static let tableViewImg = ["noticeIcon", "qnaIcon", "infoIcon"]
    static let tableViewLabel = ["공지사항", "자주묻는 질문", "정보"]
    
    var name: String
    var phoneNum: String
    var stateMessage: String
    //var profileImage: UIImage
    
    init(name: String, phoneNum: String, stateMessage: String) {
        self.name = name
        self.phoneNum = phoneNum
        self.stateMessage = stateMessage
        //self.profileImage = profileImage
    }
    

}
