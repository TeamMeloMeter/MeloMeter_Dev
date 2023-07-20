//
//  ProgressDialogView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/20.
//

import UIKit
class ProgressDialogView: UIView {
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
        
    }
    func setup() {
        self.addSubview(activityIndictor)
        activityIndictor.startAnimating()
        
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = self.superview {
            let width = superview.frame.size.width
            let height = superview.frame.size.height
            self.frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.5)
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: width / 2 - activityIndicatorSize / 2, y: height / 2 - activityIndicatorSize / 2, width: activityIndicatorSize, height: activityIndicatorSize)
            layer.masksToBounds = true
        }
    }
    func show() {
        self.isHidden = false
    }
    func hide() {
        self.isHidden = true
    }
}

