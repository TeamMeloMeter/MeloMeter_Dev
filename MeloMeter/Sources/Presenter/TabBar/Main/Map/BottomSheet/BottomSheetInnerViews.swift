//
//  BottomSheetInnerViews.swift
//  MeloMeter
//
//  Created by 양승완 on 5/29/25.
//

import Foundation
import UIKit
class CategoryView: UIView {
    let label = UILabel().then {
        $0.font = FontManager.shared.regular(ofSize: 16)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 18
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(text: String) {
        label.text = text
    }
}
class innerPictureView: UIView {
    private let addImg = UIImageView().then {
        $0.image = UIImage(systemName: "plus")
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .gray2
    }
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(addImg)
        self.addSubview(imageView)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        
        self.snp.makeConstraints {
            $0.width.height.equalTo(64)
        }
        
        addImg.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(17)
        }
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class BottomSheetSmallView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configurePickedModel(pickedModel: SearchedModel) {
        locationNameLabel.text = pickedModel.title
        locationLabel.text = pickedModel.roadAddress
        rightBtn.image = UIImage(systemName: "plus")
        catrgoryLabel.isHidden = true
        dateLabel.isHidden = true
        descriptionLabel.isHidden = true
        
    }
    func configureCouplePlaceModel(placeModel: CouplePlaceModel) {
        locationNameLabel.text = placeModel.name
        locationLabel.text = placeModel.roadAddress
        catrgoryLabel.text = placeModel.category
        dateLabel.text = placeModel.createdAt ?? ""
        descriptionLabel.text = placeModel.description
        rightBtn.image = UIImage(named: "threeDout")
        
        catrgoryLabel.isHidden = false
        descriptionLabel.isHidden = false
        dateLabel.isHidden = false
        
    }
    let descriptionLabel = UILabel().then {
        $0.textColor = .gray3
        $0.font = FontManager.shared.medium(ofSize: 16)
        $0.numberOfLines = 2
    }
    let catrgoryLabel = UILabel().then {
        $0.textColor = .primary1
        $0.font = FontManager.shared.semiBold(ofSize: 16)
        $0.numberOfLines = 2
    }
    let dateLabel = UILabel().then {
        $0.textColor = .gray3
        $0.font = FontManager.shared.medium(ofSize: 16)
    }
    
    let rightBtn = UIImageView().then {
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    let locationNameLabel = UILabel().then {
        $0.font = FontManager.shared.bold(ofSize: 18)
    }
    let locationLabel = UILabel().then {
        $0.font = FontManager.shared.medium(ofSize: 16)
        $0.textColor = .lightGray
    }
    func setUI() {
        self.addSubview(locationNameLabel)
        self.addSubview(locationLabel)
        self.addSubview(rightBtn)
        
        self.addSubview(catrgoryLabel)
        self.addSubview(dateLabel)
        self.addSubview(descriptionLabel)
        
        locationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.leading.equalToSuperview().inset(18)
            $0.width.lessThanOrEqualTo(100)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(18)
        }
        
        rightBtn.snp.makeConstraints {
            $0.width.height.equalTo(17)
            $0.centerY.equalTo(locationNameLabel)
            $0.trailing.equalToSuperview().inset(32)
        }   
        catrgoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(locationNameLabel)
            $0.leading.equalTo(locationNameLabel.snp.trailing).offset(13)
        }
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(catrgoryLabel)
            $0.leading.equalTo(catrgoryLabel.snp.trailing).offset(13)
        }
    }
}

class BottomSheetLargeView: UIView {
    
    let largeLocationLabel = UILabel().then {
        $0.text = "장소"
    }
    let largeMemoLabel = UILabel().then {
        $0.text = "메모"
    }
    let largeCategoryLabel = UILabel().then {
        $0.text = "카테고리"
    }
    let largePictureLabel = UILabel().then {
        $0.text = "사진"
    }
    let largeLocationTF = UITextField().then  {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
        $0.placeholder = "장소 이름"
    }
    let largeMemoTF = UITextField().then  {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 8
        $0.placeholder = "장소에 대한 짧은 메모를 남겨주세요."
    }
    let largeCategoryStack = UIStackView().then {
        $0.distribution = .fillEqually
        $0.spacing = 10
        $0.axis = .horizontal
        $0.alignment = .fill
    }
    let largePictureStack = UIStackView().then {
        $0.alignment = .center
        $0.spacing = 14
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    var largeSaveBtn = UIButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = FontManager.shared.extraBold(ofSize: 14)
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = false
        $0.backgroundColor = .gray4
    }
    let xButton = UIButton().then {
        $0.setImage(UIImage(named: "xmark"), for: .normal)
        $0.contentHorizontalAlignment = .center
        $0.contentVerticalAlignment = .center
    }
    override init(frame:CGRect) {
        super.init(frame: frame)
        setUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        [largePictureLabel,largeCategoryLabel,largeMemoLabel,largeLocationLabel].forEach {
            self.addSubview($0)
            $0.font = FontManager.shared.semiBold(ofSize: 15)
        }
        [xButton, largePictureStack,largeCategoryStack,largeSaveBtn].forEach {
            self.addSubview($0)
        }
        [largeMemoTF,largeLocationTF].forEach {
            self.addSubview($0)
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.leftView = leftPaddingView
            $0.leftViewMode = .always

            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.rightView = rightPaddingView
            $0.rightViewMode = .always
        }
        xButton.snp.makeConstraints {
            $0.centerY.equalTo(largeLocationLabel).offset(-6)
            $0.height.width.equalTo(48)
            $0.trailing.equalTo(6)
        }
        largeLocationLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        largeLocationTF.snp.makeConstraints {
            $0.top.equalTo(largeLocationLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        largeMemoLabel.snp.makeConstraints {
            $0.top.equalTo(largeLocationTF.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        largeMemoTF.snp.makeConstraints {
            $0.top.equalTo(largeMemoLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        largeCategoryLabel.snp.makeConstraints {
            $0.top.equalTo(largeMemoTF.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        largeCategoryStack.snp.makeConstraints {
            $0.top.equalTo(largeCategoryLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        largePictureLabel.snp.makeConstraints {
            $0.top.equalTo(largeCategoryStack.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }
        
        largePictureStack.snp.makeConstraints {
            $0.top.equalTo(largePictureLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.height.equalTo(64)
        }
        largeSaveBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(52)
        }
    }
    
}
