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

// MARK: Kakao 공유 Service 싱글톤 클래스
final class KakaoService {
    
    static let shared = KakaoService()
    
    private init(){}
    
    func shareWithKakaoTalk(inviteCode: String) {
        // 앱 링크: 파라미터를 함께 전달하여 앱으로 들어왔을 때 특정 페이지로 이동할 수 있는 역할
        let appLink = Link(iosExecutionParams: ["appBtnTapped": inviteCode])
        
        // 버튼
        let appButton = Button(title: "앱에서 보기", link: appLink)
        
        // 메인이 되는 사진, 이미지 URL, 클릭 시 이동하는 링크를 설정합니다.
        let content = Content(title: "[멜로미터] 초대코드: \(inviteCode)",
                              imageUrl: URL(string: "https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png")!,
                              link: appLink)
        
        let template = FeedTemplate(content: content, buttons: [appButton])
        
        // 메시지 템플릿 encode
        if let templateJsonData = (try? SdkJSONEncoder.custom.encode(template)) {
            // 생성한 메시지 템플릿 객체를 jsonObject로 변환
            if let templateJsonObject = SdkUtils.toJsonObject(templateJsonData) {
                // 카카오톡 앱이 있는지 체크
                if ShareApi.isKakaoTalkSharingAvailable() {
                    ShareApi.shared.shareDefault(templateObject:templateJsonObject) {(linkResult, error) in
                        if let error = error {
                            print("error : \(error)")
                        }
                        else {
                            print("defaultLink(templateObject:templateJsonObject) success.")
                            guard let linkResult = linkResult else { return }
                            UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                        }
                    }
                } else {
                    // 없을 경우 카카오톡 앱스토어로 이동 (이거 하려면 URL Scheme에 itms-apps 추가 해야함)
                    let url = "itms-apps://itunes.apple.com/app/362057947"
                    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
        }
    }
}
