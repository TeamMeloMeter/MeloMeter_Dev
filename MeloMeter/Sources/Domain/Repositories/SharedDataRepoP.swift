//
//  SharedDataRepoP.swift
//  MeloMeter
//
//  Created by 양승완 on 4/23/25.
//

import Foundation

protocol SharedDataRepoP {
    func saveOthersName(othersName: String)
    func saveStartDate(startDate: String)
    func saveMyName(myName: String)
}
