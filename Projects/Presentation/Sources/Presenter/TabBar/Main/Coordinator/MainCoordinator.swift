//
//  MainCoordinator.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/07/26.
//

import UIKit
import Domain
import Core
public final class MainCoordinator: Coordinator {
    
    public var delegate: CoordinatorDelegate?
    public var navigationController: UINavigationController
    public var childCoordinators: [Coordinator]
    
    private let dependencies: PresentationDependencyProviding
    private let adMobRepo = AdmobRepository()
    private let uploadPlaceUseCase: PlaceUseCase
    
    private var mapSearchVM: MapSearchVM?
    private var mapVM: MapVM?
    private var bottomSheet: BottomSheetVC?
    
    public init(_ navigationController: UINavigationController, dependencies: PresentationDependencyProviding) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.dependencies = dependencies
        self.uploadPlaceUseCase = PlaceUseCaseImpl(repository: dependencies.makeCouplePlaceRepository())
    }
    
    public func start() {
        showMapVC(pickedModel: nil)
    }

}

extension MainCoordinator {
    
    public func showMapVC(pickedModel: SearchedModel?) {
        let vm = MapVM(
            coordinator: self,
            mainUseCase: MainUseCase(
                firebaseService: dependencies.firebaseService,
                userRepository: dependencies.makeUserRepository(),
                coupleRepository: dependencies.makeCoupleRepository(),
                adMobRepo: self.adMobRepo,
                sharedDataRepo: dependencies.sharedDataRepo,
                notificationService: dependencies.pushNotificationService
            ),
            uploadPlaceUseCase: uploadPlaceUseCase,
            datePlanUseCase: DatePlanUseCaseImpl(repository: dependencies.makeDatePlanRepository()),
            pushNotificationService: dependencies.pushNotificationService
        )
        self.mapVM = vm
        let viewController = MapVC(viewModel: vm
        )
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
   
    public func showAlarmFlow() {
        let alarmCoordinator = AlarmCoordinator(self.navigationController, dependencies: dependencies)
        childCoordinators.append(alarmCoordinator)
        alarmCoordinator.delegate = self
        alarmCoordinator.start()
    }
    
    public func showDdayFlow() {
        let dDayCoordinator = DdayCoordinator(self.navigationController, dependencies: dependencies)
        childCoordinators.append(dDayCoordinator)
        dDayCoordinator.delegate = self
        dDayCoordinator.start()
    }
    
    
    //MARK: Push funcs
    public func pushMapSearchVC() {
        let vm = MapSearchVM(coordinator: self, searchUseCase: SearchUseCase(searchRepo: dependencies.makeSearchRepository()))
        let viewController = MapSearchVC(viewModel: vm)
        vm.onLocationSelected.bind(to: self.mapVM!.pickedModel).disposed(by: viewController.disposeBag)
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    
    public func setupSheet(pickedModel: SearchedModel?, placeModel: CouplePlaceModel?, type:String) {
        self.bottomSheet = nil
        self.bottomSheet = BottomSheetVC(viewModel: mapVM!)
        guard let bottomSheet else {return}
        var startingHeight = 0.0
        bottomSheet.modalPresentationStyle = .pageSheet
        bottomSheet.isModalInPresentation = false
        
        
        if type == "small", let pickedModel {
            bottomSheet.setSmallView(pickedModel: pickedModel)
            startingHeight = 120
        } else if let placeModel {
            if let urls = placeModel.imageURLs, urls.isEmpty {
                startingHeight = 160
                bottomSheet.setInformView(placeModel: placeModel, imageExist: false)
            } else {
                startingHeight = 320
                bottomSheet.setInformView(placeModel: placeModel, imageExist: true)
            }
        }
  
        if let sheet = bottomSheet.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("custom"), resolver: { _ in
                    return startingHeight
                })
                sheet.selectedDetentIdentifier = .some(.init("custom"))
                // 드래그를 멈추면 그 위치에 멈추는 지점: default는 large()
                sheet.detents = [customDetent]
                // sheet로 present된 viewController내부를 scroll하면 sheet가 움직이지 않고 내부 컨텐츠를 스크롤되도록 설정
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                // grabber바 보이도록 설정
                sheet.prefersGrabberVisible = false
                // corner 값 설정
                sheet.preferredCornerRadius = 16
            } else {
                // Fallback on earlier versions
            }
          
        }
        self.navigationController.present(bottomSheet, animated: false, completion: nil)
        
    }

    public func presentRecordCreation(pickedModel: SearchedModel, memo: String) {
        self.bottomSheet = nil
        self.bottomSheet = BottomSheetVC(viewModel: mapVM!)
        guard let bottomSheet else { return }

        bottomSheet.modalPresentationStyle = .pageSheet
        bottomSheet.isModalInPresentation = false
        bottomSheet.loadViewIfNeeded()
        self.navigationController.present(bottomSheet, animated: false) {
            bottomSheet.setRecordCreationView(pickedModel: pickedModel, memo: memo)
        }
    }
    
    public func finish() {
        self.delegate?.didFinish(childCoordinator: self)
    }
    

}

extension MainCoordinator: CoordinatorDelegate {
    public func didFinish(childCoordinator: Coordinator) {
        self.childCoordinators = []
        if childCoordinator is DdayCoordinator || childCoordinator is AlarmCoordinator {
            self.navigationController.popViewController(animated: true)
        }
    }
}
