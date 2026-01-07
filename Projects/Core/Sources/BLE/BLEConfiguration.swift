import CoreBluetooth
import CryptoKit

public final class BLEConfiguration {
    public static let shared = BLEConfiguration()

    public static let defaultServiceUUIDString = "00000000-0000-0000-0000-000000000000"
    public static let defaultCharacteristicUUIDString = "00000000-0000-0000-0000-000000000001"

    public let localNamePrefix = "MeloMeterNear"
    public let advertisedIdLength = 12
    public let proximityRssiThreshold = -65
    public let cooldownSeconds: TimeInterval = 600
    public let centralRestoreIdentifier = "com.melometer.ble.central.restore"
    public let peripheralRestoreIdentifier = "com.melometer.ble.peripheral.restore"

    private(set) public var serviceUUID: CBUUID
    private(set) public var characteristicUUID: CBUUID

    public static let serviceUUIDUpdatedNotification = Notification.Name("BLEConfiguration.serviceUUIDUpdated")

    private init() {
        self.serviceUUID = CBUUID(string: Self.defaultServiceUUIDString)
        self.characteristicUUID = CBUUID(string: Self.defaultCharacteristicUUIDString)
    }

    @discardableResult
    public func updateServiceUUID(with string: String?) -> Bool {
        guard let string, string.isEmpty == false else { return false }
        let candidate = CBUUID(string: string)
        guard candidate != serviceUUID else { return false }
        serviceUUID = candidate
        NotificationCenter.default.post(name: Self.serviceUUIDUpdatedNotification, object: nil)
        return true
    }

    @discardableResult
    public func updateCharacteristicUUID(with string: String?) -> Bool {
        guard let string, string.isEmpty == false else { return false }
        let candidate = CBUUID(string: string)
        guard candidate != characteristicUUID else { return false }
        characteristicUUID = candidate
        return true
    }

    public func proximityServiceUUID(for coupleId: String?) -> CBUUID {
        guard let coupleId, coupleId.isEmpty == false else { return serviceUUID }
        let seed = "\(serviceUUID.uuidString)|\(coupleId)"
        let derived = Self.makeDeterministicUUID(seed: seed)
        return CBUUID(string: derived.uuidString)
    }

    private static func makeDeterministicUUID(seed: String) -> UUID {
        let digest = SHA256.hash(data: Data(seed.utf8))
        var uuidBytes = uuid_t()
        withUnsafeMutableBytes(of: &uuidBytes) { bytes in
            bytes.copyBytes(from: digest.prefix(16))
        }
        return UUID(uuid: uuidBytes)
    }
}
