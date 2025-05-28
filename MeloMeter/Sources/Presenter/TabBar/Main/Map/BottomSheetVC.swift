//
//  BottomSheetVC.swift
//  MeloMeter
//
//  Created by 양승완 on 5/21/25.
//

import Foundation
import UIKit
import RxSwift
import Kingfisher
import PhotosUI
import RxRelay

class BottomSheetVC: UIViewController {
    
    init(disposeBag: DisposeBag = DisposeBag(), viewModel: MapVM) {
        self.disposeBag = disposeBag
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var categoryTapped = PublishSubject<Int?>()
    
    private var selectedImage = BehaviorRelay<Data?>(value: nil)
    
    private var selectedImageTag = BehaviorRelay<Int?>(value: nil)
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: MapVM
    
    
    //MARK: First
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
    

    
    let smallView = UIView()
    
    let largeView = UIView().then {
        $0.isHidden = true
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setSmallView()
        setLargeView()
        setBindings()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func configure(pickedModel: SearchedModel) {
        locationNameLabel.text = pickedModel.title
        locationLabel.text = pickedModel.roadAddress
    }
    
    func setSmallView() {
        view.addSubview(smallView)
        
        smallView.addSubview(locationNameLabel)
        smallView.addSubview(locationLabel)
        smallView.addSubview(addbtn)
        
        smallView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        locationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(26)
            $0.trailing.leading.equalToSuperview().inset(18)
        }
        
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(locationNameLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(18)
        }
        
        addbtn.snp.makeConstraints {
            $0.width.height.equalTo(17)
            $0.top.equalToSuperview().inset(28)
            $0.trailing.equalToSuperview().inset(32)
        }
        
    }
    
    func setLargeView() {
        let innerCategoryTexts = ["전체", "맛집", "전시회", "공원", "기타"]
        
        for i in 0 ..< innerCategoryTexts.count {
            let categoryView = CategoryView()
            categoryView.configure(text: innerCategoryTexts[i])
            categoryView.tag = i
            categoryView.rx.tapGesture().when(.recognized).map{
                $0.view?.tag
            }.bind(to: categoryTapped).disposed(by: disposeBag)
            largeCategoryStack.addArrangedSubview(categoryView)
        }
        
        for i in 0 ..< 4 {
            let innerPicture = innerPictureView()
            innerPicture.tag = i
            innerPicture.rx.tapGesture().when(.recognized).map {
                self.presentImagePicker()
                return $0.view?.tag
            }.bind(to: selectedImageTag).disposed(by: disposeBag)
            largePictureStack.addArrangedSubview(innerPicture)
            innerPicture.snp.makeConstraints {
                $0.width.equalTo(64)
            }
        }
        
        view.addSubview(largeView)
        
        [largePictureLabel,largeCategoryLabel,largeMemoLabel,largeLocationLabel].forEach {
            largeView.addSubview($0)
            $0.font = FontManager.shared.semiBold(ofSize: 15)
        }
        [xButton, largePictureStack,largeCategoryStack,largeSaveBtn].forEach {
            largeView.addSubview($0)
        }
        
        [largeMemoTF,largeLocationTF].forEach {
            largeView.addSubview($0)
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.leftView = leftPaddingView
            $0.leftViewMode = .always

            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            $0.rightView = rightPaddingView
            $0.rightViewMode = .always
        }
                
        
        largeView.snp.makeConstraints {
            $0.bottom.top.leading.trailing.equalToSuperview().inset(16)
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
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(52)
        }
        
        
    }
    
    func setBindings() {
        
        self.rx
              .methodInvoked(#selector(UIView.touchesBegan(_:with:)))
              .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
              })
              .disposed(by: disposeBag)
        
        let pictureTapped = Observable.zip(selectedImageTag.asObservable(), selectedImage.asObservable())
        
        let output = viewModel.transform(input: MapVM.BottomSheetInput(dismissBottomSheet: xButton.rx.tap.asObservable(), categoryTapped: categoryTapped, pictureTapped:
                                                                        pictureTapped, loactionTFtexts: largeLocationTF.rx.textOrEmpty.asObservable(), memoTFtexts: largeMemoTF.rx.textOrEmpty.asObservable(), viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:))).map { _ in }.asObservable(), largeSaveBtnTapped:largeSaveBtn.rx.tap.map { _ in }.asObservable()
                                                                      ), disposeBag: disposeBag)
        
        output.btnEnabled.bind(onNext: { [weak self] val in
            guard let self else {return}
            self.largeSaveBtn.isEnabled = val
            if val {
                self.largeSaveBtn.backgroundColor = .primary1
            } else {
                self.largeSaveBtn.backgroundColor = .gray4

            }
            
        }).disposed(by: disposeBag)
        
        output.categoryIsSelected.subscribe(onNext: { [weak self] array in
            for i in 0 ..< array.count {
                let categoryView = self?.largeCategoryStack.arrangedSubviews[i] as! CategoryView
                if array[i] {
                    categoryView.backgroundColor = .primary1
                    categoryView.layer.borderColor = UIColor.primary1.cgColor
                    categoryView.label.textColor = .white
                } else {
                    categoryView.backgroundColor = .clear
                    categoryView.layer.borderColor = UIColor.gray45.cgColor
                    categoryView.label.textColor = .black
                }
            }
        }).disposed(by: disposeBag)
        
        output.pictureValues.subscribe(onNext: { [weak self] datas in
            guard let self else {return}
            print(datas)
            for idx in 0 ..< 4 {
                let view = self.largePictureStack.arrangedSubviews[idx] as! innerPictureView
                if idx < datas.count {
                    view.imageView.image = UIImage(data: datas[idx])
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
            if datas.count < 4 {
                let view = self.largePictureStack.arrangedSubviews[datas.count] as! innerPictureView
                view.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        
        if #available(iOS 16.0, *) {
            addbtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
                guard let self, let sheet = self.sheetPresentationController else {return}
                let largeDetent = UISheetPresentationController.Detent.custom(identifier: .init("large")) { context in
                    return 560 // 확장 높이
                }
                sheet.animateChanges {
                    sheet.detents = [largeDetent]
                    sheet.selectedDetentIdentifier = .init("large")
                    
                    self.smallView.isHidden = true
                    self.largeView.isHidden = false
                    
                }
                
            }).disposed(by: disposeBag)
        } else {
            // Fallback on earlier versions
        }
    }
}
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
extension BottomSheetVC :PHPickerViewControllerDelegate {
   func presentImagePicker() {
       var config = PHPickerConfiguration()
       config.selectionLimit = 1
       config.filter = .images
       let picker = PHPickerViewController(configuration: config)
       picker.delegate = self
       present(picker, animated: true)
   }

   func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       picker.dismiss(animated: true)

       guard let itemProvider = results.first?.itemProvider,
             itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

       itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
           guard let self ,let uiImage = image as? UIImage else { return }
           DispatchQueue.main.async {
               if let jpegData = uiImage.jpegData(compressionQuality: 0.6) {
                   self.selectedImage.accept(jpegData)
               }
           }
       }
   }
}
