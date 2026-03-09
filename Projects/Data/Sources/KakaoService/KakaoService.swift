//
//  KakaoService.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/23.
//

import KakaoSDKShare
import KakaoSDKCommon
import KakaoSDKTalk
import KakaoSDKAuth
import KakaoSDKTemplate
import UIKit
#if canImport(Domain)
import Domain
#endif

// MARK: Kakao 공유 Service 싱글톤 클래스
public final class KakaoService {
    
    public static let shared = KakaoService()
    
    private init(){}
    
    public func shareWithKakaoTalk(inviteCode: String) {
        
        if ShareApi.isKakaoTalkSharingAvailable() {
            ShareApi.shared.shareCustom(templateId: 96360, templateArgs: ["${inviteCode}": inviteCode]) {(sharingResult, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("shareCustom() success.")
                    if let sharingResult = sharingResult {
                        UIApplication.shared.open(sharingResult.url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        else {

        }

    }
}
