import Foundation

public protocol PushNotificationServiceP {
  func addRepeatAlarm(_ dataArray: [DdayCellData], _ firstDay: Date)
}
