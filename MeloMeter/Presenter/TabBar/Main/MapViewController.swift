//
//  MapViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit
import NMapsMap
import CoreLocation
import RxCocoa
import RxSwift

//메인 지도 화면
class MapViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate{

    let infoWindow = NMFInfoWindow()
    private let viewModel: MapVM
    let disposeBag = DisposeBag()
    private var locationManager: CLLocationManager?

    init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapViewTouch()
        setLocation()
        setUpBarButton()
        configure()
        setAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        setMarker()
    }
    
    // MARK: Configure
    func configure() {
        view.backgroundColor = .white
        [naverMapView, alarmButton, dDayButton, currentLocationButton].forEach { view.addSubview($0) }
    }
    
    // MARK: Location
    func setLocation() {
        self.locationManager?.delegate = self // 델리게이트 넣어줌
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정
        self.locationManager?.requestAlwaysAuthorization() // 위치 권한 설정 값을 받아옵니다
        self.locationManager?.startUpdatingLocation() // 위치 업데이트 시작
        
        if let myLocation = locationManager?.location?.coordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: myLocation.latitude, lng: myLocation.longitude))
            cameraUpdate.animation = .easeIn
            naverMapView.moveCamera(cameraUpdate)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("[ViewController > locationManager() : 위치 사용 권한 항상 허용]")
        }
        if status == .authorizedWhenInUse {
            self.locationManager?.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 앱 사용 시 허용]")
        }
        if status == .denied {
            self.locationManager?.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 거부]")
        }
        if status == .restricted || status == .notDetermined {
            self.locationManager?.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 대기 상태]")
        }
    }
    
    // [위치 정보 지속적 업데이트]
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // [위치 정보가 nil 이 아닌 경우]
            print("[ > didUpdateLocations() : 위치 정보 확인 실시]")
            print("[위도 : \(location.coordinate.latitude)]")
            print("[경도 : \(location.coordinate.longitude)]")
            
            //내 위치 마커 표시, 정보창 표시
            myMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            myMarker.mapView = naverMapView
            infoWindow.open(with: myMarker)
            
        }
    }
    
    
    // [위도, 경도 받아오기 에러가 발생한 경우]
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("")
        print("===============================")
        print("[ViewController > didFailWithError() : 위치 정보 확인 에러]")
        print("[error : \(error)]")
        print("[localizedDescription : \(error.localizedDescription)]")
        print("===============================")
        print("")
    }

    // MARK: Event
    // 뷰 요소 터치이벤트
    func setMapViewTouch() {
        
        alarmButton.addTarget(self, action: #selector(alarmBtnTapped), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        dDayButton.addTarget(self, action: #selector(dDayBtnTapped), for: .touchUpInside)
        
    }
    
    //알림 화면으로
    @objc func alarmBtnTapped(){
        let VC = AlarmViewController()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
        
    }
    
    //기념일 화면으로
    @objc func dDayBtnTapped(){
        let VC = DdayViewController()
        VC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //현재 위치로 카메라 이동
    @objc func currentLocationTapped(){
        if let myLocation = locationManager?.location?.coordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: myLocation.latitude, lng: myLocation.longitude))
            cameraUpdate.animation = .easeIn
            naverMapView.moveCamera(cameraUpdate)
        }
    }
    
    // MARK: navigationBar
    func setUpBarButton() {
        //스와이프 뒤로가기
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        //타이틀 속성 조정 - 폰트, 배경
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]
        
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    // MARK: UI
    
    /// 마커 아이콘, 상태메세지 정보창 설정
    func setMarker() {
        myMarker.iconImage = NMFOverlayImage(image: myMarkerIcon)
        let dataSource = CustomInfoViewDataSource(customView: myInfoWindowLabel)
        infoWindow.dataSource = dataSource

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
    
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        mapViewConstraint()
        mapViewElementConstraint()
    }
    
    private func mapViewConstraint() {
        naverMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            naverMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naverMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naverMapView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44),
            naverMapView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
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
