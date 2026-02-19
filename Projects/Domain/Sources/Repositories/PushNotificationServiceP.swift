import Foundation

public protocol PushNotificationServiceP {
  func addRepeatAlarm(_ dataArray: [DdayCellData], _ firstDay: Date)
  func addAlarm(text: String, date: String, type: String)
  func registerForPushNotifications()
}
