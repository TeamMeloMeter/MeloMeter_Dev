//
//  AdmobRepository.swift
//  MeloMeter
//
//  Created by 양승완 on 4/1/25.
//

import UIKit
import GoogleMobileAds
import RxSwift
import RxCocoa
import Domain
public class AdmobRepository: AdmobRepositoryP {
    
    private let bannerDebug = "ca-app-pub-3940256099942544/2934735716"
    private let bannerRelease = "ca-app-pub-5763713982294456/4052448154"
    
    private let fullScreenDebug = "ca-app-pub-3940256099942544/4411468910"
    private let fullScreenRelease = "ca-app-pub-5763713982294456/4004346694"

    public init() {}
    
    public func loadBottomBanner() -> BannerView {
        let bannerView = BannerView()
        
#if DEBUG
        bannerView.adUnitID = bannerDebug
#else
        bannerView.adUnitID = bannerRelease
#endif
        bannerView.load(Request())
        return bannerView
        
    }
    
    public func loadInterstitial() -> Single<InterstitialAd> {
        return Single.create { [weak self] single in
            guard let self else {return Disposables.create()}
            
    #if DEBUG
            let id = fullScreenDebug
    #else
            let id = fullScreenRelease
    #endif
            
            InterstitialAd.load(
                with: id,
                request: Request()
            ) { [weak self] ad, error in
                guard let self else {return}
                
                if let ad {
                    single(.success(ad))
                    return
                }
                else if let error {
                    single(.failure(error))

                    return
                }
            }
            return Disposables.create()
        }
    }
}
