//
//  LocationModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/19.
//

import UIKit


class Model {
//    static let shared = Model()
//    ///Dday 데이터
//    var startDate: Date? //연애 시작일
//    private let dateFormatter = DateFormatter() //날짜 형식
//    private var pmDate = ""
//    var birthDay = Date() // 생일
//    var addDdayArray: [[String]] = [] {  // 추가된 기념일
//        didSet{ //속성감시자 (기념일 추가된지)
//            guard let lastAni = addDdayArray.last?[0] else { return }
//            guard let lastDate = addDdayArray.last?[1] else { return }
//            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
//            print("실패????\(lastDate)")
//            if let date = dateFormatter.date(from: lastDate) {
//                print("기념일 추가배열 속성 감시 되니 ㅡㅡ>>>>")
//                addAnniversary(addName: lastAni, addDate: date)
//            }
//        }
//    }
//    private let calendar = Calendar.current // 날짜 계산
//    var dataDdayTableView: [DdayCellData] = [] //기념일 테이블뷰 셀 데이터
//    var cellIndex = 0 //셀 시작 인덱스
//
//    private init() {}
//
//    //임시 시작날짜
//    func startDay() {
//        dateFormatter.dateFormat = "yyyy.MM.dd" // 날짜 포맷
//        //임시 시작일
//        let dateString = "2023.05.21"
//        if let date = dateFormatter.date(from: dateString) {
//           startDate = date
//        }
//        //임시생일
//        let birthString = "1998.05.21"
//        if let date = dateFormatter.date(from: birthString) {
//            birthDay = date
//        }
//    }
//
//    func pmDday(from date: Date) -> Int { // 입력받은 날짜 - 현재 날짜 계산
//        let result = (calendar.dateComponents([.day], from: Date(), to: date).day ?? 0)
//        if result < 0 {
//            return  result
//        }
//        return result
//    }
//
//    //생일 추가
//    func listAddBirthday() {
//        var cnt = 0
//
//        var addindex = 0
//        let length = dataDdayTableView.count
//        // 찾은 위치에 새로운 날짜를 삽입
//        for index in 0..<length {
//
//            guard let date = dateFormatter.date(from: dataDdayTableView[index + addindex].aniDate) else{return}
//            guard let birth = calendar.date(byAdding: .year, value: cnt, to: birthDay) else{return}
//            let birthY = calendar.component(.year, from: birth)
//            let dateY = calendar.component(.year, from: dateFormatter.date(from: dataDdayTableView[0].aniDate) ?? Date())
//            if birthY < dateY {
//                cnt = dateY - birthY
//            }
//            if pmDday(from: birth) > 0 {
//                pmDate = "\(pmDday(from: birth))일 남음"
//            }else if pmDday(from: birth) == 0 {
//                pmDate = "당일"
//            }else {
//                pmDate = "\(abs(pmDday(from: birth)))일 지남"
//            }
//            if birth < date && birth != birthDay {
//                dataDdayTableView.insert(DdayCellData(aniName: "생일", countDdays: pmDate, aniDate: dateFormatter.string(from: birth)), at: index + addindex)
//                cnt += 1
//                addindex += 1
//
//            }else if birth == date {
//                dataDdayTableView.insert(DdayCellData(aniName: "생일 & \(dataDdayTableView[index + addindex].aniName)", countDdays: pmDate, aniDate: dateFormatter.string(from: birth)), at: index + addindex)
//                dataDdayTableView.remove(at: index + addindex + 1)
//                cnt += 1
//            }
//
//        }
//
//    }
//
//
//    //기념일 리스트 계산 후 대입
//    func calculateDays() {
//        dateFormatter.dateFormat = "yyyy.MM.dd"
//        var cnt = 1 //몇주년 인지 구분
//        //시작날짜 없을 경우 분기처리
//        guard let dateStart = startDate else {
//            dataDdayTableView.append(DdayCellData(aniName: "연애 시작 날짜를 입력해주세요!", countDdays: "", aniDate: "0000.00.00"))
//            return
//        }
//
//        dataDdayTableView.append(DdayCellData(aniName: "1일", countDdays: "\(abs(pmDday(from: dateStart)))일 지남", aniDate: dateFormatter.string(from: dateStart)))
//
//        for i in 1...100 {
//            //시작일부터 100일 단위 기념일 날짜
//            guard let ani = calendar.date(byAdding: .day, value: (i * 100) - 1, to: dateStart) else{return}
//            //년 단위 기념일 날짜
//            guard let yearAni = calendar.date(byAdding: .year, value: cnt, to: dateStart) else{return}
//
//            //100일 단위 기념일의 날짜와 년 단위 날짜 차이
//            if let aniDay = calendar.dateComponents([.day], from: ani, to: yearAni).day {
//                //지난 기념일 판단
//                if pmDday(from: ani) > 0 {
//                    pmDate = "\(pmDday(from: ani))일 남음"
//                }else if pmDday(from: ani) == 0 {
//                    pmDate = "당일"
//                }else {
//                    pmDate = "\(abs(pmDday(from: ani)))일 지남"
//                }
//
//                if aniDay > 0 {
//
//                    dataDdayTableView.append(DdayCellData(aniName: "\(i * 100)일", countDdays: pmDate, aniDate: dateFormatter.string(from: ani)))
//                }else if let aniYear = calendar.dateComponents([.year], from: dateStart, to: yearAni).year{
//                    cnt += 1
//
//                    dataDdayTableView.append(DdayCellData(aniName: "\(aniYear)주년", countDdays: pmDate, aniDate: dateFormatter.string(from: yearAni)))
//                    dataDdayTableView.append(DdayCellData(aniName: "\(i * 100)일", countDdays: pmDate, aniDate: dateFormatter.string(from: ani)))
//
//                }
//            }
//        }
//
//        listAddBirthday()
//    }
//
//    ///기념일 추가 시 년도마다 추가 or 하나만 추가 옵션(?) 추후 고려
//
//    //기념일 추가
//    func addAnniversary(addName: String, addDate: Date) {
//        //이진탐색
//        var startIndex = 0
//        var endIndex = dataDdayTableView.count
//        let newDate = addDate
//        dateFormatter.dateFormat = "yyyy.MM.dd"
//        while startIndex < endIndex {
//            let middleIndex = (startIndex + endIndex) / 2
//            guard let middleDate = dateFormatter.date(from: dataDdayTableView[middleIndex].aniDate) else { return }
//            if newDate < middleDate {
//                endIndex = middleIndex
//            } else {
//                startIndex = middleIndex + 1
//            }
//        }
//
//        if pmDday(from: newDate) > 0 {
//            pmDate = "\(pmDday(from: newDate))일 남음"
//        }else if pmDday(from: newDate) == 0 {
//            pmDate = "당일"
//        }else {
//            pmDate = "\(abs(pmDday(from: newDate)))일 지남"
//        }
//        dataDdayTableView.insert(DdayCellData(aniName: addName, countDdays: pmDate, aniDate: dateFormatter.string(from: newDate)), at: startIndex)
//
//        print("ㅡㅡㅡㅡㅡ 남은날짜 \(pmDday(from: newDate)) 인덱스 ㅡㅡ>>> \(startIndex)")
//
//    }
//    //처음 표시할 셀
//    func focusCell() {
//        for (index, element) in dataDdayTableView.enumerated() {
//            guard let date = dateFormatter.date(from: element.aniDate) else{return}
//            let distance = date.timeIntervalSince(Date()) // 현재 날짜와의 차이값
//            if distance >= 0 {
//                cellIndex = index
//                return
//            }
//        }
//    }
}
