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
    
    let informView = BottomSheetinformView()
    
    let smallView = BottomSheetSmallView()
    
    let largeView = BottomSheetLargeView().then {
        $0.isHidden = true
    }
    let grabbar = UIImageView(image: UIImage(named: "grabbar"))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        //TODO: cycle 보면서 smallView 로드시에만 로드시키게.
        setLargeView()
        
        setBindings()
        setGrabbar()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setGrabbar() {
        view.addSubview(grabbar)
        grabbar.snp.makeConstraints {
            $0.top.equalTo(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(3)
            $0.width.equalTo(46)
        }
    }
    
    func setSmallView(pickedModel: SearchedModel) {
        smallView.configurePickedModel(pickedModel: pickedModel)
        view.addSubview(smallView)
        smallView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
  
    
    func setLargeView() {
        view.addSubview(largeView)
        largeView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        let innerCategoryTexts = ["전체", "맛집", "전시회", "공원", "기타"]
        
        for i in 0 ..< innerCategoryTexts.count {
            let categoryView = CategoryView()
            categoryView.configure(text: innerCategoryTexts[i])
            categoryView.tag = i
            categoryView.rx.tapGesture().when(.recognized).map{
                $0.view?.tag
            }.bind(to: categoryTapped).disposed(by: disposeBag)
            largeView.largeCategoryStack.addArrangedSubview(categoryView)
        }
        for i in 0 ..< 4 {
            let innerPicture = innerPictureView()
            innerPicture.tag = i
            innerPicture.rx.tapGesture().when(.recognized).map {
                self.presentImagePicker()
                return $0.view?.tag
            }.bind(to: selectedImageTag).disposed(by: disposeBag)
            largeView.largePictureStack.addArrangedSubview(innerPicture)
            innerPicture.snp.makeConstraints {
                $0.width.equalTo(64)
            }
        }
    }
    
 
    func setInformView(placeModel: CouplePlaceModel, imageExist: Bool) {
        informView.configure(placeModel: placeModel, imageExist: imageExist)
        view.addSubview(informView)
        informView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        view.bringSubviewToFront(grabbar)
        
       
    }
    
    func setBindings() {
        self.rx
              .methodInvoked(#selector(UIView.touchesBegan(_:with:)))
              .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
              })
              .disposed(by: disposeBag)
        
        let pictureTapped = Observable.zip(selectedImageTag.asObservable(), selectedImage.asObservable())
        
        let output = viewModel.transform(input: MapVM.BottomSheetInput(dismissBottomSheet: largeView.xButton.rx.tap.asObservable(), categoryTapped: categoryTapped, pictureTapped:
                                                                        pictureTapped, loactionTFtexts: largeView.largeLocationTF.rx.textOrEmpty.asObservable(), memoTFtexts: largeView.largeMemoTF.rx.textOrEmpty.asObservable(), viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:))).map { _ in }.asObservable(), largeSaveBtnTapped: largeView.largeSaveBtn.rx.tap.map { _ in }.asObservable()
                                                                       ,editBtnTapped:  informView.informSmallView.dropPickerView.delete.rx.tapGesture().when(.recognized).map { _ in }.asObservable(), deleteBtnTapped: informView.informSmallView.dropPickerView.delete.rx.tapGesture().when(.recognized).map { _ in }.asObservable()), disposeBag: disposeBag)
        
        output.btnEnabled.bind(onNext: { [weak self] val in
            guard let self else {return}
            largeView.largeSaveBtn.isEnabled = val
            if val {
                largeView.largeSaveBtn.backgroundColor = .primary1
            } else {
                largeView.largeSaveBtn.backgroundColor = .gray4

            }
            
        }).disposed(by: disposeBag)
        
        output.categoryIsSelected.subscribe(onNext: { [weak self] array in
            for i in 0 ..< array.count {
                let categoryView = self?.largeView.largeCategoryStack.arrangedSubviews[i] as! CategoryView
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
                let view = largeView.largePictureStack.arrangedSubviews[idx] as! innerPictureView
                if idx < datas.count {
                    view.imageView.image = UIImage(data: datas[idx])
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
            if datas.count < 4 {
                let view = largeView.largePictureStack.arrangedSubviews[datas.count] as! innerPictureView
                view.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        
        if #available(iOS 16.0, *) {
            smallView.rightBtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
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

