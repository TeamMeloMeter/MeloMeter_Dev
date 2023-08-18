//
//  Date.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/14.
//

import Foundation

extension Date {
    
    enum Format: String {
        case yearToDay = "yyyy.MM.dd"
        case yearToDayHipen = "yyyy-MM-dd"
        case yearToSecond = "yyyy-MM-dd HH:mm:ss"
        case timeStamp = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case hourAndMinute = "HH:mm"
        case monthAndDate = "M월 d일"
        case monthAndDate2 = "MM/dd"
        case yearAndMonthAndDate = "YYYY년 M월 d일"
        case yearAndMonth = "YYYY년 M월"
    }
    
    // MARK: Methods
    func toString(type: Format) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = type.rawValue
        
        return formatter.string(from: self)
    }
    
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = format

        return formatter.string(from: self)
    }

    static func stringToDate(dateString: String, type: Format) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = type.rawValue

        return formatter.date(from: dateString)
    }
    
    static func stringToDate(dateString: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = format
        
        return formatter.date(from: dateString)
    }
}

extension Date {
    
    static func fromStringOrNow(_ string: String,_ type: Format) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = type.rawValue
        if formatter.date(from: string) == nil {
        }
        
        return formatter.date(from: string) ?? Date()
    }
}
