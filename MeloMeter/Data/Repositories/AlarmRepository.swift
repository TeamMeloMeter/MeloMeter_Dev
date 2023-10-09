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
    func getAlarm() -> Observable<[AlarmDTO]> {
        return self.firebaseService.observer(collection: .Alarm, document: UserDefaults.standard.string(forKey: "uid") ?? "")
            .map { documentSnapshot -> [AlarmDTO] in
                
                if let alarmList = documentSnapshot["alarmList"] as? [[String: Any]],  !alarmList.isEmpty{
                    
                    //300개 넘어가면 오래된 순으로 삭제
                    if alarmList.count > 200{
                        let values = Array(alarmList[1..<alarmList.count])
                        self.firebaseService.updateDocument(collection: .Alarm, document: UserDefaults.standard.string(forKey: "uid") ?? "", values: ["alarmList" : values] )
                            .subscribe(onSuccess: {})
                            .disposed(by: self.disposeBag)
                    }
                    return self.convertToAlarmDTOArray(from: alarmList)
                } else {
                    return []
                }
            }
    }
    
    //딕셔너리로 가져온 데이터 [DTO] 로 변환
    func convertToAlarmDTOArray(from dictionaries: [[String: Any]]) -> [AlarmDTO] {
        var alarmDTOArray: [AlarmDTO] = []
        
        for dictionary in dictionaries {
            if let text = dictionary["text"] as? String,
               let date = dictionary["date"] as? String,
               let type = dictionary["type"] as? String
            {
                let alarmDTO = AlarmDTO(text: text, date: date, type: type)
                alarmDTOArray.append(alarmDTO)
            }
        }
        return alarmDTOArray
    }
}
