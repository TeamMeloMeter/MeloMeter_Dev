//
//  ProgressDialogView.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/20.
//

import UIKit
class ProgressDialogView: UIView {
    static let shared = ProgressDialogView()
    
    private var overlayView: UIView?
    
    func show() {
        guard overlayView == nil else { return }
        
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        
        let overlay = UIView(frame: window?.bounds ?? .zero)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let activityIndicator = UIActivityIndicatorView(style: .medium )
        let activityIndicatorSize: CGFloat = 40
        activityIndicator.center = overlay.center
        
        activityIndicator.startAnimating()
        overlay.addSubview(activityIndicator)
        
        window?.addSubview(overlay)
        overlayView = overlay
    }
    
    func hide() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}

