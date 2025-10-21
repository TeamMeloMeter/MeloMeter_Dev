//
//  RxNMFMapViewTouchDelegateProxy.swift
//  MeloMeter
//
//  Created by 양승완 on 5/26/25.
//
import RxSwift
import RxCocoa
import NMapsMap
final class RxNMFMapViewTouchDelegateProxy:
    DelegateProxy<NMFMapView, NMFMapViewTouchDelegate>,
    DelegateProxyType,
    NMFMapViewTouchDelegate {

    static func registerKnownImplementations() {
        self.register { RxNMFMapViewTouchDelegateProxy(parentObject: $0, delegateProxy: self) }
    }

    static func currentDelegate(for object: NMFMapView) -> NMFMapViewTouchDelegate? {
        return object.touchDelegate
    }

    static func setCurrentDelegate(_ delegate: NMFMapViewTouchDelegate?, to object: NMFMapView) {
        object.touchDelegate = delegate
    }

    private let tapSubject = PublishSubject<NMGLatLng>()

    func mapView(_ mapView: NMFMapView, didTap mapPoint: NMGLatLng) {
        tapSubject.onNext(mapPoint)
    }

    var tapEvent: Observable<NMGLatLng> {
        return tapSubject.asObservable()
    }

    deinit {
        tapSubject.onCompleted()
    }
}
extension Reactive where Base: NMFMapView {
    var tap: Observable<NMGLatLng> {
        let proxy = RxNMFMapViewTouchDelegateProxy.proxy(for: base)
        return proxy.tapEvent
    }
}
