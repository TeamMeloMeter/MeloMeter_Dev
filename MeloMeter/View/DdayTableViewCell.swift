//
//  DdayTableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/04.
//

import UIKit

class DdayTableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "한강 불꽃놀이"
        label.textColor = UIColor.black
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2023.05.04"
        label.textColor = #colorLiteral(red: 0.5924944878, green: 0.5924944878, blue: 0.5924944878, alpha: 1)
        label.font = FontManager.shared.medium(ofSize: 12)
        return label
    }()
    
    let remainingDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "123일 남음"
        label.textColor = UIColor.black
        label.font = FontManager.shared.medium(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -262),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            
            remainingDaysLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
            remainingDaysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            
        ])
        
    }
}
