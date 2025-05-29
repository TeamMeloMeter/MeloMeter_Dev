//
//  MapSearchCell.swift
//  MeloMeter
//
//  Created by 양승완 on 5/21/25.
//

import Foundation
import UIKit

class MapSearchCell: UITableViewCell {
    static let reuseIdentifier = "LocationCell"

    // 1) 왼쪽 아이콘
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "pickedMarkerIcon")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 2) 오른쪽 텍스트 라벨
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // 초기화
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    // 뷰 계층 및 제약 설정
    private func setupLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // 1) 아이콘 크기 & 위치
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            // 2) 라벨 위치
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    // 외부에서 텍스트를 설정할 수 있는 메서드
    func configure(with title: String, icon: UIImage? = nil) {
        titleLabel.text = title
        if let icon = icon {
            iconImageView.image = icon
        }
    }
}
