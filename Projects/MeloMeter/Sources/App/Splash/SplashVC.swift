//
//  SplashVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/16.
//

import UIKit
import RxSwift
import GoogleMobileAds
import Presentation
import SnapKit
final class SplashVC: UIViewController {
    private let viewModel: SplashVM
    private var disposeBag = DisposeBag()
    init(viewModel: SplashVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayout()
        startAnimation()
        
        viewModel.selectFlow()
        viewModel.setNotification()
       
        viewModel.loadAdmob.subscribe(onNext: { [weak self] ad in
            guard let self, let ad else {return}
            ad.present(from: self)
        }).disposed(by: disposeBag)
        
        viewModel.alert.subscribe(onNext: { [weak self] alertType in
            guard let self else {return}
            
            if alertType == "appStore" {
                DispatchQueue.main.async {
                    AlertManager(viewController: self)
                        .setAppStoreAlert()
                }
   
            } else if alertType == "offLine" {
                DispatchQueue.main.async {
                    
                    AlertManager(viewController: self)
                        .showNomalAlert(title: "네트워크 오류", message: "네트워크 연결을 확인해주세요").subscribe({ com in
                            switch com {
                                
                            case .success():
                                exit(0)
                            case .failure(_):
                                exit(0)
                            }
                            
                        }).disposed(by: self.disposeBag)
                }
            }
            
            
        }).disposed(by: disposeBag)
        
    }
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    func startAnimation() {
        UIView.animate(withDuration: 1.2, delay: 0.1, options: [.autoreverse, .repeat], animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: nil)
    }
    
    private func setAutoLayout() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    //MARK: adMob
    private func addBannerViewToView(bannerView: BannerView?) {
        
        guard let bannerView else {return}
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        bannerView.adSize = adaptiveSize
        bannerView.rootViewController = self
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.centerX.equalTo(view.snp.centerX)
        }

    }
}
