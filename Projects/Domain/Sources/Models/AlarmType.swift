import Foundation

public enum AlarmType: String {
  case defaultValue
  case yearAnni
  case hundredAnni
  case customAnni
  case hundredQA
  case birthDay
  case profile

  public var stringType: String {
    return rawValue
  }
}
