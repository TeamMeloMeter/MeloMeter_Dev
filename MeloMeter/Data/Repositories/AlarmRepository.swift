//
//  AlarmRepository.swift
//  MeloMeter
//
//  Created by LTS on 2023/10/01.
//

import Foundation
import FirebaseFirestore
import RxSwift
import RxRelay

class AlarmRepository: AlarmRepositoryP {
    
    var firebaseService: FireStoreService
    var disposeBag: DisposeBag
    
    init(firebaseService: FireStoreService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    //실시간으로 추가된 알림 목록 가져오기
    func getAlarm() -> Single<[AlarmDTO]> {
        return self.firebaseService.observer(collection: .Alarm, document: UserDefaults.standard.string(forKey: "uid") ?? "")
            .map { documentSnapshot in
                if let alarmList = documentSnapshot["alarmList"] as? [[String: Any]],  !alarmList.isEmpty{
                    return self.convertToAlarmDTOArray(from: alarmList)
                } else {
                    return []
                }
            }
            .asSingle()
    }
    
    //딕셔너리로 가져온 데이터 [DTO] 로 변환
    func convertToAlarmDTOArray(from dictionaries: [[String: Any]]) -> [AlarmDTO] {
        var alarmDTOArray: [AlarmDTO] = []
        
        for dictionary in dictionaries {
            if let body = dictionary["body"] as? String,
               let date = dictionary["date"] as? String,
               let title = dictionary["title"] as? String,
               let type = dictionary["type"] as? String
            {
                let alarmDTO = AlarmDTO(body: body, date: date, title: title, type: type)
                alarmDTOArray.append(alarmDTO)
            }
        }
        print("🟢2222",alarmDTOArray)
        return alarmDTOArray
    }
}
