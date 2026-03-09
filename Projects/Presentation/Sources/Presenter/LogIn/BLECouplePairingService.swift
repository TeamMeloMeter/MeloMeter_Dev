//
//  BLECouplePairingService.swift
//  MeloMeter
//
//  Created by Codex on 2025/12/28.
//

import Foundation
import CoreBluetooth
#if canImport(Core)
import Core
#endif

final class BLECouplePairingService: NSObject {
    private enum Constants {
        static var serviceUUID: CBUUID { BLEConfiguration.shared.serviceUUID }
        static var characteristicUUID: CBUUID { BLEConfiguration.shared.characteristicUUID }
        static let localName = "MeloMeterPair"
    }

    var onInviteCodeReceived: ((String) -> Void)?

    private var centralManager: CBCentralManager?
    private var peripheralManager: CBPeripheralManager?
    private var discoveredPeripheral: CBPeripheral?
    private var characteristic: CBMutableCharacteristic?
    private var inviteCodeData: Data
    private var didReceiveInviteCode = false
    private var didAddService = false

    init(inviteCode: String) {
        self.inviteCodeData = inviteCode.data(using: .utf8) ?? Data()
        super.init()
    }

    func updateInviteCode(_ inviteCode: String) {
        inviteCodeData = inviteCode.data(using: .utf8) ?? Data()
    }

    func start() {
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: .main)
        } else if centralManager?.state == .poweredOn {
            startScanning()
        }

        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
        } else if peripheralManager?.state == .poweredOn {
            setupServiceIfNeeded()
            startAdvertising()
        }
    }

    func stop() {
        centralManager?.stopScan()
        if let discoveredPeripheral {
            centralManager?.cancelPeripheralConnection(discoveredPeripheral)
        }
        discoveredPeripheral = nil

        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        didAddService = false
        characteristic = nil
    }

    private func startScanning() {
        guard didReceiveInviteCode == false else { return }
        centralManager?.scanForPeripherals(withServices: [Constants.serviceUUID], options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    private func setupServiceIfNeeded() {
        guard didAddService == false else { return }
        let characteristic = CBMutableCharacteristic(
            type: Constants.characteristicUUID,
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        let service = CBMutableService(type: Constants.serviceUUID, primary: true)
        service.characteristics = [characteristic]
        self.characteristic = characteristic
        peripheralManager?.add(service)
        didAddService = true
    }

    private func startAdvertising() {
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Constants.serviceUUID],
            CBAdvertisementDataLocalNameKey: Constants.localName
        ])
    }
}

extension BLECouplePairingService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        startScanning()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        guard discoveredPeripheral == nil else { return }
        discoveredPeripheral = peripheral
        central.stopScan()
        peripheral.delegate = self
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([Constants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        discoveredPeripheral = nil
        startScanning()
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        discoveredPeripheral = nil
        if didReceiveInviteCode == false {
            startScanning()
        }
    }
}

extension BLECouplePairingService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == Constants.serviceUUID {
            peripheral.discoverCharacteristics([Constants.characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.uuid == Constants.characteristicUUID {
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else { return }
        guard characteristic.uuid == Constants.characteristicUUID else { return }
        guard let data = characteristic.value,
              let inviteCode = String(data: data, encoding: .utf8),
              inviteCode.isEmpty == false else { return }

        didReceiveInviteCode = true
        onInviteCodeReceived?(inviteCode)
        stop()
    }
}

extension BLECouplePairingService: CBPeripheralManagerDelegate {
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

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == Constants.characteristicUUID else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }
        guard request.offset <= inviteCodeData.count else {
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }
        request.value = inviteCodeData.subdata(in: request.offset..<inviteCodeData.count)
        peripheral.respond(to: request, withResult: .success)
    }
}
