//
//  AlarmTableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {
    
    lazy var alarmView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.addSubview(alarmTitleLabel)
        view.addSubview(alarmSubtitleLabel)
        view.addSubview(alarmImageView)
        return view
    }()
    
    let alarmTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "D-7"
        return label
    }()
    
    let alarmSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "00님의 생일까지 7일이 남았어요"
        return label
    }()
    
    let alarmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "alarmIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(alarmView)
        backgroundColor = .white
        alarmViewConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func alarmViewConstraints() {
        alarmView.translatesAutoresizingMaskIntoConstraints = false
        alarmTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alarmView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            alarmView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            alarmView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            alarmView.heightAnchor.constraint(equalToConstant: 82),

            alarmTitleLabel.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 64),
            alarmTitleLabel.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 14),
            alarmTitleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            alarmSubtitleLabel.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 64),
            alarmSubtitleLabel.bottomAnchor.constraint(equalTo: alarmView.bottomAnchor, constant: -11),
            alarmSubtitleLabel.heightAnchor.constraint(equalToConstant: 34),

            alarmImageView.leadingAnchor.constraint(equalTo: alarmView.leadingAnchor, constant: 18),
            alarmImageView.topAnchor.constraint(equalTo: alarmView.topAnchor, constant: 27),
            alarmImageView.widthAnchor.constraint(equalToConstant: 24),
            alarmImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
            
    }
}
