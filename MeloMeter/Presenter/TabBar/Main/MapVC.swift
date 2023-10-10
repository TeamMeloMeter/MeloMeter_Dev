//
//  MapViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit
import NMapsMap
import RxCocoa
import RxSwift
import CoreLocation

//메인 지도 화면
class MapVC: UIViewController, UIGestureRecognizerDelegate{

    let infoWindow1 = NMFInfoWindow()
    let infoWindow2 = NMFInfoWindow()
    var endTriggerAlertEvent = PublishSubject<Void>()
    private var viewModel: MapVM?
    let disposeBag = DisposeBag()
    
    init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMarker()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: Binding
    func setBindings() {
        let input = MapVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            dDayBtnTapEvent: self.dDayButton.rx.tap
                .map({ _ in })
                .asObservable(),
            alarmBtnTapEvent: self.alarmButton.rx.tap
                .map({ _ in })
                .asObservable(),
            endTriggerAlertTapEvent: self.endTriggerAlertEvent
                .asObserver()
        )
            
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.daySince
            .bind(onNext: { text in
                self.dDayLabel.text = text
            })
            .disposed(by: disposeBag)
        
        output.myProfileImage
            .asDriver(onErrorJustReturn: UIImage(named: "defaultProfileImage"))
            .drive(onNext: { image in
                if let myImage = image {
                    self.changedMarkerIcon(isMine: true, profileImage: myImage)
                }else {
                    self.changedMarkerIcon(isMine: true, profileImage: UIImage(named: "defaultProfileImage")!)
                }
            })
            .disposed(by: disposeBag)
        
        output.otherProfileImage
            .asDriver(onErrorJustReturn: UIImage(named: "defaultProfileImage"))
            .drive(onNext: { image in
                if let otherImage = image {
                    self.changedMarkerIcon(isMine: false, profileImage: otherImage)
                }else {
                    self.changedMarkerIcon(isMine: false, profileImage: UIImage(named: "defaultProfileImage")!)
                }
            })
            .disposed(by: disposeBag)
        
        output.myStateMessage
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: {[weak self] text in
                guard let self = self else { return }
                if let message = text {
                    if message == "" {
                        self.myInfoWindowLabel.text = text
                        self.infoWindow1.close()
                    }else {
                        self.myInfoWindowLabel.text = message
                        self.myInfoWindowLabel.layoutIfNeeded()
                        self.myInfoWindowView.layoutIfNeeded()
                        self.infoWindow1.open(with: self.myMarker)
                    }
                }else {
                    self.myInfoWindowLabel.text = text
                    self.infoWindow1.close()
                }
            })
            .disposed(by: disposeBag)

        output.otherStateMessage
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: {[weak self] text in
                guard let self = self else { return }
                if let message = text {
                    if message == "" {
                        self.otherInfoWindowLabel.text = text
                        self.infoWindow2.close()
                    }else {
                        self.otherInfoWindowLabel.text = message
                        self.otherInfoWindowLabel.layoutIfNeeded()
                        self.otherInfoWindowView.layoutIfNeeded()
                        self.infoWindow2.open(with: self.otherMarker)
                    }
                } else {
                    self.otherInfoWindowLabel.text = text
                    self.infoWindow2.close()
                }
            })
            .disposed(by: disposeBag)
        
        output.authorizationAlertShouldShow
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] shouldShowAlert in
                guard let self = self else{ return }
                if shouldShowAlert {
                    AlertManager(viewController: self)
                        .setLocationAlert()
                }
            })
            .disposed(by: disposeBag)
        
        output.currentLocation
            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
            .drive(onNext: { [weak self] current in
                self?.updateMyMarker(current ?? CLLocation(latitude: 0, longitude: 0))
            })
            .disposed(by: disposeBag)
        
        output.currentLocation
            .take(1)
            .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
            .drive(onNext: { [weak self] current in
                self?.updateCamera(current ?? CLLocation(latitude: 0, longitude: 0))
            })
            .disposed(by: disposeBag)
        
        output.currentOtherLocation
            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
            .drive(onNext: { [weak self] current in
                self?.updateOtherMarker(current ?? CLLocation(latitude: 0, longitude: 0))
            })
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .subscribe(onNext: {[weak self] _ in
                guard let self = self else{ return }
                let current = CLLocation(latitude: myMarker.position.lat, longitude: myMarker.position.lng)
                self.updateCamera(current)
            })
            .disposed(by: disposeBag)
        
        output.endTrigger
            .subscribe(onNext: { trig in
                if trig {
                    self.endTriggerAlert()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: Map
    func updateMyMarker(_ location: CLLocation) {
        myMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        myMarker.mapView = naverMapView
    }
    
    func updateOtherMarker(_ location: CLLocation) {
        otherMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        otherMarker.mapView = naverMapView
    }
    
    func updateCamera(_ location: CLLocation) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        cameraUpdate.animation = .easeIn
        naverMapView.moveCamera(cameraUpdate)
    }

    // MARK: Configure
    func configure() {
        [naverMapView,
         currentLocationButton,
         dDayButton,
         alarmButton].forEach { view.addSubview($0) }
        view.sendSubviewToBack(naverMapView)
    }
    
    // MARK: Event
    func endTriggerAlert() {
        AlertManager(viewController: self)
            .showNomalAlert(title: "연결 종료",
                            message: """
                                    상대방과의 연결이 종료되었습니다.
                                    새로운 커플 연결을 통해
                                    멜로미터를 다시 이용하실 수
                                    있습니다.
                                    """
            )
            .subscribe(onSuccess: {
                self.endTriggerAlertEvent.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func changedMarkerIcon(isMine: Bool, profileImage: UIImage) {
        let imageName = isMine ? "myMarker" : "otherMarker"
        let icon: UIImage = {
            let image1 = UIImage(named: "\(imageName)border")
            let image2 = UIImage(named: "\(imageName)Dot")
            let imageSize = CGSize(width: 80, height: 107)
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
            
            image1?.draw(in: CGRect(x: 0, y: 0, width: 80, height: 90))
            image2?.draw(in: CGRect(x: 31, y: 89, width: 18, height: 18))
            
            let size = CGSize(width: 66, height: 66)
            let roundedProfileImage = UIGraphicsImageRenderer(size: size).image { _ in
                UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: size.width / 2).addClip()
                profileImage.draw(in: CGRect(origin: .zero, size: size))
            }
            roundedProfileImage.draw(in: CGRect(x: 7, y: 7, width: 66, height: 66))

            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            if let image = compositeImage {
                return image
            }
            return UIImage(named: "\(imageName)Dot")!
        }()
        
        if isMine {
            myMarker.iconImage = NMFOverlayImage(image: icon)
        }else {
            otherMarker.iconImage = NMFOverlayImage(image: icon)
        }
    }
    
    // MARK: navigationBar
    func setNavigationBar() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // MARK: UI
    
    /// 마커 아이콘, 상태메세지 정보창 설정
    func setMarker() {
        myMarker.iconImage = NMFOverlayImage(image: myMarkerIcon)
        let dataSource1 = CustomInfoViewDataSource(customView: myInfoWindowView)
        infoWindow1.offsetY = 5
        infoWindow1.dataSource = dataSource1
        otherMarker.iconImage = NMFOverlayImage(image: otherMarkerIcon)
        let dataSource2 = CustomInfoViewDataSource(customView: otherInfoWindowView)
        infoWindow2.offsetY = 5
        infoWindow2.dataSource = dataSource2
    }
    
    lazy var naverMapView: NMFMapView = {
        let view = NMFMapView()
        view.allowsZooming = true
        view.logoInteractionEnabled = false
        view.allowsScrolling = true
        return view
    }()
    
    var myMarker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        return marker
    }()
    
    let myMarkerIcon: UIImage = {
        let image1 = UIImage(named: "myMarkerborder")
        let image2 = UIImage(named: "myMarkerDot")
        let defaultProfileImage = UIImage(named: "defaultProfileImage")!

        let imageSize = CGSize(width: 80, height: 107)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)

        image1?.draw(in: CGRect(x: 0, y: 0, width: 80, height: 90))
        image2?.draw(in: CGRect(x: 31, y: 89, width: 18, height: 18))
        defaultProfileImage.draw(in: CGRect(x: 7, y: 7, width: 66, height: 66))
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        if let image = compositeImage {
            return image
        }
        return UIImage(named: "myMarkerDot")!

    }()
    lazy var myInfoWindowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = #colorLiteral(red: 0.9843137255, green: 0.3607843137, blue: 0.9960784314, alpha: 1)
        view.layer.borderWidth = 1.0
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.addSubview(myInfoWindowLabel)
        return view
    }()
    let myInfoWindowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.textAlignment = .center
        label.font = FontManager.shared.regular(ofSize: 16)
        label.backgroundColor = .white
        label.sizeToFit()
        return label
    }()
    
    //상대방 마커
    var otherMarker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        return marker
    }()
    
    let otherMarkerIcon: UIImage = {
        let image1 = UIImage(named: "otherMarkerborder")
        let image2 = UIImage(named: "otherMarkerDot")
        let defaultProfileImage = UIImage(named: "defaultProfileImage")!

        let imageSize = CGSize(width: 80, height: 107)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        
        image1?.draw(in: CGRect(x: 0, y: 0, width: 80, height: 90))
        image2?.draw(in: CGRect(x: 31, y: 89, width: 18, height: 18))
        defaultProfileImage.draw(in: CGRect(x: 7, y: 7, width: 66, height: 66))

        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = compositeImage {
            return image
        }
        return UIImage(named: "otherMarkerDot")!
    
    }()
    
    lazy var otherInfoWindowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = #colorLiteral(red: 1, green: 0.8549019608, blue: 0.3490196078, alpha: 1)
        view.layer.borderWidth = 1.0
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.addSubview(otherInfoWindowLabel)
        return view
    }()
    
    let otherInfoWindowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.textAlignment = .center
        label.font = FontManager.shared.regular(ofSize: 16)
        label.backgroundColor = .white
        label.sizeToFit()
        return label
    }()
    
    lazy var dDayButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        button.layer.applyShadow(color: #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.3764705882, alpha: 1), alpha: 0.28, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        button.addSubview(dDayLabel)
        return button
    }()
    
    let dDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 18)
        return label
    }()
    
    let alarmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "alarmIcon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        return button
    }()
    
    let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "myPositionIcon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        return button
    }()
    
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        mapViewConstraints()
        mapViewElementConstraints()
        infoWindowConstraints()
    }
    
    private func mapViewConstraints() {
        naverMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            naverMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naverMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naverMapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            naverMapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func infoWindowConstraints() {
        myInfoWindowView.translatesAutoresizingMaskIntoConstraints = false
        myInfoWindowLabel.translatesAutoresizingMaskIntoConstraints = false
        otherInfoWindowView.translatesAutoresizingMaskIntoConstraints = false
        otherInfoWindowLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myInfoWindowView.leadingAnchor.constraint(equalTo: self.myInfoWindowLabel.leadingAnchor, constant: -20),
            myInfoWindowView.trailingAnchor.constraint(equalTo: self.myInfoWindowLabel.trailingAnchor, constant: 20),
            myInfoWindowView.heightAnchor.constraint(equalToConstant: 43),
            
            myInfoWindowLabel.centerXAnchor.constraint(equalTo: myInfoWindowView.centerXAnchor),
            myInfoWindowLabel.centerYAnchor.constraint(equalTo: myInfoWindowView.centerYAnchor),
            myInfoWindowLabel.heightAnchor.constraint(equalToConstant: 43),
            
            otherInfoWindowView.leadingAnchor.constraint(equalTo: self.otherInfoWindowLabel.leadingAnchor, constant: -20),
            otherInfoWindowView.trailingAnchor.constraint(equalTo: self.otherInfoWindowLabel.trailingAnchor, constant: 20),
            otherInfoWindowView.heightAnchor.constraint(equalToConstant: 43),
            
            otherInfoWindowLabel.centerXAnchor.constraint(equalTo: otherInfoWindowView.centerXAnchor),
            otherInfoWindowLabel.centerYAnchor.constraint(equalTo: otherInfoWindowView.centerYAnchor),
            otherInfoWindowLabel.heightAnchor.constraint(equalToConstant: 43)
        
        ])
        
    }
    private func mapViewElementConstraints() {
        dDayButton.translatesAutoresizingMaskIntoConstraints = false
        dDayLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dDayButton.leadingAnchor.constraint(equalTo: dDayLabel.leadingAnchor, constant: -20),
            dDayButton.trailingAnchor.constraint(equalTo: dDayLabel.trailingAnchor, constant: 20),
            dDayButton.topAnchor.constraint(equalTo: naverMapView.topAnchor, constant: 60),
            dDayButton.heightAnchor.constraint(equalToConstant: 48),
            
            dDayLabel.centerXAnchor.constraint(equalTo: naverMapView.centerXAnchor),
            dDayLabel.centerYAnchor.constraint(equalTo: dDayButton.centerYAnchor),
            
            alarmButton.trailingAnchor.constraint(equalTo: naverMapView.trailingAnchor, constant: -16),
            alarmButton.topAnchor.constraint(equalTo: naverMapView.topAnchor, constant: 60),
            alarmButton.widthAnchor.constraint(equalToConstant: 48),
            alarmButton.heightAnchor.constraint(equalToConstant: 48),

            currentLocationButton.trailingAnchor.constraint(equalTo: naverMapView.trailingAnchor, constant: -16),
            currentLocationButton.bottomAnchor.constraint(equalTo: naverMapView.bottomAnchor, constant: -16),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 48),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 48),
                        
        ])
    }
    
}

// MARK: Custom Marker InfoView
class CustomInfoViewDataSource: NSObject, NMFOverlayImageDataSource {
    func view(with overlay: NMFOverlay) -> UIView {
        return customView
    }
    
    let customView: UIView
    
    init(customView: UIView) {
        self.customView = customView
    }
    
}
