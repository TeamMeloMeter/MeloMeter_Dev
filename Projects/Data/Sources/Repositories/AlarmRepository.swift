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
#if canImport(Domain)
import Domain
#endif

public class AlarmRepository: AlarmRepositoryP {
    
    public var firebaseService: FirebaseService
    public var disposeBag: DisposeBag
    
    public init(firebaseService: FirebaseService) {
        self.firebaseService = firebaseService
        self.disposeBag = DisposeBag()
    }
    
    //실시간으로 추가된 알림 목록 가져오기
    public func getAlarm() -> Observable<[AlarmModel]> {
        return self.firebaseService.observer(collection: .Alarm, document: UserDefaults.standard.string(forKey: "uid") ?? "")
            .map { documentSnapshot -> [AlarmModel] in
                
                if let alarmList = documentSnapshot["alarmList"] as? [[String: Any]],  !alarmList.isEmpty{
                    
                    //300개 넘어가면 오래된 순으로 삭제
                    if alarmList.count > 200{
                        let values = Array(alarmList[1..<alarmList.count])
                        self.firebaseService.updateDocument(collection: .Alarm, document: UserDefaults.standard.string(forKey: "uid") ?? "", values: ["alarmList" : values] )
                            .subscribe(onSuccess: {})
                            .disposed(by: self.disposeBag)
                    }
                    return self.convertToAlarmModelArray(from: alarmList)
                } else {
                    return []
                }
            }
    }
    
    // 딕셔너리로 가져온 데이터 [Model] 로 변환
    private func convertToAlarmModelArray(from dictionaries: [[String: Any]]) -> [AlarmModel] {
        var alarmModelArray: [AlarmModel] = []
        
        for dictionary in dictionaries {
            if let text = dictionary["text"] as? String,
               let date = dictionary["date"] as? String,
               let type = dictionary["type"] as? String
            {
                let alarmDTO = AlarmDTO(text: text, date: date, type: type)
                alarmModelArray.append(alarmDTO.toModel())
            }
        }
        return alarmModelArray
    }
}
