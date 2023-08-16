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
        
    }
    
    // MARK: Binding
    func setBindings() {
        let input = MapVM.Input(
            viewWillApearEvent: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            dDayBtnTapEvent: self.dDayButton.rx.tap.asObservable(),
            alarmBtnTapEvent: self.alarmButton.rx.tap.asObservable()

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
            .drive(onNext: { text in
                if let message = text {
                    self.myInfoWindowLabel.text = message
                    self.infoWindow1.open(with: self.myMarker)
                }else {
                    self.myInfoWindowLabel.text = text
                    self.infoWindow1.close()
                }
            })
            .disposed(by: disposeBag)
        
        output.otherStateMessage
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { text in
                if let message = text {
                    self.otherInfoWindowLabel.text = message
                    self.infoWindow2.open(with: self.otherMarker)
                }else {
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
            .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
            .drive(onNext: { [weak self] current in
                print("내위치 vc", current, Date())
                self?.updateMyMarker(current)
            })
            .disposed(by: disposeBag)
        
        output.currentLocation
            .take(4)
            .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
            .drive(onNext: { [weak self] current in
                self?.updateCamera(current)
            })
            .disposed(by: disposeBag)
        
        output.currentOtherLocation
            .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
            .drive(onNext: { [weak self] current in
                self?.updateOtherMarker(current)
            })
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .subscribe(onNext: {[weak self] _ in
                output.currentLocation
                    .take(1)
                    .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
                    .drive(onNext: { [weak self] current in
                        self?.updateCamera(current)
                    })
                    .dispose()
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
        [naverMapView, alarmButton, dDayButton, currentLocationButton].forEach { view.addSubview($0) }
        setMarker()
    }
    
    // MARK: Event
    
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

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // MARK: UI
    
    /// 마커 아이콘, 상태메세지 정보창 설정
    func setMarker() {
        myMarker.iconImage = NMFOverlayImage(image: myMarkerIcon)
        let dataSource1 = CustomInfoViewDataSource(customView: myInfoWindowLabel)
        infoWindow1.dataSource = dataSource1
        
        otherMarker.iconImage = NMFOverlayImage(image: otherMarkerIcon)
        let dataSource2 = CustomInfoViewDataSource(customView: otherInfoWindowLabel)
        infoWindow2.dataSource = dataSource2
    }
    
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
    
    let myInfoWindowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 141, height: 43))
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
    
    let otherInfoWindowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 141, height: 43))
        label.textColor = .black
        label.textAlignment = .center
        label.font = FontManager.shared.regular(ofSize: 16)
        label.backgroundColor = .white
        label.layer.borderColor = #colorLiteral(red: 1, green: 0.8549019608, blue: 0.3490196078, alpha: 1)
        label.layer.borderWidth = 1.0
        label.clipsToBounds = true
        label.layer.cornerRadius = 20
        return label
    }()
    
    lazy var dDayButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
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
    
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        mapViewConstraints()
        mapViewElementConstraints()
    }
    
    private func mapViewConstraints() {
        naverMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            naverMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naverMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naverMapView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44),
            naverMapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
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
            dDayButton.topAnchor.constraint(equalTo: naverMapView.topAnchor, constant: 17),
            dDayButton.heightAnchor.constraint(equalToConstant: 48),
            
            dDayLabel.centerXAnchor.constraint(equalTo: naverMapView.centerXAnchor),
            dDayLabel.centerYAnchor.constraint(equalTo: dDayButton.centerYAnchor),
            
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
