//
//  SharedDataRepo.swift
//  MeloMeter
//
//  Created by 양승완 on 4/23/25.
//

import Foundation
#if canImport(Domain)
import Domain
#endif

public class SharedDataRepo: SharedDataRepoP {

    private let userDefaults = UserDefaults(suiteName: "group.com.teamMelometer.widget")

    public init() {}
    
    public func saveStartDate(startDate: String) {
        userDefaults!.set(startDate, forKey: "startDate")
        userDefaults!.synchronize()

        WidgetService.shared.reloadTimelines()
    }
    
    public func saveOthersName(othersName: String) {
        userDefaults!.set(othersName, forKey: "othersName")
        userDefaults!.synchronize()
        WidgetService.shared.reloadTimelines()
    }
    
    public func saveMyName(myName: String) {
        userDefaults!.set(myName, forKey: "myName")
        userDefaults!.synchronize()
        WidgetService.shared.reloadTimelines()
    }
}
