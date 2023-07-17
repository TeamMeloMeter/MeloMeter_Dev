//
//  CoupleInfoModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/03.
//

import Foundation
import Firebase
//  get set으로 캡슐화 하는 이유
//1. 일단은 변수별로 get 함수를 지정 -> 필요한 값만 조회한다.
//2. 외부에서 변수의 값을 변경 불가능하게 만들 수 있따.
//3. set()으로 변수 값 대입 -> 모든 코드에서 무결성을 보장한다.
//4. 변수마다 유효성 검사를 할 수 있따.

struct CoupleInfoModel {
    var _userName1: String?
    
    var userName1: String? {
        get {
            return _userName1
        }
        set(value) {
            _userName1 = value
        }
    }
}
