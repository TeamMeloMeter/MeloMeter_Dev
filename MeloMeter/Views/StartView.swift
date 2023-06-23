//
//  StartView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/06/22.
//

import Foundation
import UIKit

class StartView: UIView {
   
    let background: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "startView")
        imageView.contentMode = .scaleToFill
       
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = "멜로미터에\n오신 것을 환영합니다"
        label.textColor = .primary2
        label.font = FontManager.shared.extraLight(ofSize: 30)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let range = NSRange(location: 0, length: 4)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.semiBold(ofSize: 30),
            .foregroundColor: UIColor.primary2
        ]
        attributedString.addAttributes(attributes, range: range)
        label.attributedText = attributedString
        return label
    }()
    
    private let exLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.text = " 시작하기를 누르면 개인정보 보호정책 및 \n서비스약관에 동의하는 것으로 간주됩니다."
        label.textColor = #colorLiteral(red: 0.4756370187, green: 0.4756369591, blue: 0.4756369591, alpha: 1)
        label.font = FontManager.shared.medium(ofSize: 12)
        let attributedString = NSMutableAttributedString(string: label.text!)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        
        return label
    }()
    
    let startBtn: UIButton = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
    }
    
    func addViews() {
        [background, titleLabel, exLabel, startBtn].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        constraints()
    }
    
    private func constraints() {
        background.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        exLabel.translatesAutoresizingMaskIntoConstraints = false
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            background.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            background.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 88),
            
            exLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            exLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 430),
            
            startBtn.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            startBtn.topAnchor.constraint(equalTo: exLabel.bottomAnchor, constant: 24),
            startBtn.widthAnchor.constraint(equalToConstant: 327),
            startBtn.heightAnchor.constraint(equalToConstant: 52)

        ])
    }
}
