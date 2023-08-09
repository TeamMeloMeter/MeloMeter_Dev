//
//  DdayUseCase.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/07.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import Firebase

class DdayUseCase {
    
    private var disposeBag: DisposeBag
    private var coupleRepository: CoupleRepository
    private let calendar = Calendar.current
    var firstDay: PublishRelay<Date>
    var dDayCellArray: PublishRelay<[DdayCellData]>
    
    init(coupleRepository: CoupleRepository) {
        self.coupleRepository = coupleRepository
        self.firstDay = PublishRelay()
        self.dDayCellArray = PublishRelay()
        self.disposeBag = DisposeBag()
    }
    
    func getFirstDay() {
        self.coupleRepository.getCoupleModel()
            .subscribe(onSuccess: { data in
                if let day = data?.firstDay {
                    self.createAnniArray(day)
                    self.firstDay.accept(day)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func sinceDday(from date: Date) -> String {
        let result = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        return result < 0 ? "\(abs(result))일 지남" : "\(result + 1)일"
    }
    
    func sinceDday(from date: Date) -> Int {
        let result = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        return result < 0 ? abs(result) : (result + 1)
    }
    
    func createAnniArray(_ firstDay: Date) {
        self.coupleRepository.getCoupleModel()
            .subscribe(onSuccess: { data in
                if let dataArray = data?.anniversaries, let firstDay = data?.firstDay {
                    self.dDayCellArray.accept(self.createDdayList(dataArray, firstDay))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func createDdayList(_ dataArray: [DdayCellData],_ firstDay: Date) -> [DdayCellData] {
        var resultArray: [DdayCellData] = []
        var cnt = 1 //몇주년 인지 구분
        var countDday = ""
//        //시작날짜 없을 경우 분기처리
//        guard let dateStart = startDate else {
//            dataDdayTableView.append(DdayCellData(aniName: "연애 시작 날짜를 입력해주세요!", countDdays: "", aniDate: "0000.00.00"))
//            return
//        }
        
        resultArray.append(DdayCellData(dateName: "첫 만남🫣", date: firstDay, countDdays: sinceDday(from: firstDay)))
        print("유케: ",resultArray)
        for i in 1...100 {
            //시작일부터 100일 단위 기념일 날짜
            guard let ani = calendar.date(byAdding: .day, value: (i * 100) - 1, to: firstDay) else{return resultArray}
            //년 단위 기념일 날짜
            guard let yearAni = calendar.date(byAdding: .year, value: cnt, to: firstDay) else{return resultArray}

            //100일 단위 기념일의 날짜와 년 단위 날짜 차이
            if let aniDay = calendar.dateComponents([.day], from: ani, to: yearAni).day {
                //지난 기념일 판단
                if sinceDday(from: ani) > 0 {
                    countDday = "\(sinceDday(from: ani))일 남음"
                }else if sinceDday(from: ani) == 0 {
                    countDday = "당일"
                }else {
                    countDday = "\(abs(sinceDday(from: ani)))일 지남"
                }
                if aniDay > 0 {
                    resultArray.append(DdayCellData(dateName: "\(i * 100)일", date: ani, countDdays: countDday))
                }else if let aniYear = calendar.dateComponents([.year], from: firstDay, to: yearAni).year{
                    cnt += 1
                    resultArray.append(DdayCellData(dateName: "\(aniYear)주년",
                                                    date: yearAni,
                                                    countDdays: countDday)
                                       )
                    resultArray.append(DdayCellData(dateName: "\(i * 100)일", date: ani, countDdays: countDday))

                }
            }
        }
        return resultArray
    }
    
}
