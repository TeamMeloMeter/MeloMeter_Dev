//
//  AlarmView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

// 알림페이지 UI View
class AlarmView: UIView {
    //배경 뷰
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        
        return view
    }()
    // 알림 리스트 tableView
    let alarmTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: "AlarmTableViewCell")
        tableView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        tableView.rowHeight = 100
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
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
        [backgroundView, alarmTableView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        alarmTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            alarmTableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            alarmTableView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            alarmTableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            alarmTableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        ])
    }
}
