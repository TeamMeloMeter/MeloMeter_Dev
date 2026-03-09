//
//  UserDefaultService.swift
//  MeloMeter
//
//  Created by 양승완 on 12/17/24.
//

import Foundation
import WidgetKit
#if canImport(Domain)
import Domain
#endif


public final class WidgetService {
    
    public static let shared = WidgetService()
    
    private init() {}
    
    public func reloadTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}
