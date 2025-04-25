//
//  SharedDataRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 4/23/25.
//

import Foundation

class SharedDataRepo: SharedDataRepoP {

    private let userDefaults = UserDefaults(suiteName: "group.com.teamMelometer.widget")
    
    func saveStartDate(startDate: String) {
        userDefaults!.set(startDate, forKey: "startDate")
        userDefaults!.synchronize()

        WidgetService.shared.reloadTimelines()
    }
    
    func saveOthersName(othersName: String) {
        userDefaults!.set(othersName, forKey: "othersName")
        userDefaults!.synchronize()
        WidgetService.shared.reloadTimelines()
    }
    
    func saveMyName(myName: String) {
        userDefaults!.set(myName, forKey: "myName")
        userDefaults!.synchronize()
        WidgetService.shared.reloadTimelines()
    }
}
