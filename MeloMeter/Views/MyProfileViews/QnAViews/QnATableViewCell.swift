//
//  QnATableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/09.
//

import UIKit

//자주묻는 질문 테이블뷰 셀
class QnATableViewCell: UITableViewCell {
    
    
    //질문내용
    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 인증이 뭔가요?"
        label.textColor = .black
        label.font = FontManager.shared.medium(ofSize: 16)
        return label
    }()
    
    //화살표 > 이미지
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowIcon")
        imageView.contentMode = .right
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.frame.size = CGSize(width: 18, height: 18)
        return imageView
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
        contentView.addSubview(questionLabel)
        contentView.addSubview(arrowImageView)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            questionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            questionLabel.widthAnchor.constraint(equalToConstant: 300),
            questionLabel.heightAnchor.constraint(equalToConstant: 19),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 18),
            arrowImageView.heightAnchor.constraint(equalToConstant: 18),

        ])
        
    }
}
