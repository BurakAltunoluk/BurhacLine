//
//  BluetoothHelper.swift
//
//  Created by Alberto Pasca on 03/05/17.
//  Copyright © 2017 albertopasca.it. All rights reserved.
//

import UIKit
import CoreBluetooth


protocol BluetoothHelperDelegate {
    func didDataReceived( data: String )
    func didErrorReceived( data: String )
}

class BluetoothHelper: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var delegate : BluetoothHelperDelegate?
    public static let sharedBluetooth : BluetoothHelper = BluetoothHelper()
    var durum = 1

    fileprivate var manager : CBCentralManager!
    fileprivate var peripheral : CBPeripheral!
    fileprivate var characteristic : CBCharacteristic!
    // ---
    fileprivate let BEAN_NAME = "=Bsuerdaak"
    fileprivate let BEAN_SCRATCH_UUID = CBUUID(string:  "FFE1")
    fileprivate let BEAN_SERVICE_UUID = CBUUID(string:  "FFE0")
    // ---
    fileprivate let formatter = DateFormatter()

    
    func startService( _ delegate : BluetoothHelperDelegate? ) {
        manager = CBCentralManager(delegate: self, queue: nil)
        self.delegate = delegate
    }

    
    // +---------------------------------------------------------------------------+
    //MARK: - Scan for Devices
    // +---------------------------------------------------------------------------+
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            delegate?.didErrorReceived(data: "Bluetooth not available.")
            print( "••• Bluetooth not available." )
        }
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Connect to a Device
    // +---------------------------------------------------------------------------+
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(BEAN_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Get Services
    // +---------------------------------------------------------------------------+
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
        NotificationCenter.default.post(name: Notification.Name("done"), object: nil)
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Get Characteristics
    // +---------------------------------------------------------------------------+
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == BEAN_SERVICE_UUID {
                print( "••• SERVICE UUID: \(service.uuid.uuidString)" )
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Setup Notifications
    // +---------------------------------------------------------------------------+
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == BEAN_SCRATCH_UUID {
                print( "••• CHARACTERISTIC UUID: \(thisCharacteristic.uuid.uuidString)" )
                self.characteristic = characteristic
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
            }
        }
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Changes Are Coming
    // +---------------------------------------------------------------------------+
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == BEAN_SCRATCH_UUID {
            print( "••• didUpdateValueFor: \(characteristic.uuid.uuidString)" )

            self.characteristic = characteristic

            if (characteristic.value != nil) {
                if let data = String(data: characteristic.value!, encoding: .utf8) {
                    
                    print( "••• RECEIVED DATA: \(data)" )
                    delegate?.didDataReceived(data: data)
//                    if data.contains("#") {
//                        dataFromBLE = dataFromBLE.replacingOccurrences(of: "#", with: "")
//                        delegate?.didDataReceived(data: dataFromBLE)
//                        dataFromBLE = ""
//                    }

                }

            }

        }
    }
    
    // +---------------------------------------------------------------------------+
    //MARK: - Send date
    // +---------------------------------------------------------------------------+

    func sendDataToDevice( _ data: String ) {
        let dataToSend = "\(data)#".data(using: String.Encoding.utf8)
        
        if let p = self.peripheral, let c = self.characteristic {
            p.writeValue(dataToSend!, for: c, type: CBCharacteristicWriteType.withoutResponse)
            print( "••• WRITE VALUE: \(data) : \(c.uuid.uuidString)" )
        } else {
            print( "••• Haven't discovered device yet." )
        }
    }

    // +---------------------------------------------------------------------------+
    //MARK: - Disconnect and Try Again
    // +---------------------------------------------------------------------------+
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    

}

