import CoreBluetooth
import Foundation

public final class BLEProximityMonitor: NSObject {
    public static let shared = BLEProximityMonitor()
    public static let proximityDetectedNotification = Notification.Name("BLEProximityMonitorDetected")
    public static let proximityHeartbeatNotification = Notification.Name("BLEProximityMonitorHeartbeat")

    public static let meetingMissingThreshold: TimeInterval = 3600

    private enum Constants {
        static let proximityRssiThreshold = BLEConfiguration.shared.proximityRssiThreshold
        static let cooldownSeconds = BLEConfiguration.shared.cooldownSeconds
        static let centralRestoreIdentifier = BLEConfiguration.shared.centralRestoreIdentifier
        static let peripheralRestoreIdentifier = BLEConfiguration.shared.peripheralRestoreIdentifier
    }

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var lastTriggerDate: Date?
    private var didAddService = false
    private var coupleId: String?
    private var serviceObserver: NSObjectProtocol?
    private var isMonitoring = false

    private override init() {
        super.init()
        serviceObserver = NotificationCenter.default.addObserver(
            forName: BLEConfiguration.serviceUUIDUpdatedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restartIfNeeded()
        }
    }

    deinit {
        if let observer = serviceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    public func configure(coupleId: String?) {
        let trimmed = coupleId?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = trimmed?.isEmpty == false ? trimmed : nil
        guard normalized != self.coupleId else { return }
        self.coupleId = normalized
        lastTriggerDate = nil
        restartIfNeeded()
    }

    public func start(coupleId: String? = nil) {
        if coupleId != nil {
            configure(coupleId: coupleId)
        }
        guard let activeCoupleId = self.coupleId, activeCoupleId.isEmpty == false else { return }
        isMonitoring = true
        TogetherTimeStore.shared.refreshState(now: Date(),
                                              coupleId: activeCoupleId,
                                              missingThreshold: Self.meetingMissingThreshold)
        if centralManager == nil {
            centralManager = CBCentralManager(
                delegate: self,
                queue: .main,
                options: [
                    CBCentralManagerOptionShowPowerAlertKey: true,
                    CBCentralManagerOptionRestoreIdentifierKey: Constants.centralRestoreIdentifier
                ]
            )
        } else if centralManager?.state == .poweredOn {
            startScanning()
        }

        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(
                delegate: self,
                queue: .main,
                options: [
                    CBPeripheralManagerOptionRestoreIdentifierKey: Constants.peripheralRestoreIdentifier
                ]
            )
        } else if peripheralManager?.state == .poweredOn {
            setupServiceIfNeeded()
            startAdvertising()
        }
    }

    public func stop() {
        isMonitoring = false
        centralManager?.stopScan()
        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        didAddService = false
    }

    public func refreshSessionState(now: Date = Date()) {
        guard let coupleId, coupleId.isEmpty == false else { return }
        TogetherTimeStore.shared.refreshState(now: now,
                                              coupleId: coupleId,
                                              missingThreshold: Self.meetingMissingThreshold)
    }

    private func restartIfNeeded() {
        guard isMonitoring else { return }
        stop()
        start()
    }

    private func serviceUUID() -> CBUUID {
        BLEConfiguration.shared.proximityServiceUUID(for: coupleId)
    }

    private func startScanning() {
        centralManager?.scanForPeripherals(
            withServices: [serviceUUID()],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    private func setupServiceIfNeeded() {
        guard didAddService == false else { return }
        let service = CBMutableService(type: serviceUUID(), primary: true)
        peripheralManager?.add(service)
        didAddService = true
    }

    private func startAdvertising() {
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID()]
        ])
    }

    private func handleProximity(rssi: NSNumber) {
        if rssi.intValue == 127 { return }
        guard rssi.intValue >= Constants.proximityRssiThreshold else { return }
        guard let coupleId, coupleId.isEmpty == false else { return }
        let now = Date()
        TogetherTimeStore.shared.recordHeartbeat(at: now,
                                                 coupleId: coupleId,
                                                 missingThreshold: Self.meetingMissingThreshold)
        NotificationCenter.default.post(
            name: Self.proximityHeartbeatNotification,
            object: self,
            userInfo: ["date": now]
        )

        if let lastTriggerDate, now.timeIntervalSince(lastTriggerDate) < Constants.cooldownSeconds {
            return
        }
        lastTriggerDate = now
        NotificationCenter.default.post(
            name: Self.proximityDetectedNotification,
            object: self,
            userInfo: ["date": now]
        )
    }
}

extension BLEProximityMonitor: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        guard coupleId != nil else { return }
        startScanning()
    }

    public func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any],
                               rssi RSSI: NSNumber) {
        handleProximity(rssi: RSSI)
    }

    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        guard coupleId != nil else { return }
        startScanning()
    }
}

extension BLEProximityMonitor: CBPeripheralManagerDelegate {
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        guard coupleId != nil else { return }
        setupServiceIfNeeded()
        startAdvertising()
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil {
            startAdvertising()
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        guard coupleId != nil else { return }
        setupServiceIfNeeded()
        startAdvertising()
    }
}
