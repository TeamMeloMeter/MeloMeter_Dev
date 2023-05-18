//
//  MapViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/03.
//

import UIKit
import NMapsMap
import CoreLocation

//메인 지도 화면
class MapViewController: UIViewController, CLLocationManagerDelegate{

    let mainView = MapView()
    let infoWindow = NMFInfoWindow()
    

    var locationManager = CLLocationManager()
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapViewTouch()
        setLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        setMarker()
        
    }
    
    func setLocation() {
        self.locationManager.delegate = self // 델리게이트 넣어줌
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정
        self.locationManager.requestAlwaysAuthorization() // 위치 권한 설정 값을 받아옵니다
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
        
        if let myLocation = locationManager.location?.coordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: myLocation.latitude, lng: myLocation.longitude))
            cameraUpdate.animation = .easeIn
            mainView.naverMapView.moveCamera(cameraUpdate)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("[ViewController > locationManager() : 위치 사용 권한 항상 허용]")
        }
        if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 앱 사용 시 허용]")
        }
        if status == .denied {
            self.locationManager.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 거부]")
        }
        if status == .restricted || status == .notDetermined {
            self.locationManager.requestAlwaysAuthorization()
            print("[ViewController > locationManager() : 위치 사용 권한 대기 상태]")
        }
    }
    
    // MARK: - [위치 정보 지속적 업데이트]
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // [위치 정보가 nil 이 아닌 경우]
            print("[ > didUpdateLocations() : 위치 정보 확인 실시]")
            print("[위도 : \(location.coordinate.latitude)]")
            print("[경도 : \(location.coordinate.longitude)]")
            
            //내 위치 마커 표시, 정보창 표시
            mainView.myMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            mainView.myMarker.mapView = mainView.naverMapView
            infoWindow.open(with: mainView.myMarker)
            
        }
    }
    
    /// 마커 아이콘, 상태메세지 정보창 설정
    func setMarker() {
        mainView.myMarker.iconImage = NMFOverlayImage(image: mainView.myMarkerIcon)
        let dataSource = CustomInfoViewDataSource(customView: mainView.myInfoWindowLabel)
        infoWindow.dataSource = dataSource
        
    }
    
    
    // MARK: - [위도, 경도 받아오기 에러가 발생한 경우]
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("")
        print("===============================")
        print("[ViewController > didFailWithError() : 위치 정보 확인 에러]")
        print("[error : \(error)]")
        print("[localizedDescription : \(error.localizedDescription)]")
        print("===============================")
        print("")
    }

    // 뷰 요소 터치이벤트
    func setMapViewTouch() {
        
        mainView.alarmButton.addTarget(self, action: #selector(alarmBtnTapped), for: .touchUpInside)
        mainView.currentLocationButton.addTarget(self, action: #selector(currentLocationTapped), for: .touchUpInside)
        mainView.dDayButton.addTarget(self, action: #selector(dDayBtnTapped), for: .touchUpInside)
        
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
        if let myLocation = locationManager.location?.coordinate {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: myLocation.latitude, lng: myLocation.longitude))
            cameraUpdate.animation = .easeIn
            mainView.naverMapView.moveCamera(cameraUpdate)
        }
    }
    
}

///뷰를 이미지로 변환
//extension UIView {
//    func transfromToImage() -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
//        defer {
//            UIGraphicsEndImageContext()
//        }
//        if let context = UIGraphicsGetCurrentContext() {
//            layer.render(in: context)
//            return UIGraphicsGetImageFromCurrentImageContext()
//        }
//        return nil
//    }
//}

/// 마커 정보창을 커스텀 뷰로 사용
class CustomInfoViewDataSource: NSObject, NMFOverlayImageDataSource {
    func view(with overlay: NMFOverlay) -> UIView {
        return customView
    }
    
    let customView: UIView
    
    init(customView: UIView) {
        self.customView = customView
    }
    
}
