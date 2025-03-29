//
//  VersionRepositoryP.swift
//  MeloMeter
//
//  Created by 양승완 on 3/29/25.
//

protocol VersionRepositoryP {
    func getAppStoreVersion(completion: @escaping (String?) -> Void)
    func getDeviceVersion() -> String
}
