//
//  MyProfileTableViewCell.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/04/28.
//

import UIKit

// 마이페이지의 공지사항, 자주묻는 질문, 정보 란 TableView에 들어갈 Cell
class MyProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var arrowLable: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
