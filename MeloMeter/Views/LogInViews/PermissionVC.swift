//
//  PermissionVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/05.
//

import UIKit

class PermissionVC: UIViewController {
    
    private let viewModel: PermissionVM
    
    init(viewModel: PermissionVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
    }
    
    // MARK: - configure
    func configure() {
        view.backgroundColor = .white
       
        [background, titleLabel, exLabel, subLabel, startBtn].forEach { view.addSubview($0) }
    }
    
    // MARK: - UI
    let background: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "permissionBackG")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "거의 다 왔어요!\n서로의 위치 공유를 위해\n위치권한을 허용해 주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 20)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        return label
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "사랑하는 연인과 위치를 공유하기 위해서\n“앱을 사용하는 동안 허용”으로 설정해 주세요"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let range = NSRange(location: 21, length: 15)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.semiBold(ofSize: 14)
        ]
        attributedString.addAttributes(attributes, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 정보는 서비스 최적화를 위해서만 사용됩니다"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        
        return label
    }()
    
    private let startBtn: UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.primary1, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 18)
        button.layer.cornerRadius = 25
        button.backgroundColor = .white
        button.layer.applyShadow(color: UIColor.primary1, alpha: 0.48, x: 0, y: 0, blur: 16)
        button.layer.masksToBounds = false
        return button
    }()
    
    // MARK: - 오토레이아웃
    private func setAutoLayout() {
        background.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            background.topAnchor.constraint(equalTo: self.view.topAnchor),
            background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 124),
            
            exLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            exLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36),
            
            subLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            subLabel.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 13),
            
            startBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            startBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            startBtn.widthAnchor.constraint(equalToConstant: 327),
            startBtn.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
