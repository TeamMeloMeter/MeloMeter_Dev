//
//  SplashVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/16.
//

import UIKit
import RxSwift
final class SplashVC: UIViewController {
    private let viewModel: SplashVM
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
}
