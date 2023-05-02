//
//  AlarmView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit

// 알림페이지 UI View
class AlarmView: UIView {
    
   
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
        [].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
    }
}
