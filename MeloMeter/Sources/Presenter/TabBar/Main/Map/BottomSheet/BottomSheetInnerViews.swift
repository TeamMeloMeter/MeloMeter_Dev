//
//  BottomSheetInnerViews.swift
//  MeloMeter
//
//  Created by 양승완 on 5/29/25.
//

import Foundation
import UIKit
import Kingfisher
import RxSwift
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
    private let addImg = UIImageView(image: UIImage(named: "addIcon")).then {
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
            $0.height.width.equalTo(24)
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
    
    private var disposeBag = DisposeBag()

    
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
        rightBtn.image = UIImage(named: "addIcon")
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
        $0.contentMode = .scaleAspectFill
    }
    let locationNameLabel = UILabel().then {
        $0.font = FontManager.shared.bold(ofSize: 18)
    }
    let locationLabel = UILabel().then {
        $0.font = FontManager.shared.medium(ofSize: 16)
        $0.textColor = .lightGray
        $0.numberOfLines = 2
    }
    let dropPickerView = DropPickerView().then {
        $0.isHidden = true
    }
    
    func setUI() {
        self.addSubview(locationNameLabel)
        self.addSubview(locationLabel)
        self.addSubview(descriptionLabel)
        
        self.addSubview(rightBtn)
        self.addSubview(dropPickerView)
        
        self.addSubview(catrgoryLabel)
        self.addSubview(dateLabel)
        
        dropPickerView.layer.shadowColor = UIColor.gray1.cgColor
        dropPickerView.layer.shadowOpacity = 0.4
        dropPickerView.layer.shadowRadius = 10
        dropPickerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        dropPickerView.layer.shadowPath = nil
        
        
        locationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(18)
            $0.width.lessThanOrEqualTo(170)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(18)
        }
        
        rightBtn.snp.makeConstraints {
            $0.width.height.equalTo(44)
            $0.centerY.equalTo(locationNameLabel).offset(-4)
            $0.trailing.equalToSuperview().inset(18)
        }
        catrgoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(locationNameLabel)
            $0.leading.equalTo(locationNameLabel.snp.trailing).offset(13)
        }
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(catrgoryLabel)
            $0.leading.equalTo(catrgoryLabel.snp.trailing).offset(13)
        }
        dropPickerView.snp.makeConstraints {
            $0.trailing.equalTo(rightBtn).inset(10)
            $0.width.equalTo(68)
            $0.height.equalTo(94)
            $0.top.equalTo(rightBtn.snp.bottom).offset(-12)
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
    var largePictureStack = UIStackView().then {
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
    
    func setupPages(imageUrls: [URL]) {
        for (index, i) in imageUrls.enumerated() {
            (largePictureStack.arrangedSubviews[index] as! UIImageView).kf.setImage(
                with: i,  // 이미지 불러올 url
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.none),
                    .cacheOriginalImage
                ])
            
        }
    }
    
}
class BottomSheetinformView: UIView, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(page)
    }
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var pageCount = 0
    
    private let scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    private let pageControl = UIPageControl()
    
    let informSmallView = BottomSheetSmallView()
    
    func configure(placeModel: CouplePlaceModel, imageExist: Bool) {
        var imageViewH = 12
        if imageExist {
            pageCount = placeModel.imageURLs!.count
            imageViewH = 160
        }
        scrollView.delegate = self
        informSmallView.configureCouplePlaceModel(placeModel: placeModel)
        self.addSubview(scrollView)
        self.addSubview(informSmallView)
        scrollView.addSubview(stackView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageViewH)
        }
        stackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.height.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(pageCount)
            
        }
        informSmallView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        guard let imageUrls = placeModel.imageURLs else {
            return
        }
        setupPages(imageUrls: imageUrls.compactMap { URL(string: $0)})
        setupPageControl()
        
        
        
    }
    private func setupPages(imageUrls: [URL]) {
        for i in imageUrls {
            let page = UIImageView()
            page.kf.indicatorType = .activity  // indicator 활성화
            page.kf.setImage(
                with: i,  // 이미지 불러올 url
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.none),
                    .cacheOriginalImage
                ])
            stackView.addArrangedSubview(page)
        }
    }
    private func setupPageControl() {
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        
        self.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(scrollView.snp.bottom).inset(6)
            $0.centerX.equalToSuperview()
        }
    }
}
class DropPickerView: UIView {
    
    let edit = UILabel().then { $0.text = "수정"; $0.font = FontManager.shared.medium(ofSize: 15)}
    let delete = UILabel().then { $0.text = "삭제";  $0.font = FontManager.shared.medium(ofSize: 15)}
    lazy var stackView = UIStackView(arrangedSubviews: [ edit, delete ]).then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 0
        $0.alignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
