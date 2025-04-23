//
//  UserDefaultService.swift
//  MeloMeter
//
//  Created by 양승완 on 12/17/24.
//

import Foundation
import WidgetKit


final class WidgetService {
    
    static let shared = WidgetService()
    
    private init() {}
    
    func reloadTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}
