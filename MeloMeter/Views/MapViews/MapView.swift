//
//  MapViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit
import NMapsMap

// Map UI View
class MapView: UIView {
    
    lazy var naverMapView: NMFMapView = {
        let view = NMFMapView()
        view.allowsZooming = true // 줌 가능
        view.logoInteractionEnabled = false // 로고 터치 불가능
        view.allowsScrolling = true // 스크롤 가능
        return view
    }()
    
    //내 위치 마커
    var myMarker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        return marker
    }()
    
    let myMarkerIcon: UIImage = {
        let image1 = UIImage(named: "myMarkerBorder")
        let image2 = UIImage(named: "myMarkerDot")
        let image3 = UIImage(named: "profileTest")
        
        let imageSize = CGSize(width: 80, height: 107)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        
        image1?.draw(in: CGRect(x: 0, y: 0, width: 80, height: 90))
        image2?.draw(in: CGRect(x: 31, y: 89, width: 18, height: 18))
        image3?.draw(in: CGRect(x: 7, y: 7, width: 66, height: 66))
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = compositeImage {
            return image
        }
        return UIImage(named: "myMarkerDot")!
    
    }()
    
    let myInfoWindowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 141, height: 43))
        label.text = "오늘 기분 최고:)"
        label.textColor = .black
        label.textAlignment = .center
        label.font = FontManager.shared.regular(ofSize: 16)
        label.backgroundColor = .white
        label.layer.borderColor = #colorLiteral(red: 0.9843137255, green: 0.3607843137, blue: 0.9960784314, alpha: 1)
        label.layer.borderWidth = 1.0
        label.clipsToBounds = true
        label.layer.cornerRadius = 20
        return label
    }()
    
    let dDayButton: UIButton = {
        let button = UIButton()
        button.setTitle("D-55", for: .normal)
        button.setTitleColor(UIColor.gray1, for: .normal)
        button.titleLabel?.font = FontManager.shared.regular(ofSize: 18)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        return button
    }()
    
    let alarmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "alarmIcon"), for: .normal)
        
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 24
        button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        return button
    }()
    
    let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "myPositionIcon"), for: .normal)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 24
        button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        return button
    }()
    
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
        [naverMapView, alarmButton, dDayButton, currentLocationButton].forEach { addSubview($0) }
    }
    
    private func setConstraints() {
        mapViewConstraint()
        mapViewElementConstraint()
    }
    
    private func mapViewConstraint() {
        naverMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            naverMapView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            naverMapView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            naverMapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            naverMapView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func mapViewElementConstraint() {
        dDayButton.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dDayButton.centerXAnchor.constraint(equalTo: naverMapView.centerXAnchor),
            dDayButton.topAnchor.constraint(equalTo: naverMapView.topAnchor, constant: 17),
            dDayButton.widthAnchor.constraint(equalToConstant: 86),
            dDayButton.heightAnchor.constraint(equalToConstant: 48),
            
            alarmButton.trailingAnchor.constraint(equalTo: naverMapView.trailingAnchor, constant: -16),
            alarmButton.topAnchor.constraint(equalTo: naverMapView.topAnchor, constant: 17),
            alarmButton.widthAnchor.constraint(equalToConstant: 48),
            alarmButton.heightAnchor.constraint(equalToConstant: 48),

            currentLocationButton.trailingAnchor.constraint(equalTo: naverMapView.trailingAnchor, constant: -16),
            currentLocationButton.bottomAnchor.constraint(equalTo: naverMapView.bottomAnchor, constant: -16),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 48),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    
    
}
