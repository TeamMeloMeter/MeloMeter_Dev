//
//  PushNotificationService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/24.
//

import Foundation
import UserNotifications
final class PushNotificationService {
    static let shared = PushNotificationService()
//    private var token: String?
    //    private var title: String?
    //    private var body: String?
    
    private init() {}
    
    func sendPushNotification(title: String, body: String) {
        let message = [
            "to": UserDefaults.standard.string(forKey: "otherFcmToken") ?? "",
            "notification": [
                "title": title,
                "body": body
            ]
        ] as [String : Any]
        
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
}
