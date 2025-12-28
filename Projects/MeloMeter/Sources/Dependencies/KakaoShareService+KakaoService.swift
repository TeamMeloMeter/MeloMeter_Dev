//
//  KakaoShareService+KakaoService.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Data
import Presentation

extension KakaoService: KakaoShareService {
    public func share(inviteCode: String) {
        shareWithKakaoTalk(inviteCode: inviteCode)
    }
}
