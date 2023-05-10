//
//  QnAView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

class QnAView: UIView {
   
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        return view
    }()
    
    let radioBtn: UIButton = {
        let button = UIButton()
        button.setTitle("가입/인증", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.isSelected = true
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = FontManager.shared.semiBold(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.6392156863, green: 0.6392156863, blue: 0.6392156863, alpha: 1)
        return button
    }()
    
    let radioBtn1: UIButton = {
        let button = UIButton()
        button.setTitle("아이디/비밀번호 분실", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn2: UIButton = {
        let button = UIButton()
        button.setTitle("변경/탈퇴", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn3: UIButton = {
        let button = UIButton()
        button.setTitle("위치기반", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn4: UIButton = {
        let button = UIButton()
        button.setTitle("연결/재연결", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    let radioBtn5: UIButton = {
        let button = UIButton()
        button.setTitle("백업/복구", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.4588235294, green: 0.4509803922, blue: 0.4509803922, alpha: 1), for: .normal)
        button.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        button.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9725490196, alpha: 1)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        
        return button
    }()
    
    
    // 질문 tableView
    let qnATableView: UITableView = {
        let tableView = UITableView()
        tableView.register(QnATableViewCell.self, forCellReuseIdentifier: "QnATableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 56
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tableView
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
        [topView, radioBtn, radioBtn1, radioBtn2, radioBtn3, radioBtn4, radioBtn5, qnATableView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        radioConstraint()
        qnATableViewConstraint()
    }
    
    private func topViewConstraint() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 104)
           
        ])
    }
    
    private func radioConstraint() {
        radioBtn.translatesAutoresizingMaskIntoConstraints = false
        radioBtn1.translatesAutoresizingMaskIntoConstraints = false
        radioBtn2.translatesAutoresizingMaskIntoConstraints = false
        radioBtn3.translatesAutoresizingMaskIntoConstraints = false
        radioBtn4.translatesAutoresizingMaskIntoConstraints = false
        radioBtn5.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radioBtn.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            radioBtn.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 32),
            radioBtn.widthAnchor.constraint(equalToConstant: 86),
            radioBtn.heightAnchor.constraint(equalToConstant: 37),
           
            radioBtn1.leadingAnchor.constraint(equalTo: radioBtn.trailingAnchor, constant: 8),
            radioBtn1.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 32),
            radioBtn1.widthAnchor.constraint(equalToConstant: 150),
            radioBtn1.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn2.leadingAnchor.constraint(equalTo: radioBtn1.trailingAnchor, constant: 8),
            radioBtn2.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 32),
            radioBtn2.widthAnchor.constraint(equalToConstant: 86),
            radioBtn2.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn3.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            radioBtn3.topAnchor.constraint(equalTo: radioBtn.bottomAnchor, constant: 17),
            radioBtn3.widthAnchor.constraint(equalToConstant: 81),
            radioBtn3.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn4.leadingAnchor.constraint(equalTo: radioBtn3.trailingAnchor, constant: 8),
            radioBtn4.topAnchor.constraint(equalTo: radioBtn1.bottomAnchor, constant: 17),
            radioBtn4.widthAnchor.constraint(equalToConstant: 98),
            radioBtn4.heightAnchor.constraint(equalToConstant: 37),
            
            radioBtn5.leadingAnchor.constraint(equalTo: radioBtn4.trailingAnchor, constant: 8),
            radioBtn5.topAnchor.constraint(equalTo: radioBtn2.bottomAnchor, constant: 17),
            radioBtn5.widthAnchor.constraint(equalToConstant: 86),
            radioBtn5.heightAnchor.constraint(equalToConstant: 37),
            
        ])
    }
    
    private func qnATableViewConstraint() {
        qnATableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            qnATableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            qnATableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            qnATableView.topAnchor.constraint(equalTo: radioBtn3.bottomAnchor, constant: 31.5),
            qnATableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
           
        ])
    }
}
