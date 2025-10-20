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
fileprivate let categoryIndex = ["전체":0, "맛집":1, "전시회": 2, "공원": 3, "기타" : 4]

class BottomSheetVC: UIViewController {
    
    
    init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var deletePicker = PublishSubject<Void>()
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
        self.largeView.isHidden = true
        self.informView.isHidden = true
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
            }.bind(onNext: { [weak self] tapped in
                guard let self else {return}
                categoryTapped.onNext(tapped)}).disposed(by: disposeBag)
            largeView.largeCategoryStack.addArrangedSubview(categoryView)
        }
        for i in 0 ..< 4 {
            let innerPicture = innerPictureView()
            innerPicture.tag = i
            innerPicture.rx.tapGesture().when(.recognized).map {
                self.presentImagePicker()
                return $0.view?.tag
            }.bind(onNext: { [weak self] tag in
                guard let self else {return}
                selectedImageTag.accept(tag)
            } ).disposed(by: disposeBag)
            largeView.largePictureStack.addArrangedSubview(innerPicture)
            innerPicture.snp.makeConstraints {
                $0.width.equalTo(64)
            }
        }
    }
    
    func setInformView(placeModel: CouplePlaceModel, imageExist: Bool) {
        self.largeView.isHidden = true
        self.smallView.isHidden = true
        informView.configure(placeModel: placeModel, imageExist: imageExist)
        view.addSubview(informView)
        informView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        view.bringSubviewToFront(grabbar)
    }
    
    func setBindings() {
        
        let pictureTapped = Observable.zip(selectedImageTag.asObservable(), selectedImage.asObservable())
        
        let output = viewModel.transform(input: MapVM.BottomSheetInput(
            dismissBottomSheet: largeView.xButton.rx.tap.asObservable(),categoryTapped: categoryTapped, pictureTapped: pictureTapped, loactionTFtexts: largeView.largeLocationTF.rx.textOrEmpty.asObservable(), memoTFtexts: largeView.largeMemoTF.rx.textOrEmpty.asObservable(), viewWillDisappear: self.rx.methodInvoked(#selector(viewWillDisappear(_:))).map { _ in }.asObservable(),
            largeSaveBtnTapped: largeView.largeSaveBtn.rx.tap.asObservable(),
            editBtnTapped:  informView.informSmallView.dropPickerView.edit.rx.tapGesture().when(.recognized).map { _ in
                var datas: [Data] = []
                let views = (self.informView.stackView.arrangedSubviews as? [UIImageView]) ?? []
                for view in views {
                    if let img = view.image {
                        datas.append(img.jpegData(compressionQuality: 1)!)
                    }
                }
                return datas
            }.asObservable(),
            deleteBtnTapped: informView.informSmallView.dropPickerView.delete.rx.tapGesture().when(.recognized).map { _ in }.asObservable(), threeDoutTapped: informView.informSmallView.rightBtn.rx.tapGesture().when(.recognized).map { _ in }.asObservable(), informViewTapped: self.rx
                .methodInvoked(#selector(UIView.touchesBegan(_:with:)))
                .flatMap { _ in self.view.endEditing(true)
                    return Observable.just(()) }.asObservable(), deletePicker: self.deletePicker.asObservable()),
                                         disposeBag: disposeBag)
        
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
            guard let self else {return}
            for i in 0 ..< array.count {
                let categoryView = self.largeView.largeCategoryStack.arrangedSubviews[i] as! CategoryView
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
        
        output.dropPickerIsHidden.bind(onNext: { [weak self] hidden in
            guard let self else {return}
            informView.informSmallView.dropPickerView.isHidden = hidden
        } ).disposed(by: disposeBag)
        
        output.alert
            .flatMap { [weak self] title, message in
                print("message \(title) \(message)")
                return AlertManager(viewController: self!)
                    .setTitle(title)
                    .setMessage(message)
                    .showYNAlert()
            }.subscribe(onNext: { [weak self] in
                guard let self else {return}
                self.deletePicker.onNext(())}).disposed(by: disposeBag)
        
        
      smallView.rightBtn.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
          guard let self else {return}
          setLargeBottomSheet()
      }).disposed(by: disposeBag)
      
        output.changeEditStyle.subscribe(onNext: { [weak self] model in
            guard let self else {return}
            largeView.largeMemoTF.rx.text.onNext(model.description)
            largeView.largeLocationTF.rx.text.onNext(model.name)
            largeView.largeMemoTF.sendActions(for: .editingChanged)
            largeView.largeLocationTF.sendActions(for: .editingChanged)
            categoryTapped.onNext(categoryIndex[model.category])
            self.setLargeBottomSheet()
        }).disposed(by: disposeBag)
        
        output.progressControl.subscribe(onNext: { [weak self] control in
            guard let self else {return}
            if control {
                ProgressDialogView.shared.show()
            } else {
                ProgressDialogView.shared.hide()

            }
        }).disposed(by: disposeBag)
        
    }
    func setLargeBottomSheet() {
        guard let sheet = self.sheetPresentationController else {return}
        let largeDetent = UISheetPresentationController.Detent.custom(identifier: .init("large")) { context in
            return 560 // 확장 높이
        }
        sheet.animateChanges {
            sheet.detents = [largeDetent]
            sheet.selectedDetentIdentifier = .init("large")
            self.smallView.isHidden = true
            self.informView.isHidden = true
            self.largeView.isHidden = false
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

