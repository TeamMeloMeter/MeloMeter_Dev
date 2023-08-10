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
        self.coupleRepository.coupleModel
            .take(1)
            .subscribe(onNext: { data in
                self.firstDay.accept(data.firstDay)
            })
            .disposed(by: disposeBag)
    }
    
    func sinceDday(from date: Date) -> Int {
        let currentDate = Date.fromStringOrNow(Date().toString(type: .yearToDay), .yearToDay)
        let result = calendar.dateComponents([.day], from: currentDate, to: date).day ?? 0

        return result
    }
    
    func coupleObserverExcute() {
        self.coupleRepository.couplesObserver()
        self.coupleRepository.coupleModel
            .map{ data in
                let dataArray = data.anniversaries, firstDay = data.firstDay
                return self.createDdayList(dataArray, firstDay)
            }
            .asObservable()
            .bind(to: self.dDayCellArray)
            .disposed(by: disposeBag)
    }
    
    func createDdayList(_ dataArray: [DdayCellData],_ firstDay: Date) -> [DdayCellData] {
        var resultArray: [DdayCellData] = []
        var countDday = ""
        let firstDayCount = sinceDday(from: firstDay) == 0 ? "오늘✋" : "\(abs(sinceDday(from: firstDay)))일 지남"
        resultArray.append(DdayCellData(dateName: "첫 만남🫣", date: firstDay, countDdays: firstDayCount))
        for i in 1...182 {
            //시작일부터 100일 단위 기념일 날짜
            guard let ani = calendar.date(byAdding: .day, value: (i * 100), to: firstDay) else{return resultArray}
            if sinceDday(from: ani) > 0 {
                countDday = "\(sinceDday(from: ani))일 남음"
            }else if sinceDday(from: ani) == 0 {
                countDday = "오늘🎉"
            }else {
                countDday = "\(abs(sinceDday(from: ani)))일 지남"
            }
            resultArray.append(DdayCellData(dateName: "\(i * 100)일", date: ani, countDdays: countDday))
        }
        
        for i in 1...50 {
            //년 단위 기념일 날짜
            guard let yearAni = calendar.date(byAdding: .year, value: i, to: firstDay) else{ return resultArray }
    
            if sinceDday(from: yearAni) > 0 {
                countDday = "\(sinceDday(from: yearAni))일 남음"
            }else if sinceDday(from: yearAni) == 0 {
                countDday = "오늘🎊"
            }else {
                countDday = "\(abs(sinceDday(from: yearAni)))일 지남"
            }
            resultArray.append(DdayCellData(dateName: "\(i)주년",
                                            date: yearAni,
                                            countDdays: countDday)
            )
            
        }
        var addAni = Date()
        for data in dataArray {
            if data.dateName.contains("생일") {
                addAni = calendar.date(byAdding: .year, value: 20, to: data.date) ?? Date()
                for i in 1...50 {
                    guard let yearAni = calendar.date(byAdding: .year, value: i, to: addAni) else{ return resultArray }
                    if sinceDday(from: yearAni) > 0 {
                        countDday = "\(sinceDday(from: yearAni))일 남음"
                    }else if sinceDday(from: yearAni) == 0 {
                        countDday = "오늘🎉"
                    }else {
                        countDday = "\(abs(sinceDday(from: yearAni)))일 지남"
                    }
                    resultArray.append(DdayCellData(dateName: data.dateName, date: yearAni, countDdays: countDday))
                }
            }else {
                addAni = data.date
                if sinceDday(from: addAni) > 0 {
                    countDday = "\(sinceDday(from: addAni))일 남음"
                }else if sinceDday(from: addAni) == 0 {
                    countDday = "오늘🎉"
                }else {
                    countDday = "\(abs(sinceDday(from: addAni)))일 지남"
                }
                resultArray.append(DdayCellData(dateName: data.dateName, date: addAni, countDdays: countDday))
            }
            
        }
        
        
        return resultArray.sorted(by: { $0.date < $1.date })
    }
    
    func addDday(add: [String]) -> Single<Void> {
        var data = add
        data[1] = Date.fromStringOrNow(add[1], .yearAndMonthAndDate).toString(type: .yearToDay)
        return self.coupleRepository.setAnniversaries(data: data)
    }
    
}
