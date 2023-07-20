//
//  CustomAlertVC.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/20.
//

import UIKit

class CustomAlertVC: UIViewController {
    var alertTitle: String?
    var message: String?
    var addActionConfirm: AddAction?
    
    private lazy var alertView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(lineView)
        view.addSubview(confirmButton)
        return view
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.font = FontManager.shared.semiBold(ofSize: 26)
        label.textColor = .gray1
        label.textAlignment = .center
        label.text = alertTitle
        return label
    }()
    
    private lazy var messageLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = FontManager.shared.medium(ofSize: 14)
        label.textAlignment = .center
        label.text = message
        let attributedString = NSMutableAttributedString(string: label.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var lineView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    private lazy var confirmButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        button.setTitle(addActionConfirm?.text, for: .normal)
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        return button
    }()
    
    @objc func pressed() {
        addActionConfirm?.action?()
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    private func setViews() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(alertView)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor, constant: 280),
            alertView.widthAnchor.constraint(equalToConstant: 280),
            alertView.heightAnchor.constraint(equalToConstant: 303),
            
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 74),
            
            messageLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 29),
            
            lineView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -52),
            lineView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            
            confirmButton.topAnchor.constraint(equalTo: lineView.bottomAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor)

        ])
    }
}
