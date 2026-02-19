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
    private let longTapSubject = PublishSubject<NMGLatLng>()

    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        tapSubject.onNext(latlng)
    }

    func mapView(_ mapView: NMFMapView, didLongTapMap latlng: NMGLatLng, point: CGPoint) {
        longTapSubject.onNext(latlng)
    }

    var tapEvent: Observable<NMGLatLng> {
        return tapSubject.asObservable()
    }

    var longTapEvent: Observable<NMGLatLng> {
        return longTapSubject.asObservable()
    }

    deinit {
        tapSubject.onCompleted()
        longTapSubject.onCompleted()
    }
}
public extension Reactive where Base: NMFMapView {
    public var tap: Observable<NMGLatLng> {
        let proxy = RxNMFMapViewTouchDelegateProxy.proxy(for: base)
        return proxy.tapEvent
    }

    public var longTap: Observable<NMGLatLng> {
        let proxy = RxNMFMapViewTouchDelegateProxy.proxy(for: base)
        return proxy.longTapEvent
    }
}
