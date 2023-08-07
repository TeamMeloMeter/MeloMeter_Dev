//
//  DdayView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

// 기념일페이지 UI View
class DdayView: UIView {
    
    //상단 배경 뷰
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: #colorLiteral(red: 0.7137254902, green: 0.7137254902, blue: 0.7137254902, alpha: 1), alpha: 0.25, x: 3, y: 2, blur: 10)
        view.addSubview(dDayImageView)
        view.addSubview(nomalLabel)
        view.addSubview(countDateLabel)
        view.addSubview(startDateLabel)
        
        return view
    }()
    
    //로고 이미지
    let dDayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "topImage")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    
    
    // 우리 함께한지 label
    private let nomalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "우리 함께한지"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    // 현재 D+ 날짜 label
    let countDateLabel: UILabel = {
        let label = UILabel()
        label.text = "0일째"
        label.textColor = #colorLiteral(red: 1, green: 0.2941176471, blue: 0.7411764706, alpha: 1)
        label.font = FontManager.shared.semiBold(ofSize: 32)
        return label
    }()
    // 연애 시작일 날짜 label
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.text = "첫 만남 0000.00.00"
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    // 기념일 리스트 tableView
    let dDayTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DdayTableViewCell.self, forCellReuseIdentifier: "DdayTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
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
        [topView, dDayTableView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        topViewConstraint()
        dDayImageViewConstraint()
        labelConstraint()
        dDayTableViewConstraint()
    }
    
    
    private func topViewConstraint() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 9),
            topView.heightAnchor.constraint(equalToConstant: 340)
            
        ])
    }
    
    private func dDayImageViewConstraint() {
        dDayImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dDayImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 35),
            dDayImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -47),
            dDayImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 39),
            dDayImageView.heightAnchor.constraint(equalToConstant: 147)
        ])
    }
    
    
    private func labelConstraint() {
        nomalLabel.translatesAutoresizingMaskIntoConstraints = false
        countDateLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nomalLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            nomalLabel.topAnchor.constraint(equalTo: dDayImageView.bottomAnchor, constant: 13),
            nomalLabel.widthAnchor.constraint(equalToConstant: 87),
            nomalLabel.heightAnchor.constraint(equalToConstant: 19),
            
            countDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            countDateLabel.topAnchor.constraint(equalTo: nomalLabel.bottomAnchor, constant: 6),
            
            startDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            startDateLabel.topAnchor.constraint(equalTo: countDateLabel.bottomAnchor, constant: 16),
            
            
        ])
    }
    
    private func dDayTableViewConstraint() {
        dDayTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dDayTableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            dDayTableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            dDayTableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 16),
            dDayTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
    }
    
}
