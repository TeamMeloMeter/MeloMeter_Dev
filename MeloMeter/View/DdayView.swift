//
//  DdayView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

// 기념일페이지 UI View
class DdayView: UIView {
    
    //마이페이지 상단 배경 뷰
     lazy var topView: UIView = {
         let view = UIView()
         view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
         view.addSubview(meProfileImageView)
         view.addSubview(loverProfileImageView)
         view.addSubview(nomalLabel)
         view.addSubview(currentDateLabel)
         view.addSubview(startDateLabel)
         
         return view
     }()
   
    //내 프로필사진
    let meProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profileTest")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    //상대방 프로필사진
    let loverProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profileTest")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    // 우리 함께한지 label
    let nomalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "우리 함께한지"
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    // 현재 D+ 날짜 label
    let currentDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "1593일째"
        label.font = FontManager.shared.semiBold(ofSize: 32)
        return label
    }()
    // 연애 시작일 날짜 label
    let startDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.5924944878, green: 0.5924944878, blue: 0.5924944878, alpha: 1)
        label.text = "2023.05.04"
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    // 기념일 리스트 tableView
    let dDayTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DdayTableViewCell.self, forCellReuseIdentifier: "DdayTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 77
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

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
        meProfileImageViewConstraint()
        loverProfileImageViewConstraint()
        labelConstraint()
        dDayTableViewConstraint()
    }
    
    
    private func topViewConstraint() {
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 332)
           
        ])
    }
    
    private func meProfileImageViewConstraint() {
        meProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            meProfileImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 109),
            meProfileImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -180),
            meProfileImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 57),
            meProfileImageView.widthAnchor.constraint(equalToConstant: 86),
            meProfileImageView.heightAnchor.constraint(equalToConstant: 86)
        ])
    }
    
    private func loverProfileImageViewConstraint() {
        loverProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loverProfileImageView.trailingAnchor.constraint(equalTo: meProfileImageView.trailingAnchor, constant: 75),
            loverProfileImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 57),
            loverProfileImageView.widthAnchor.constraint(equalToConstant: 86),
            loverProfileImageView.heightAnchor.constraint(equalToConstant: 86)
        ])
    }
    
    private func labelConstraint() {
        nomalLabel.translatesAutoresizingMaskIntoConstraints = false
        currentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nomalLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            nomalLabel.topAnchor.constraint(equalTo: loverProfileImageView.bottomAnchor, constant: 34),
            nomalLabel.widthAnchor.constraint(equalToConstant: 87),
            nomalLabel.heightAnchor.constraint(equalToConstant: 19),
            
            currentDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            currentDateLabel.topAnchor.constraint(equalTo: nomalLabel.bottomAnchor, constant: 9),
            
            startDateLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            startDateLabel.topAnchor.constraint(equalTo: currentDateLabel.bottomAnchor, constant: 17),
            
            
        ])
    }
    
    private func dDayTableViewConstraint() {
        dDayTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dDayTableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            dDayTableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            dDayTableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 31),
            dDayTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }
    
}
