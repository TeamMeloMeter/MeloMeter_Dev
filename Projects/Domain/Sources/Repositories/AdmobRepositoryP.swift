import GoogleMobileAds
import RxSwift

protocol AdmobRepositoryP {
    func loadBottomBanner() -> BannerView
    func loadInterstitial() -> Single<InterstitialAd>
}

extension AdmobRepository: AdmobRepositoryP {}
