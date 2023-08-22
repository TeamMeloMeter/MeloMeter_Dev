//
//  HundredQATableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/08/22.
//

import UIKit

class HundredQATableViewCell: UITableViewCell {
    
    lazy var questionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = false
        view.layer.applyShadow(color: UIColor.gray2, alpha: 0.1, x: 0, y: 2, blur: 20)
        view.addSubview(numberLabel)
        view.addSubview(questionLabel)
        view.addSubview(newDotImage)
        return view
    }()
    
    let newDotImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "newDot")
        imageView.isHidden = true
        return imageView
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.semiBold(ofSize: 16)
        label.text = "13"
        return label
    }()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.medium(ofSize: 14)
        label.text = "가장 좋아하는 데이트 장소는 어디인가요?"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(questionView)
        backgroundColor = .white
        questionViewConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func questionViewConstraints() {
        questionView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        newDotImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            questionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            questionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            questionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            numberLabel.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 25),
            numberLabel.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),
            
            questionLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 25),
            questionLabel.centerYAnchor.constraint(equalTo: questionView.centerYAnchor),
            
            newDotImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            newDotImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 42),
            newDotImage.widthAnchor.constraint(equalToConstant: 6),
            newDotImage.heightAnchor.constraint(equalToConstant: 6)

        ])
            
    }
}
