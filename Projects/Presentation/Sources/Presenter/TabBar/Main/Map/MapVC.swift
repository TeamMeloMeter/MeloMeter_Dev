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
import CoreBluetooth
import CoreLocation
import GoogleMobileAds
import UserNotifications
import Domain
import Core

//메인 지도 화면
public class MapVC: UIViewController, UIGestureRecognizerDelegate{

    private var beforePickedMarkers: NMFMarker?
    private var beforeAlreadyPlaceMarkers: [NMFMarker] = []
    private let infoWindow1 = NMFInfoWindow()
    private let infoWindow2 = NMFInfoWindow()
    private var bannerView: BannerView?
    private let proximityService = BLEProximityService()
    private var lastKnownLocation: CLLocation?
    private var currentMode: MapMode = .record
    private var datePlans: [DatePlanModel] = []
    private var planMarkers: [NMFMarker] = []
    private var handledCompletedPlanIds: Set<String> = []
    private var didInitializePlans = false
    private let savePlanSubject = PublishSubject<DatePlanDraft>()
    private let checkInPlanSubject = PublishSubject<DatePlanModel>()
    private let updatePlanSubject = PublishSubject<DatePlanModel>()
    private let deletePlanSubject = PublishSubject<String>()
    private var notifiedPlanIds: Set<String> = []
    private var isPresentingMeetingPrompt = false
    private var toastHideWorkItem: DispatchWorkItem?
    private var isPresentingDateEndPrompt = false
    private var bleLastSeenAt: Date?
    private var bleMissingSince: Date?
    private var bleEndedAt: Date?
    private var isBleMeetingActive = false
    private var didPromptBleEnded = false
    private var bleMonitorTimer: Timer?
    private var bleMonitoringStarted = false
    private let bleCheckInterval: TimeInterval = 600
    private let bleMissingThreshold: TimeInterval = 3600
  
    
    //MARK: Rx
    public var endTriggerAlertEvent = PublishSubject<Void>()
    public var markerTapped = PublishSubject<CouplePlaceModel>()
    
    
    private var viewModel: MapVM?
    public let disposeBag = DisposeBag()
    
    public init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        setBindings()
        setNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMarker()
        self.navigationController?.navigationBar.isHidden = true
        startBleMonitoringIfNeeded()
        let coupleId = UserDefaults.standard.string(forKey: "coupleID")
        _ = MeetingStampStore.shared.savePendingStamp(coupleId: coupleId)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        stopBleMonitoring()
    }
    
    // MARK: Binding
    public func setBindings() {
        let modeChanged = modeSegmentedControl.rx.selectedSegmentIndex
            .map { index -> MapMode in
                return index == 0 ? .record : .reservation
            }
            .share()
        let input = MapVM.Input(
            viewWillAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
                .map({ _ in })
                .asObservable(),
            dDayBtnTapEvent: self.dDayButton.rx.tap
                .map({ _ in })
                .asObservable(),
            alarmBtnTapEvent: self.alarmButton.rx.tap
                .map({ _ in })
                .asObservable(),
            searchBtnTapEvent: self.searchBtn.rx.tap.map ({ _ in }).asObservable(),
            modeChanged: modeChanged.asObservable(),
            savePlan: savePlanSubject.asObservable(),
            checkInPlan: checkInPlanSubject.asObservable(),
            updatePlan: updatePlanSubject.asObservable(),
            deletePlan: deletePlanSubject.asObservable(),
            endTriggerAlertTapEvent: self.endTriggerAlertEvent
                .asObserver(),
            dissmissBottomSheet: self.naverMapView.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).map { _ in }.asObservable(),
            markerTapped: markerTapped
            
        )

        naverMapView.rx.longTap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mapPoint in
                self?.handleMapLongPress(at: mapPoint)
            })
            .disposed(by: disposeBag)
        
        guard let output = self.viewModel?.transform(input: input, disposeBag: self.disposeBag) else { return }
        
        output.getBottomBannerAd.bind(onNext: addBannerViewToView ).disposed(by: disposeBag)

        modeChanged
            .subscribe(onNext: { [weak self] mode in
                self?.currentMode = mode
                self?.applyMapMode()
            })
            .disposed(by: disposeBag)
        
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
                self.infoWindow1.close()
                guard let message = text, message.isEmpty == false else { return }
                self.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        output.otherStateMessage
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: {[weak self] text in
                guard let self = self else { return }
                self.infoWindow2.close()
                guard let message = text, message.isEmpty == false else { return }
                self.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        output.authorizationAlertShouldShow
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] shouldShowAlert in
                guard let self else{ return }
                if shouldShowAlert {
                    AlertManager(viewController: self)
                        .setLocationAlert()
                }
            })
            .disposed(by: disposeBag)

        output.currentLocation
            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
            .drive(onNext: { [weak self] current in
                guard let self else {return}
                self.updateMyMarker(current ?? CLLocation(latitude: 0, longitude: 0))
            })
            .disposed(by: disposeBag)
        //        output.currentLocation
        //            .take(1)
        //            .asDriver(onErrorJustReturn: CLLocation(latitude: 37.541, longitude: 126.986))
        //            .drive(onNext: { [weak self] current in
        //
        //                self?.updateCamera(current ?? CLLocation(latitude: 0, longitude: 0))
        //            })
        //            .disposed(by: disposeBag)
        //
        
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
        
        output.searchedMarker.bind(onNext: self.pickedMarker).disposed(by: disposeBag)
        
        output.cameraUpdate.bind(onNext: self.updateCamera).disposed(by: disposeBag)
        
        output.deletePickedMarkers.bind(onNext: self.deletePickedMarkers).disposed(by: disposeBag)
        
        output.alreadyPlacesMarkers.bind(onNext: updatePlaceMarkers).disposed(by: disposeBag)

        output.datePlans
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] plans in
                self?.datePlans = plans
                self?.updatePlanMarkers()
                DatePlanCalendarStore.shared.update(plans: plans)
                if let location = self?.lastKnownLocation {
                    self?.evaluatePlanProximity(with: location)
                }
                self?.handleCompletedPlansIfNeeded(plans)
            })
            .disposed(by: disposeBag)

        output.presentDatePlanSheet
            .subscribe(onNext: { [weak self] pickedModel in
                self?.presentDatePlanSheet(pickedModel: pickedModel)
            })
            .disposed(by: disposeBag)
        
        calendarButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showCalendar()
            })
            .disposed(by: disposeBag)

    }
    
    // MARK: Map
    public func updateMyMarker(_ location: CLLocation) {
        myMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        myMarker.mapView = naverMapView
        lastKnownLocation = location
        evaluatePlanProximity(with: location)
    }
    public func updateOtherMarker(_ location: CLLocation) {
        otherMarker.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        otherMarker.mapView = naverMapView
    }
    public func updatePlaceMarkers(models: [CouplePlaceModel]) {
        beforeAlreadyPlaceMarkers.forEach {
            $0.mapView = nil
        }
        beforeAlreadyPlaceMarkers.removeAll()
        models.forEach { model in
            let marker = NMFMarker()
            marker.iconImage = NMFOverlayImage(image: UIImage(named: "couplePlaceIcon")!)
            marker.position = NMGLatLng(lat: model.mapY, lng: model.mapX)
//            marker.captionText = model.name
            if currentMode == .record {
                marker.mapView = self.naverMapView
            }
            marker.touchHandler = { [weak self] overlay in
                guard let tappedMarker = overlay as? NMFMarker, let self else {
                    return false
                }
                self.markerTapped.onNext(model)
                return true
            }
            beforeAlreadyPlaceMarkers.append(marker)
        }
    }

    private func updatePlanMarkers() {
        planMarkers.forEach { $0.mapView = nil }
        planMarkers.removeAll()
        for plan in datePlans where plan.isCompleted != true {
            let marker = NMFMarker()
            marker.iconImage = NMFOverlayImage(image: planMarkerIcon(for: plan))
            marker.position = NMGLatLng(lat: plan.mapY, lng: plan.mapX)
            if currentMode == .reservation {
                marker.mapView = naverMapView
            }
            marker.touchHandler = { [weak self] _ in
                self?.handlePlanMarkerTapped(plan)
                return true
            }
            planMarkers.append(marker)
        }
    }

    private func applyMapMode() {
        deletePickedMarkers()
        switch currentMode {
        case .record:
            beforeAlreadyPlaceMarkers.forEach { $0.mapView = naverMapView }
            planMarkers.forEach { $0.mapView = nil }
        case .reservation:
            beforeAlreadyPlaceMarkers.forEach { $0.mapView = nil }
            updatePlanMarkers()
        }
    }

    private func handlePlanMarkerTapped(_ plan: DatePlanModel) {
        var message = "\(plan.scheduledAt)\n\(plan.address)"
        if let uid = UserDefaults.standard.string(forKey: "uid"),
           plan.arrivalRecords[uid] == nil {
            let radiusText = formattedRadiusText(effectiveRadiusMeters(for: plan))
            message += "\n\n목적지 \(radiusText) 안에 들어오면 자동으로 도착이 기록돼요."
        } else if plan.isCompleted == true {
            message += "\n\n약속이 완료됐어요."
        } else {
            message += "\n\n도착이 확인됐어요."
        }
        let alertController = UIAlertController(
            title: plan.name,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "시간 수정", style: .default, handler: { [weak self] _ in
            self?.confirmTimeEditIfNeeded(plan)
        }))

        alertController.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.confirmDelete(plan)
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alertController, animated: true)
    }

    private func confirmTimeEditIfNeeded(_ plan: DatePlanModel) {
        let hasActivity = plan.checkIns.isEmpty == false || plan.arrivalRecords.isEmpty == false
        guard hasActivity else {
            presentTimeEditSheet(plan: plan, resetCheckIns: false)
            return
        }
        let alert = UIAlertController(
            title: "시간을 변경할까요?",
            message: "도착 기록이 초기화돼요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "변경", style: .destructive, handler: { [weak self] _ in
            self?.presentTimeEditSheet(plan: plan, resetCheckIns: true)
        }))
        present(alert, animated: true)
    }

    private func confirmDelete(_ plan: DatePlanModel) {
        let alert = UIAlertController(
            title: "예약을 삭제할까요?",
            message: "삭제한 예약은 복구할 수 없어요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.deletePlanSubject.onNext(plan.uuid)
        }))
        present(alert, animated: true)
    }

    private func presentTimeEditSheet(plan: DatePlanModel, resetCheckIns: Bool) {
        let viewController = DatePlanTimeEditSheetVC(plan: plan, resetCheckIns: resetCheckIns) { [weak self] updatedPlan in
            self?.updatePlanSubject.onNext(updatedPlan)
        }
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let fixedHeight: CGFloat = 360
                let fixedDetent = UISheetPresentationController.Detent.custom(identifier: .init("time-edit")) { context in
                    return min(fixedHeight, context.maximumDetentValue)
                }
                sheet.detents = [fixedDetent]
                sheet.selectedDetentIdentifier = .init("time-edit")
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true)
    }

    private func canCheckIn(plan: DatePlanModel) -> Bool {
        guard let location = lastKnownLocation else { return false }
        let recentThreshold = Date().addingTimeInterval(-60)
        guard location.timestamp >= recentThreshold else { return false }
        let target = CLLocation(latitude: plan.mapY, longitude: plan.mapX)
        return location.distance(from: target) <= effectiveRadiusMeters(for: plan)
    }

    private func evaluatePlanProximity(with location: CLLocation) {
        guard let uid = UserDefaults.standard.string(forKey: "uid"), uid.isEmpty == false else { return }
        for plan in datePlans {
            guard plan.isCompleted != true else { continue }
            guard plan.arrivalRecords[uid] == nil else { continue }
            guard plan.notifyEnabled else { continue }
            let target = CLLocation(latitude: plan.mapY, longitude: plan.mapX)
            let distance = location.distance(from: target)
            guard distance <= effectiveRadiusMeters(for: plan) else { continue }
            guard UIApplication.shared.applicationState != .active else { continue }
            guard notifiedPlanIds.contains(plan.uuid) == false else { continue }
            sendCheckInNotification(for: plan)
            notifiedPlanIds.insert(plan.uuid)
        }
    }

    private func sendCheckInNotification(for plan: DatePlanModel) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.title = "약속 장소에 도착했어요"
            content.body = "자동으로 도착이 기록돼요."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "plan-checkin-\(plan.uuid)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    private func planMarkerIcon(for plan: DatePlanModel) -> UIImage {
        if plan.isOnTime == true, let heart = UIImage(named: "heartIcon") {
            return heart
        }
        return planMarkerIcon
    }

    private func startBleMonitoringIfNeeded() {
        guard bleMonitoringStarted == false else { return }
        bleMonitoringStarted = true

        proximityService.onProximityDetected = { [weak self] in
            self?.handleProximityDetected()
        }
        proximityService.onProximityHeartbeat = { [weak self] date in
            self?.updateBleHeartbeat(at: date)
        }
        let coupleId = UserDefaults.standard.string(forKey: "coupleID")
        proximityService.configure(coupleId: coupleId)
        proximityService.start()

        bleMonitorTimer?.invalidate()
        bleMonitorTimer = Timer.scheduledTimer(withTimeInterval: bleCheckInterval, repeats: true) { [weak self] _ in
            self?.checkBleMeetingStatus()
        }
    }

    private func stopBleMonitoring() {
        bleMonitorTimer?.invalidate()
        bleMonitorTimer = nil
        proximityService.stop()
        bleMonitoringStarted = false
    }

    private func updateBleHeartbeat(at date: Date) {
        bleLastSeenAt = date
        bleMissingSince = nil
        bleEndedAt = nil
        if isBleMeetingActive == false {
            isBleMeetingActive = true
            didPromptBleEnded = false
        }
    }

    private func checkBleMeetingStatus() {
        guard isBleMeetingActive else { return }
        guard let lastSeen = bleLastSeenAt else { return }
        let now = Date()
        if now.timeIntervalSince(lastSeen) < bleCheckInterval {
            bleMissingSince = nil
            return
        }

        if bleMissingSince == nil {
            bleMissingSince = now
        }
        guard let missingSince = bleMissingSince else { return }
        if now.timeIntervalSince(missingSince) >= bleMissingThreshold {
            isBleMeetingActive = false
            bleLastSeenAt = nil
            bleEndedAt = missingSince
            if didPromptBleEnded == false {
                didPromptBleEnded = true
                presentDateEndPrompt()
            }
        }
    }

    private func showToast(message: String) {
        toastHideWorkItem?.cancel()
        toastLabel.text = message
        if toastContainerView.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.toastContainerView.alpha = 1
            }
        }
        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.toastContainerView.alpha = 0
            }
        }
        toastHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

    private func formattedRadiusText(_ meters: Double) -> String {
        if meters >= 1000, meters.truncatingRemainder(dividingBy: 1000) == 0 {
            return "\(Int(meters / 1000))km"
        }
        return "\(Int(meters))m"
    }

    private func effectiveRadiusMeters(for plan: DatePlanModel) -> Double {
#if DEBUG
        return max(plan.radiusMeters, 1000)
#else
        return plan.radiusMeters
#endif
    }

    private func handleCompletedPlansIfNeeded(_ plans: [DatePlanModel]) {
        let completedPlans = plans.filter { plan in
            plan.isCompleted == true && plan.arrivalRecords.count >= 2
        }
        if didInitializePlans == false {
            handledCompletedPlanIds = Set(completedPlans.map { $0.uuid })
            didInitializePlans = true
            return
        }
        guard let plan = completedPlans.first(where: { handledCompletedPlanIds.contains($0.uuid) == false }) else { return }
        handledCompletedPlanIds.insert(plan.uuid)
        presentCompletionAlert(for: plan)
    }

    private func presentCompletionAlert(for plan: DatePlanModel) {
        let alert = UIAlertController(
            title: "약속 완료!",
            message: "기록을 추가할까요?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "추가하기", style: .default, handler: { [weak self] _ in
            self?.navigateToRecordCreation(plan)
        }))
        present(alert, animated: true)
    }

    private func navigateToRecordCreation(_ plan: DatePlanModel) {
        currentMode = .record
        modeSegmentedControl.selectedSegmentIndex = 0
        applyMapMode()

        let searchedModel = SearchedModel(title: plan.name,
                                          link: "",
                                          category: "",
                                          description: "",
                                          telephone: "",
                                          address: plan.address,
                                          roadAddress: plan.roadAddress,
                                          mapx: plan.mapX,
                                          mapy: plan.mapY)
        pickedMarker(model: searchedModel)
        viewModel?.coordinator?.presentRecordCreation(pickedModel: searchedModel, memo: plan.memo)
    }
    
    public func updateCamera(_ location: CLLocation) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
        cameraUpdate.animation = .easeIn
        naverMapView.moveCamera(cameraUpdate)
    }
    
    // MARK: Configure
    public func configure() {
        
        [naverMapView,
         currentLocationButton,
         dDayButton,
         alarmButton,
         calendarButton,
         modeSegmentedControl,
         searchBtn,
         toastContainerView].forEach { view.addSubview($0) }
        toastContainerView.addSubview(toastLabel)
        view.sendSubviewToBack(naverMapView)
    }
    
    // MARK: Event
    public func endTriggerAlert() {
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
    
    public func changedMarkerIcon(isMine: Bool, profileImage: UIImage) {
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
    public func setNavigationBar() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
            backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance
        }
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: FontManager.shared.medium(ofSize: 18)]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        if #available(iOS 16.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationController?.navigationBar.isTranslucent = false
        if let backImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal) {
            navigationController?.navigationBar.backIndicatorImage = backImage
            navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        }
        navigationController?.navigationBar.tintColor = .gray1
    }
    
    // MARK: UI
    
    /// 마커 아이콘, 상태메세지 정보창 설정
    public func setMarker() {
        myMarker.iconImage = NMFOverlayImage(image: myMarkerIcon)
        let dataSource1 = CustomInfoViewDataSource(customView: myInfoWindowView)
        infoWindow1.offsetY = 5
        infoWindow1.dataSource = dataSource1
        
        otherMarker.iconImage = NMFOverlayImage(image: otherMarkerIcon)
        let dataSource2 = CustomInfoViewDataSource(customView: otherInfoWindowView)
        infoWindow2.offsetY = 5
        infoWindow2.dataSource = dataSource2
    }
    
    public func pickedMarker(model: SearchedModel) {
        let marker = NMFMarker()
        marker.iconImage = NMFOverlayImage(image: UIImage(named: "pickedMarkerIcon")!)
        marker.position = NMGLatLng(lat: model.mapy, lng: model.mapx)
        marker.captionText = model.title
        marker.mapView = self.naverMapView
        beforePickedMarkers = marker
    }
    
    public func deletePickedMarkers() {
        beforePickedMarkers?.mapView = nil
    }

    private func handleMapLongPress(at mapPoint: NMGLatLng) {
        guard presentedViewController == nil else { return }

        if modeSegmentedControl.selectedSegmentIndex != 1 {
            modeSegmentedControl.selectedSegmentIndex = 1
            modeSegmentedControl.sendActions(for: .valueChanged)
        }

        deletePickedMarkers()

        let pickedModel = SearchedModel(title: "지정한 위치",
                                        link: "",
                                        category: "",
                                        description: "",
                                        telephone: "",
                                        address: "지정한 위치",
                                        roadAddress: "",
                                        mapx: mapPoint.lng,
                                        mapy: mapPoint.lat)
        pickedMarker(model: pickedModel)
        presentDatePlanSheet(pickedModel: pickedModel)
    }

    private func showCalendar() {
        let viewController = CalendarSheetVC()
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }

    private func presentDatePlanSheet(pickedModel: SearchedModel) {
        let viewController = DatePlanSheetVC(pickedModel: pickedModel) { [weak self] draft in
            self?.savePlanSubject.onNext(draft)
            self?.deletePickedMarkers()
        }
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let fixedHeight: CGFloat = 560
                let fixedDetent = UISheetPresentationController.Detent.custom(identifier: .init("fixed")) { context in
                    return min(fixedHeight, context.maximumDetentValue)
                }
                sheet.detents = [fixedDetent]
                sheet.selectedDetentIdentifier = .init("fixed")
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(viewController, animated: true)
    }


    private func handleProximityDetected() {
        let now = Date()
        updateBleHeartbeat(at: now)
        let coupleId = UserDefaults.standard.string(forKey: "coupleID")
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: now)
        let hasMeetingStamp = MeetingStampStore.shared.hasStamp(on: todayComponents, coupleId: coupleId)
        if hasMeetingStamp == false {
            if UIApplication.shared.applicationState == .active {
                MeetingStampStore.shared.addStamp(date: now, location: lastKnownLocation, coupleId: coupleId)
            } else {
                MeetingStampStore.shared.setPending(date: now, location: lastKnownLocation, coupleId: coupleId)
            }
        }
        if UIApplication.shared.applicationState == .active {
            presentBleMeetingPrompt()
        } else {
            sendLocalNotification(
                title: "만나셨군요!",
                body: "목적지 근처에 들어오면 자동으로 도착이 기록돼요.",
                identifier: "ble-meet"
            )
        }
    }

    private func presentBleMeetingPrompt() {
        guard isPresentingMeetingPrompt == false else { return }
        isPresentingMeetingPrompt = true
        let alertController = UIAlertController(
            title: "만나셨군요!",
            message: "목적지 근처에 들어오면 자동으로 도착이 기록돼요.",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.isPresentingMeetingPrompt = false
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }


    private func presentDateEndPrompt() {
        if UIApplication.shared.applicationState == .active {
            guard isPresentingDateEndPrompt == false else { return }
            isPresentingDateEndPrompt = true
            let alertController = UIAlertController(
                title: "데이트가 끝나셨나요?",
                message: "오늘의 기록을 남겨보세요.",
                preferredStyle: .alert
            )
            let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.isPresentingDateEndPrompt = false
            }
            alertController.addAction(confirmAction)
            present(alertController, animated: true)
        } else {
            sendLocalNotification(
                title: "데이트가 끝나셨나요?",
                body: "오늘의 기록을 남겨보세요.",
                identifier: "ble-end"
            )
        }
    }

    private func sendLocalNotification(title: String, body: String, identifier: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    lazy var naverMapView: NMFMapView = {
        let view = NMFMapView()
        view.allowsZooming = true
        view.logoInteractionEnabled = false
        view.allowsScrolling = true
        return view
    }()
    
    public var myMarker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        return marker
    }()
    
    public let myMarkerIcon: UIImage = {
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
    public let myInfoWindowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.textAlignment = .center
        label.font = FontManager.shared.regular(ofSize: 16)
        label.backgroundColor = .white
        label.sizeToFit()
        return label
    }()
    
    //상대방 마커
    public var otherMarker: NMFMarker = {
        let marker = NMFMarker()
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        return marker
    }()
    
    public let otherMarkerIcon: UIImage = {
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
    
    public let otherInfoWindowLabel: UILabel = {
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
    
    public let dDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray1
        label.font = FontManager.shared.regular(ofSize: 18)
        return label
    }()

    private let modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["기록", "일정"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.selectedSegmentTintColor = .gray4
        control.setTitleTextAttributes([.foregroundColor: UIColor.gray1,
                                        .font: FontManager.shared.medium(ofSize: 13)], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.gray1,
                                        .font: FontManager.shared.semiBold(ofSize: 13)], for: .selected)
        control.layer.cornerRadius = 16
        control.layer.masksToBounds = true
        return control
    }()
    
    public let alarmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "alarmIcon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        return button
    }()

    private lazy var planMarkerIcon: UIImage = {
        let baseImage = UIImage(named: "couplePlaceIcon") ?? UIImage()
        return baseImage.grayscaleImage() ?? baseImage
    }()

    public let calendarButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .gray1
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        return button
    }()

    
    public let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "myPositionIcon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
        return button
    }()
    
    public let searchBtn = UIButton().then { button in
        button.setImage(UIImage(named: "searchIcon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 24
        button.layer.applyShadow(color: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1), alpha: 0.25, x: 3, y: 3, blur: 8)
        button.layer.masksToBounds = false
    }

    private let toastContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 16
        view.alpha = 0
        return view
    }()

    private let toastLabel: UILabel = {
        let label = UILabel()
        label.font = FontManager.shared.regular(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    //MARK: adMob
    private func addBannerViewToView(bannerView: BannerView?) {
        guard let bannerView else {return}
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        bannerView.adSize = adaptiveSize
        bannerView.rootViewController = self
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        self.bannerView = bannerView
        
        currentLocationBtnConstraints()
        
    }
    
    
    
    // MARK: 오토레이아웃
    private func setAutoLayout() {
        mapViewConstraints()
        mapViewElementConstraints()
        infoWindowConstraints()
        toastConstraints()
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

    private func toastConstraints() {
        toastContainerView.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            toastContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            toastContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            toastLabel.leadingAnchor.constraint(equalTo: toastContainerView.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainerView.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastContainerView.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainerView.bottomAnchor, constant: -10)
        ])
    }
    
    private func currentLocationBtnConstraints() {
        
        currentLocationButton.snp.makeConstraints {
            $0.trailing.equalTo(naverMapView.snp.trailing).inset(16)
            $0.bottom.equalTo(bannerView!.snp.top).offset(-16)
            $0.width.height.equalTo(48)
        }
    }
    
    private func mapViewElementConstraints() {
        dDayButton.translatesAutoresizingMaskIntoConstraints = false
        dDayLabel.translatesAutoresizingMaskIntoConstraints = false
        alarmButton.translatesAutoresizingMaskIntoConstraints = false
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
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

            calendarButton.trailingAnchor.constraint(equalTo: naverMapView.trailingAnchor, constant: -16),
            calendarButton.topAnchor.constraint(equalTo: alarmButton.bottomAnchor, constant: 12),
            calendarButton.widthAnchor.constraint(equalToConstant: 48),
            calendarButton.heightAnchor.constraint(equalToConstant: 48),

            modeSegmentedControl.centerXAnchor.constraint(equalTo: naverMapView.centerXAnchor),
            modeSegmentedControl.topAnchor.constraint(equalTo: dDayButton.bottomAnchor, constant: 8),
            modeSegmentedControl.widthAnchor.constraint(equalToConstant: 180),
            modeSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            
            
        ])
        
        
        searchBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(60)
            $0.width.height.equalTo(48)
        }
    }
    
}

// MARK: Custom Marker InfoView
public class CustomInfoViewDataSource: NSObject, NMFOverlayImageDataSource {
    public func view(with overlay: NMFOverlay) -> UIView {
        return customView
    }
    
    public let customView: UIView
    
    public init(customView: UIView) {
        self.customView = customView
    }
    
}

final class CalendarSheetVC: UIViewController, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
  func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
    //
  }
  
    private let calendarView = UICalendarView()
    private let closeButton = UIButton(type: .system)
    private let meetingStore = MeetingStampStore.shared
    private lazy var heartDecorationImage: UIImage? = {
        guard let image = UIImage(named: "heartIcon") else { return nil }
        let targetSize = CGSize(width: 16, height: 16)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)
        configureCloseButton()
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            calendarView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 8),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        calendarView.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(plansDidUpdate),
                                               name: MeetingStampStore.didUpdateNotification,
                                               object: nil)
        plansDidUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plansDidUpdate()
    }

    func calendarView(_ calendarView: UICalendarView,
                      decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let coupleId = UserDefaults.standard.string(forKey: "coupleID")
        let hasMeeting = meetingStore.hasStamp(on: dateComponents, coupleId: coupleId)
#if DEBUG
        let dateText = Calendar.current.date(from: dateComponents)?.toString(type: .yearToDayHipen) ?? "nil"
        print("[Calendar] decorationFor date=\(dateText), meeting=\(hasMeeting)")
#endif
        guard hasMeeting, let heart = heartDecorationImage else { return nil }
        return .image(heart)
    }

    @objc private func plansDidUpdate() {
        let coupleId = UserDefaults.standard.string(forKey: "coupleID")
        let components = meetingStore.stampedDateComponents(coupleId: coupleId)
#if DEBUG
        print("[Calendar] reload decorations count=\(components.count)")
#endif
        calendarView.reloadDecorations(forDateComponents: components, animated: true)
    }

    private func configureCloseButton() {
        closeButton.setTitle("닫기", for: .normal)
        closeButton.setTitleColor(.gray1, for: .normal)
        closeButton.titleLabel?.font = FontManager.shared.medium(ofSize: 14)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

final class DatePlanCalendarStore {
    static let shared = DatePlanCalendarStore()
    static let didUpdateNotification = Notification.Name("DatePlanCalendarStoreDidUpdate")

    private var plans: [DatePlanModel] = []

    private init() {}

    func update(plans: [DatePlanModel]) {
        self.plans = plans
        NotificationCenter.default.post(name: DatePlanCalendarStore.didUpdateNotification, object: nil)
    }

    func plans(on dateComponents: DateComponents) -> [DatePlanModel] {
        guard let date = Calendar.current.date(from: dateComponents) else { return [] }
        let target = date.toString(type: .yearToDayHipen)
        return plans.filter { plan in
            guard let planDate = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) else { return false }
            return planDate.toString(type: .yearToDayHipen) == target
        }
    }

    var planDateComponents: [DateComponents] {
        plans.compactMap { plan in
            guard let date = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) else { return nil }
            return Calendar.current.dateComponents([.year, .month, .day], from: date)
        }
    }
}

final class DatePlanSheetVC: UIViewController {
    private let pickedModel: SearchedModel
    private let onSave: (DatePlanDraft) -> Void

    private let titleLabel = UILabel()
    private let placeLabel = UILabel()
    private let addressLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let memoField = UITextField()
    private let notifySwitch = UISwitch()
    private let saveButton = UIButton()

    init(pickedModel: SearchedModel, onSave: @escaping (DatePlanDraft) -> Void) {
        self.pickedModel = pickedModel
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setLayout()
    }

    private func configure() {
        titleLabel.text = "데이트 예약"
        titleLabel.font = FontManager.shared.semiBold(ofSize: 18)
        titleLabel.textColor = .gray1

        placeLabel.text = pickedModel.title
        placeLabel.font = FontManager.shared.medium(ofSize: 16)
        placeLabel.textColor = .gray1
        placeLabel.numberOfLines = 2

        addressLabel.text = pickedModel.roadAddress.isEmpty ? pickedModel.address : pickedModel.roadAddress
        addressLabel.font = FontManager.shared.regular(ofSize: 13)
        addressLabel.textColor = .gray2
        addressLabel.numberOfLines = 2

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()

        memoField.placeholder = "메모"
        memoField.font = FontManager.shared.regular(ofSize: 14)
        memoField.borderStyle = .roundedRect

        notifySwitch.isOn = true

        saveButton.setTitle("예약하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FontManager.shared.semiBold(ofSize: 16)
        saveButton.backgroundColor = .primary1
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func setLayout() {
        let notifyLabel = UILabel()
        notifyLabel.text = "알림 받기"
        notifyLabel.font = FontManager.shared.regular(ofSize: 14)
        notifyLabel.textColor = .gray1

        let notifyStack = UIStackView(arrangedSubviews: [notifyLabel, notifySwitch])
        notifyStack.axis = .horizontal
        notifyStack.alignment = .center
        notifyStack.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            placeLabel,
            addressLabel,
            datePicker,
            memoField,
            notifyStack,
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func saveTapped() {
        let memo = memoField.text ?? ""
        let draft = DatePlanDraft(name: pickedModel.title,
                                  memo: memo,
                                  mapX: pickedModel.mapx,
                                  mapY: pickedModel.mapy,
                                  roadAddress: pickedModel.roadAddress,
                                  address: pickedModel.address,
                                  scheduledAt: datePicker.date,
                                  notifyEnabled: notifySwitch.isOn)
        onSave(draft)
        dismiss(animated: true)
    }
}

final class DatePlanTimeEditSheetVC: UIViewController {
    private let plan: DatePlanModel
    private let resetCheckIns: Bool
    private let onSave: (DatePlanModel) -> Void

    private let titleLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton()

    init(plan: DatePlanModel, resetCheckIns: Bool, onSave: @escaping (DatePlanModel) -> Void) {
        self.plan = plan
        self.resetCheckIns = resetCheckIns
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setLayout()
    }

    private func configure() {
        titleLabel.text = "예약 시간 수정"
        titleLabel.font = FontManager.shared.semiBold(ofSize: 18)
        titleLabel.textColor = .gray1

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        if let date = Date.stringToDate(dateString: plan.scheduledAt, type: .yearToSecond) {
            datePicker.date = date
        }

        saveButton.setTitle("변경하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FontManager.shared.semiBold(ofSize: 16)
        saveButton.backgroundColor = .primary1
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func setLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, datePicker, saveButton])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func saveTapped() {
        let checkIns = resetCheckIns ? [:] : plan.checkIns
        let arrivalRecords = resetCheckIns ? [:] : plan.arrivalRecords
        let updatedPlan = DatePlanModel(uuid: plan.uuid,
                                        name: plan.name,
                                        memo: plan.memo,
                                        mapX: plan.mapX,
                                        mapY: plan.mapY,
                                        roadAddress: plan.roadAddress,
                                        address: plan.address,
                                        scheduledAt: datePicker.date.toString(type: .yearToSecond),
                                        createdAt: plan.createdAt,
                                        createdBy: plan.createdBy,
                                        notifyEnabled: plan.notifyEnabled,
                                        radiusMeters: plan.radiusMeters,
                                        dwellSeconds: plan.dwellSeconds,
                                        checkIns: checkIns,
                                        arrivalRecords: arrivalRecords,
                                        isOnTime: resetCheckIns ? nil : plan.isOnTime,
                                        isCompleted: resetCheckIns ? nil : plan.isCompleted)
        onSave(updatedPlan)
        dismiss(animated: true)
    }
}

final class MeetingStampStore {
    static let shared = MeetingStampStore()
    static let didUpdateNotification = Notification.Name("MeetingStampStoreDidUpdate")

    struct Stamp: Codable {
        let dateString: String
        let latitude: Double?
        let longitude: Double?
    }

    private let stampsKey = "meetingStamps"
    private let pendingKey = "meetingStampPending"

    func stamps(coupleId: String?) -> [Stamp] {
        loadStamps(coupleId: coupleId)
    }

    func pendingStamp(coupleId: String?) -> Stamp? {
        loadPending(coupleId: coupleId)
    }

    func setPending(date: Date, location: CLLocation?, coupleId: String? = nil) {
        let stamp = Stamp(
            dateString: date.toString(type: .yearToDayHipen),
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        savePending(stamp, coupleId: coupleId)
    }

    func clearPending(coupleId: String? = nil) {
        UserDefaults.standard.removeObject(forKey: key(base: pendingKey, coupleId: coupleId))
    }

    func savePendingStamp(coupleId: String? = nil) -> Bool {
        guard let pending = pendingStamp(coupleId: coupleId) else { return false }
        clearPending(coupleId: coupleId)
        return addStamp(pending, coupleId: coupleId)
    }

    func hasStamp(on components: DateComponents, coupleId: String? = nil) -> Bool {
        guard let date = Calendar.current.date(from: components) else { return false }
        let dateString = date.toString(type: .yearToDayHipen)
        return loadStamps(coupleId: coupleId).contains(where: { $0.dateString == dateString })
    }

    func stampedDateComponents(coupleId: String? = nil) -> [DateComponents] {
        loadStamps(coupleId: coupleId)
            .compactMap { Date.stringToDate(dateString: $0.dateString, type: .yearToDayHipen) }
            .map { Calendar.current.dateComponents([.year, .month, .day], from: $0) }
    }

    func addStamp(date: Date, location: CLLocation?, coupleId: String? = nil) -> Bool {
        let stamp = Stamp(
            dateString: date.toString(type: .yearToDayHipen),
            latitude: location?.coordinate.latitude,
            longitude: location?.coordinate.longitude
        )
        return addStamp(stamp, coupleId: coupleId)
    }

    private func addStamp(_ stamp: Stamp, coupleId: String? = nil) -> Bool {
        var stamps = loadStamps(coupleId: coupleId)
        guard stamps.contains(where: { $0.dateString == stamp.dateString }) == false else { return false }
        stamps.append(stamp)
        saveStamps(stamps, coupleId: coupleId)
        NotificationCenter.default.post(name: MeetingStampStore.didUpdateNotification, object: nil)
        return true
    }

    private func loadStamps(coupleId: String? = nil) -> [Stamp] {
        let key = key(base: stampsKey, coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Stamp].self, from: data)) ?? []
    }

    private func saveStamps(_ stamps: [Stamp], coupleId: String? = nil) {
        guard let data = try? JSONEncoder().encode(stamps) else { return }
        let key = key(base: stampsKey, coupleId: coupleId)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadPending(coupleId: String? = nil) -> Stamp? {
        let key = key(base: pendingKey, coupleId: coupleId)
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Stamp.self, from: data)
    }

    private func savePending(_ stamp: Stamp, coupleId: String? = nil) {
        guard let data = try? JSONEncoder().encode(stamp) else { return }
        let key = key(base: pendingKey, coupleId: coupleId)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func key(base: String, coupleId: String?) -> String {
        guard let coupleId, coupleId.isEmpty == false else { return base }
        return "\(base)-\(coupleId)"
    }
}

final class BLEProximityService: NSObject {
    private enum Constants {
        static var serviceUUID: CBUUID { BLEConfiguration.shared.serviceUUID }
        static let localNamePrefix = BLEConfiguration.shared.localNamePrefix
        static let advertisedIdLength = BLEConfiguration.shared.advertisedIdLength
        static let proximityRssiThreshold = BLEConfiguration.shared.proximityRssiThreshold
        static let cooldownSeconds: TimeInterval = BLEConfiguration.shared.cooldownSeconds
        static let centralRestoreIdentifier = BLEConfiguration.shared.centralRestoreIdentifier
        static let peripheralRestoreIdentifier = BLEConfiguration.shared.peripheralRestoreIdentifier
    }

    var onProximityDetected: (() -> Void)?
    var onProximityHeartbeat: ((Date) -> Void)?

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var lastTriggerDate: Date?
    private var didAddService = false
    private var coupleId: String?
    private var serviceObserver: NSObjectProtocol?

    func configure(coupleId: String?) {
        if let coupleId, coupleId.isEmpty == false {
            self.coupleId = coupleId
        } else {
            self.coupleId = nil
        }
    }

    override init() {
        super.init()
        serviceObserver = NotificationCenter.default.addObserver(
            forName: BLEConfiguration.serviceUUIDUpdatedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleServiceUUIDUpdate()
        }
    }

    deinit {
        if let observer = serviceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start() {
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self,
                                             queue: .main,
                                             options: [
                                                CBCentralManagerOptionShowPowerAlertKey: true,
                                                CBCentralManagerOptionRestoreIdentifierKey: Constants.centralRestoreIdentifier
                                             ])
        } else if centralManager?.state == .poweredOn {
            startScanning()
        }

        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self,
                                                    queue: .main,
                                                    options: [
                                                        CBPeripheralManagerOptionRestoreIdentifierKey: Constants.peripheralRestoreIdentifier
                                                    ])
        } else if peripheralManager?.state == .poweredOn {
            setupServiceIfNeeded()
            startAdvertising()
        }
    }

    private func handleServiceUUIDUpdate() {
        guard centralManager != nil || peripheralManager != nil else { return }
        stop()
        start()
    }

    func stop() {
        centralManager?.stopScan()
        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        didAddService = false
    }

    private func startScanning() {
        centralManager?.scanForPeripherals(
            withServices: [Constants.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    private func setupServiceIfNeeded() {
        guard didAddService == false else { return }
        let service = CBMutableService(type: Constants.serviceUUID, primary: true)
        peripheralManager?.add(service)
        didAddService = true
    }

    private func startAdvertising() {
        let name = advertisedLocalName()
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Constants.serviceUUID],
            CBAdvertisementDataLocalNameKey: name
        ])
    }

    private func handleProximity(rssi: NSNumber) {
        if rssi.intValue == 127 { return }
        guard rssi.intValue >= Constants.proximityRssiThreshold else { return }
        onProximityHeartbeat?(Date())
        let now = Date()
        if let lastTriggerDate, now.timeIntervalSince(lastTriggerDate) < Constants.cooldownSeconds {
            return
        }
        lastTriggerDate = now
        onProximityDetected?()
    }

    private func advertisedLocalName() -> String {
        guard let coupleId, coupleId.isEmpty == false else { return Constants.localNamePrefix }
        let shortId = String(coupleId.prefix(Constants.advertisedIdLength))
        return "\(Constants.localNamePrefix):\(shortId)"
    }
}

extension BLEProximityService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        startScanning()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        guard localName.hasPrefix(Constants.localNamePrefix) else { return }
        if let coupleId, coupleId.isEmpty == false {
            let shortId = String(coupleId.prefix(Constants.advertisedIdLength))
            let expected = "\(Constants.localNamePrefix):\(shortId)"
            guard localName == expected else { return }
        }
      
        handleProximity(rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        startScanning()
    }
}

extension BLEProximityService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        setupServiceIfNeeded()
        startAdvertising()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil {
            startAdvertising()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        setupServiceIfNeeded()
        startAdvertising()
    }
}
