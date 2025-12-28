//
//  AdmobRepositoryP.swift
//  MeloMeter
//
//  Created by 양승완 on 4/1/25.
//
import GoogleMobileAds
import RxSwift
public protocol AdmobRepositoryP {
    func loadBottomBanner() -> BannerView
    func loadInterstitial() -> Single<InterstitialAd>
}
