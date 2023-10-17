//
//  PushNotificationService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/24.
//
import Foundation
import UserNotifications
import FirebaseFirestore
import UIKit
import RxSwift
import UserNotifications

enum AlarmType: String{
    case defaultValue, yearAnni, hundredAnni, customAnni, hundredQA, birthDay, profile
    
    var stringType: String {
        // rawValue -> 원시타입으로 변경해주는 역할
        return self.rawValue
    }
}

final class PushNotificationService {
    static let shared = PushNotificationService()
    let firebaseService = DefaultFirebaseService()
    var disposeBag = DisposeBag()
    
    private init() {}
    
    func sendPushNotification(title: String, body: String, type: AlarmType) {
        let message = [
            "to": UserDefaults.standard.string(forKey: "otherFcmToken") ?? "",
            "content_available": true,
            "notification": [
                "badge": 1,
                "title": title,
                "body": body
            ],
            "data" : [
                "type" : type.stringType,
              ]
        ] as [String : Any]
        
            //사일런트 푸시
//              "to": UserDefaults.standard.string(forKey: "otherFcmToken") ?? "",
//              "content_available": true,
//              "apns-push-type": "background",
//              "apns-priority": 5,
//              "data": [
//                "title": title,
//                "date" : "\(Date())",
//                "body": body
//              ]
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAjeFoI_I:APA91bGvnP4wgl3VQtbw6-QBGJ2cam87ZW0B7elXX7vqMtvK-xA88vJWXWorFdVF3SUdgSJZ8TlvidzrmkNqeQLz1TBvtezNw6p_Bpvo4ccufJztB9STZq8PxWWig7akBeJZ-flebXyK", forHTTPHeaderField: "Authorization") // Replace with your server key
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        } catch let error {
            print("Error creating push notification: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: \(error.localizedDescription)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Push notification sent successfully, response: \(responseString ?? "")")
            }
        }
        
        task.resume()
    }
    
    func localPushNotification(title: String, body: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == UNAuthorizationStatus.authorized{
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default
                
                //트리거 생성
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: "dipose", content: content, trigger: trigger)
                
                //발송을 위한 센터에 추가
                UNUserNotificationCenter.current().add(request)
                
            }else{
                print("알림 거부")
            }
        }
    }
    
    //받은 알람을 자신의 데이터베이스에 추가
    func addAlarm(text: String, date: String, type: String) -> Void {
        
        guard let uid = UserDefaults.standard.string(forKey: "uid") else { return }
        
        let values = [
            "text" : text,
            "date" : date,
            "type" : type
        ]
        if type != "defaultValue" {
            self.firebaseService.updateDocument(collection: .Alarm, document: uid, values: ["alarmList" : FieldValue.arrayUnion([values]) ])
                .subscribe(onSuccess: { _ in })
                .disposed(by: disposeBag)
        }
    }
    
    func addRepeatAlarm(_ dataArray: [DdayCellData],_ firstDay: Date) {
        //한명이 생일을 입력하지 않았을 때 예외처리
        guard dataArray.count >= 2 else { return }
        
        //반복 알림 추가
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        
        // 알림 콘텐츠 생성
        let content = UNMutableNotificationContent()
        // 반복 설정
        let calendar = Calendar.current
        var dateComponents = DateComponents()
         
        //기념일 처리
        for i in 2..<dataArray.count{

            //지난 기념을은 continue 처리
            let comparisonResult = calendar.compare(dataArray[i].date, to: Date(), toGranularity: .day)
            if comparisonResult == .orderedAscending { // 오늘 이전의 날짜
                continue
            }
            
            let repeatDay = [-1, 0]
            for item in repeatDay{
                guard let b_date = calendar.date(byAdding: .day, value: item, to: dataArray[i].date ) else{ return }
                let components = calendar.dateComponents([.year, .month, .day], from: b_date)
                
                content.title = "MeloMeter"
                if item == -1 { content.body = "\(dataArray[i].dateName)까지 하루 전이에요" }
                else if item == 0 { content.body = "오늘의 이벤트는 \(dataArray[i].dateName) 입니다!" }
                content.sound = UNNotificationSound.default
                content.userInfo = ["type": AlarmType.customAnni.stringType]
                
                dateComponents.year = components.year
                dateComponents.month = components.month
                dateComponents.day = components.day
                dateComponents.hour = 10
                dateComponents.minute = 1
            
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                // 알림 요청 생성, 등록
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
        
        //생일 처리
        for i in 0..<2{
            let title = dataArray[i].dateName.prefix(dataArray[i].dateName.count - 3)
            
            let repeatDay = [-7, -1, 0]
            for item in repeatDay{
                guard let b_date = calendar.date(byAdding: .day, value: item, to: dataArray[i].date ) else{ return }
                let components = calendar.dateComponents([.month, .day], from: b_date)
                
                content.title = "MeloMeter"
                if item == -7 { content.body = "\(title)님의 생일까지 7일 남았어요" }
                else if item == -1 { content.body = "\(title)님의 생일까지 하루 전이에요" }
                else if item == 0 { content.body = "오늘은 \(title)님의 생일입니다. 축하해요!" }
                content.sound = UNNotificationSound.default
                content.userInfo = ["type": AlarmType.birthDay.stringType]
                
                dateComponents.year = components.year
                dateComponents.month = components.month
                dateComponents.day = components.day
                dateComponents.hour = 10
                dateComponents.minute = 1

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                // 알림 요청 생성, 등록
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
        
        //100일 단위 처리
        var cnt = 0
        
        for i in stride(from: 100, to: 10001, by: 100) {
            let repeatDay = [-1, 0]
            for item in repeatDay{
                guard let hundred_date = calendar.date(byAdding: .day, value: item + i - 1, to: firstDay ) else{ return }
                let components = calendar.dateComponents([.year, .month, .day], from: hundred_date)
                
                //지난 기념을은 continue 처리
                let comparisonResult = calendar.compare(hundred_date, to: Date(), toGranularity: .day)
                if comparisonResult == .orderedAscending { // 오늘 이전의 날짜
                    continue
                }
                
                content.title = "MeloMeter"
                if item == -1 { content.body = "\(i)일 까지 하루 전이에요" }
                else if item == 0 { content.body = "오늘은 \(i)일 기념일 입니다!" }
                content.sound = UNNotificationSound.default
                content.userInfo = ["type": AlarmType.hundredAnni.stringType]
                
                dateComponents.year = components.year
                dateComponents.month = components.month
                dateComponents.day = components.day
                dateComponents.hour = 10
                dateComponents.minute = 1
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                // 알림 요청 생성, 등록
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
                cnt += 1
            }
            
            if cnt == 6 { break }
        }
        
        //주년 단위 처리
        cnt = 0
        
        for i in stride(from: 1, to: 51, by: 1) {
            let repeatDay = [-1, 0]
            for item in repeatDay{
                guard let year_date = calendar.date(byAdding: .year, value: i, to: firstDay ) else{ return }
                guard let p_year_date = calendar.date(byAdding: .day, value: item, to: year_date ) else{ return }
                let components = calendar.dateComponents([.year, .month, .day], from: p_year_date)

                //지난 기념을은 continue 처리
                let comparisonResult = calendar.compare(p_year_date, to: Date(), toGranularity: .day)
                if comparisonResult == .orderedAscending { // 오늘 이전의 날짜
                    continue
                }
                
                content.title = "MeloMeter"
                if item == -1 { content.body = "\(i)주년 까지 하루 전이에요" }
                else if item == 0 { content.body = "오늘은 \(i)주년 기념일 입니다!" }
                content.sound = UNNotificationSound.default
                content.userInfo = ["type": AlarmType.yearAnni.stringType]
                
                dateComponents.year = components.year
                dateComponents.month = components.month
                dateComponents.day = components.day
                dateComponents.hour = 10
                dateComponents.minute = 1
            
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
                cnt += 1
            }
            
            if cnt == 2 { break }
        }
        
    }
    
    func compareDates(date: Date) -> Bool {
        let calendar = Calendar.current
        
        //오늘날짜
        let today = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        guard let todayYear = today.year,
              let todayMonth = today.month,
              let todayDay = today.day
        else{ return false }
        //비교대상
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        guard let componentsYear = components.year,
              let componentsMonth = components.month,
              let componentsDay = components.day
        else{ return false }
        
        //  2023.5.13      =     2022.7.19
        
        if todayYear < componentsYear {
                return true
            }else if todayYear == componentsYear && todayMonth < componentsMonth {
                return true
            }else if todayYear == componentsYear && todayMonth == componentsMonth && todayDay < componentsDay {
                return true
            }
        
        return false
    }

    
}
