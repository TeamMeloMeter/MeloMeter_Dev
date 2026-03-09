//
//  KakaoShareService+KakaoService.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

#if canImport(Data)
import Data
#endif
#if canImport(Presentation)
import Presentation
#endif

extension KakaoService: KakaoShareService {
    public func share(inviteCode: String) {
        shareWithKakaoTalk(inviteCode: inviteCode)
    }
}
