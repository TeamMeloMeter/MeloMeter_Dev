//
//  AuthModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/26.
//

import UIKit
//view에서 123 입력 -> vc에서 vo: model에 정의된 person1 new 생성 insertNameDao(소통모델): person 인자로 실행
//사용자 정보 모델 -> UUID, 위치정보모델, 채팅, 백문백답, 로그인 UUID 값 대입
//dto: data transform object 데이터 정의
//dao: data access object 데이터 사용 로직
// MARK: - 사용자 모델
struct UserInfoModel {
    
    var userCode1: String? = nil //내 초대 코드
    var uid1: String? = nil //내 uid
    var stateMessage: String? = nil //상태메세지
    
    var gender: String? = nil //성별
    var birth2: String? = nil
    var stateMessage2: String? = nil
    var uid2: String? = nil
    
    var firstDay: String? = nil
    //var profilePhoto: 클라우드 URL
    var phoneNumber: String? = nil //내 폰번호
    var verificationCode: String? = nil //인증번호
    var birth: String? = nil //생일
    init() {}
    
}


