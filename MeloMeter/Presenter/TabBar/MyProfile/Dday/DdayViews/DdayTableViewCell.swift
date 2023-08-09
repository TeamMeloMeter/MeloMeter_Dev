//
//  DdayTableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/04.
//

import UIKit

class DdayTableViewCell: UITableViewCell {

    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 16)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray2
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
    }()
    
    let remainingDaysLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(remainingDaysLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingDaysLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            
            remainingDaysLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
            remainingDaysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            
        ])
        
    }
}
