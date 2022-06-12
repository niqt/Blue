//
//  BLEManager.swift
//  Blue
//
//  Created by nicola on 16/11/21.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}


class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralBE: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    var peripheralsId = [UUID]()
    var thermometer: CBPeripheral!
    var serviceId = CBUUID(string: "00000001-710e-4a5b-8d75-3e5b444b3c3f")
    var readNotify = CBUUID(string: "00000002-710e-4a5b-8d75-3e5b444b3c3f")
    var readWrite = CBUUID(string: "00000003-710e-4a5b-8d75-3e5b444b3c3f")
    
    override init() {
        super.init()
        centralBE = CBCentralManager(delegate: self, queue: nil)
        centralBE.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
            if !peripheralsId.contains(peripheral.identifier) && peripheralName == "Thermometer" {
                peripheralsId.append(peripheral.identifier)
                peripherals.append(newPeripheral)
                stopScanning()
                self.thermometer = peripheral
                self.thermometer.delegate = self
                self.centralBE.connect(peripheral, options: nil)
            }
        }
        else {
            peripheralName = "Unknown"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DidConnect")
        discoverServices(peripheral: peripheral)
    }
    
    func startScanning() {
        print("startScanning")
        centralBE.scanForPeripherals(withServices: nil, options: nil)
    }
    func stopScanning() {
        print("stopScanning")
        centralBE.stopScan()
    }
    
    // Peripheral characteristics discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        service.characteristics?.forEach { char in
            print("CHAR id: \(char.uuid.uuidString) VALUE: \(String(describing: char.value) )")
            peripheral.readValue(for: char)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.value ?? "default")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        characteristic.descriptors?.forEach { desc in
            print("SERVICE \(desc.characteristic?.service!.uuid.uuidString ?? "Unknown"), DESC: \(desc)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("didModifyServices")
    }
    
    func disconnect(peripheral: CBPeripheral) {
        centralBE.cancelPeripheralConnection(peripheral)
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceId])
    }
    
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            print("not service")
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            print("ERROR didDiscoverServices")
            return
        }
        if services.count > 0 {
            discoverCharacteristics(peripheral: peripheral)
        }
    }
    
    func subscribeToNotifications(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("error \(error)")
            return
        }
        print(characteristic)
    }
    
    func readValue(characteristic: CBCharacteristic) {
        self.thermometer?.readValue(for: characteristic)
    }
}


