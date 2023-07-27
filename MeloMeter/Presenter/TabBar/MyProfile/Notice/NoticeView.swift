//
//  NoticeView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

//공지사항 View
import UIKit

class NoticeView: UIView {
   
    // 공지사항 리스트 tableView
    let noticeTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NoticeTableViewCell.self, forCellReuseIdentifier: "NoticeTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 108
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
        [noticeTableView].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        dDayTableViewConstraint()
    }
    
    private func dDayTableViewConstraint() {
        noticeTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            noticeTableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            noticeTableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            noticeTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            noticeTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}
