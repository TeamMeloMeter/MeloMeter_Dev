//
//  BottomSheetVC.swift
//  MeloMeter
//
//  Created by 양승완 on 5/21/25.
//

import Foundation
import UIKit
import RxSwift

class BottomSheetVC: UIViewController {
    
    
    private var disposeBag = DisposeBag()
    
    let addbtn = UIImageView().then {
        $0.image = UIImage(systemName: "plus")
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
    
    let locationNameLabel = UILabel().then {
        $0.font = FontManager.shared.bold(ofSize: 18)
    }
    
    let locationLabel = UILabel().then {
        $0.font = FontManager.shared.medium(ofSize: 16)
        $0.textColor = .lightGray
    }
    
    func configure(pickedModel: SearchedModel) {
        locationNameLabel.text = pickedModel.title
        locationLabel.text = pickedModel.roadAddress
    }
    
    
    func dismissThisView() {
        self.dismiss(animated: true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setBindings()
        setAutoLayout()
    }
    
    
    func setAutoLayout() {
        view.addSubview(locationNameLabel)
        view.addSubview(locationLabel)
        view.addSubview(addbtn)
        locationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.leading.equalToSuperview().inset(18)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationNameLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(18)
        }
        
        addbtn.snp.makeConstraints {
            $0.width.height.equalTo(17)
            $0.top.equalToSuperview().inset(28)
            $0.trailing.equalToSuperview().inset(32)
        }
        
    }
    
    func setBindings() {
        if #available(iOS 16.0, *) {
            addbtn.rx.tapGesture().when(.recognized).subscribe(onNext: { _ in
                

                guard let sheet =  self.sheetPresentationController else {return}
                let largeDetent = UISheetPresentationController.Detent.custom(identifier: .init("large")) { context in
                    return 560 // 확장 높이
                }
                sheet.animateChanges {
                    sheet.detents = [largeDetent]
                    sheet.selectedDetentIdentifier = .init("large")
                }
                
            }).disposed(by: disposeBag)
        } else {
            // Fallback on earlier versions
        }
    }
  

}
