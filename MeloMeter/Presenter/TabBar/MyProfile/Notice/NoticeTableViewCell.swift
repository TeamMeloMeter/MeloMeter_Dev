//
//  NoticeTableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/08.
//

import UIKit

//공지사항 테이블뷰 셀
class NoticeTableViewCell: UITableViewCell {
    
    // dot 이미지
    let dotImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "newDot")
        return imageView
    }()
    
    //공지사항 제목
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "안내"
        label.textColor = .gray2
        label.font = FontManager.shared.semiBold(ofSize: 14)
        return label
    }()
    
    let seperateLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray2
        return view
    }()
    
    // 공지사항 날짜
    let noticeDateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023년 08월 15일"
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    // 공지사항 내용
    let contentsLabel: UILabel = {
        let label = UILabel()
        label.text = "멜로미터에 오신 것을 환영합니다!"
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setConstraint()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraint() {
        contentView.addSubview(dotImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(seperateLine)
        contentView.addSubview(noticeDateLabel)
        contentView.addSubview(contentsLabel)
        dotImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seperateLine.translatesAutoresizingMaskIntoConstraints = false
        noticeDateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            dotImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            dotImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36),
            dotImageView.widthAnchor.constraint(equalToConstant: 7),
            dotImageView.heightAnchor.constraint(equalToConstant: 7),
            
            titleLabel.leadingAnchor.constraint(equalTo: dotImageView.trailingAnchor, constant: 7),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 31),
            
            seperateLine.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 9),
            seperateLine.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            seperateLine.widthAnchor.constraint(equalToConstant: 0.5),
            seperateLine.heightAnchor.constraint(equalToConstant: 13.5),
            
            noticeDateLabel.leadingAnchor.constraint(equalTo: seperateLine.trailingAnchor, constant: 10),
            noticeDateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 31),
            
            contentsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
        ])
        
    }
}
