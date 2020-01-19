//
//  BLE.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/18/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import Foundation
import SwiftUI
import CoreBluetooth
import CoreLocation



/*


class BLELocation:  UIResponder, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
   
    
    func JStartup() {
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        print("setting field vars nil")
        currentField = nil
        currentImageIndex = nil
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestLocation()
        
        return
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        blePeripheral = peripheral
        peripherals.append(peripheral)
        RSSIs.append(RSSI)
        peripheral.delegate = self
        
        if blePeripheral != nil {
            //print("Found new pheripheral devices with services")
            //print("Peripheral name: \(String(describing: peripheral.name))")
            //print("**********************************")
            //print ("Advertisement Data : \(advertisementData)")
        }
        //
        // check if we have the BTE id of the device we are configured for
        // todo: arrange persistent storage for this value at a later time .. a config option is needed
        //
        // C43BD593-DA12-7816-79D0-8B39B1E0C424
        // 982526B8-658D-D0CB-5280-2049D0BF8305
        // 087F253D-24A7-EF4E-9D4D-09650EC0C673
        if blePeripheral?.identifier.uuidString == "087F253D-24A7-EF4E-9D4D-09650EC0C673" {
            //print("YUP!")
            characteristicASCIIValue = ""
            print("Connecting to BLE device")
            connectToDevice()
        } else {
            //print("NOPE!")
            print("id:\(String(describing: blePeripheral?.identifier.uuidString))")
        }
    }
    
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            print("Lat: \(location.coordinate.latitude)")
            print("Lon: \(location.coordinate.longitude)")
            print("DEBUG: Inserting BDS")
            iPadLat = 41.339733//location.coordinate.latitude
            iPadLon = -74.431618//location.coordinate.longitude
            
            
            currentField = findField(lat: iPadLat, lon: iPadLon)
            if currentField != nil {
                print("We are at a known field!")
                print ("shortname: \(String(describing: currentField?.shortname))")
                currentImageIndex = 0
                //print("image: \(currentField!.images[currentImageIndex!].filename)")
                currentImage = currentField!.images[currentImageIndex!].filename
            } else {
                currentImageIndex = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    /*
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //print("application override point")
        /*Our key player in this app will be our CBCentralManager. CBCentralManager objects are used to manage discovered or connected remote peripheral devices (represented by CBPeripheral objects), including scanning for, discovering, and connecting to advertising peripherals.
         */
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        print("setting field vars nil")
        currentField = nil
        currentImageIndex = nil
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestLocation()
        
        return true
    }
    
    */
    
    func startScan() {
        peripherals = []
        print("Now Scanning...")
        timer.invalidate()
        centralManager?.scanForPeripherals(withServices: [BLEService_UUID] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        Timer.scheduledTimer(timeInterval: 17, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
    }
    
    /*We also need to stop scanning at some point so we'll also create a function that calls "stopScan"*/
    //@objc func cancelScan() {
    @objc func cancelScan() {
        centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
    
    
    //centralManager?.stopScan()
    
    
    
    //Peripheral Connections: Connecting, Connected, Disconnected
    
    //-Connection
    
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connect(_:options:) is successful. You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    //-Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("*****************************")
        //print("Connection complete")
        BLEConnected = true
        let BLE_id = blePeripheral!.identifier.uuidString
        //print("Peripheral ID: \(BLE_id)")
        //print("Peripheral info: \(String(describing: blePeripheral))")
        
        //Stop Scan- We don't need to scan once we've connected to a peripheral. We got what we came for.
        centralManager?.stopScan()
        //print("Called centralManager: Scan Stopped")
        
        //Erase data that we might have
        data.length = 0
        
        peripheral.delegate = self
        
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([BLEService_UUID])
        
        updateIncomingData()
        
    }
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     */
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Failed to connect to peripheral")
            return
        }
    }
    
    
    func disconnectAllConnection() {
        centralManager.cancelPeripheralConnection(blePeripheral!)
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //print("***************** did discover characteristics for **************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        //print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                //print("Rx Characteristic: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                //print("Tx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //print("******************** did update notification state for ***********************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    
    func refreshAction(_ sender: AnyObject) {
        // was @ibaction func refreshAction
        disconnectFromDevice()
        peripherals = []
        RSSIs = []
        startScan()
    }
    
    /*
     Invoked when the central manager’s state is updated.
     This is where we kick off the scan if Bluetooth is turned on.
     */
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // We will just handle it the easy way here: if Bluetooth is on, proceed...start scan!
            print("Bluetooth Enabled")
            startScan()
            
        } else {
            //If Bluetooth is off, display a UI alert message saying "Bluetooth is not enable" and "Make sure that your bluetooth is turned on"
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
            
        }
    }
    
    // Getting Values From Characteristic
    
    /*After you've found a characteristic of a service that you are interested in, you can read the characteristic's value by calling the peripheral "readValueForCharacteristic" method within the "didDiscoverCharacteristicsFor service" delegate.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("**************** did update Value for characteristic")
        if characteristic == rxCharacteristic {
            //print("char: \(characteristic), rxChar: \(String(describing: rxCharacteristic))")
            if characteristic.value == nil {
                //print("===============>>>>>>>>>>>>  characteristic.value is nil")
                return
            }
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                //print("CAV: \(characteristicASCIIValue)")
                //print("ASC: \(ASCIIstring)")
                //print("Value Recieved: \((characteristicASCIIValue as String))")
                //var valueArray = characteristicASCIIValue.components(separatedBy: ",")
                //print("ValArray: \(valueArray[0], valueArray[1], valueArray[2])")
                //writeValue(data: "100.123")
                updateIncomingData()
                ////NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                
            }
        }
    }
    
    /*
     Invoked when you discover the peripheral’s available services.
     This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //print("********** did discover services *********************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            
            peripheral.discoverCharacteristics(nil, for: service)
            // bleService = service
        }
        //print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //print("********* did discover descriptors for **********************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            
            //for x in characteristic.descriptors!{
            //   let descript = x as CBDescriptor!
            //    print("function name: DidDiscoverDescriptorForChar \(String(describing: descript?.description))")
            //    print("Rx Value \(String(describing: rxCharacteristic?.value))")
            //    print("Tx Value \(String(describing: txCharacteristic?.value))")
            // }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        BLEConnected = false
        //NotificationCenter.default.removeObserver(self)
        // no point ot restarting scan here .. need to check periodically in incoming data loop
        //print("Restarting Scan")
        //startScan()
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        //print("Message sent")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        print("didWriteValueFor succeeded")
    }
    
    
    //-Terminate all Peripheral Connection
    
    //Peripheral Connections: Connecting, Connected, Disconnected
    
    //-Connection
    func connectToDevice () {
        centralManager?.connect(blePeripheral!, options: nil)
    }
    
    //-Terminate all Peripheral Connection
    /*
     Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    func disconnectFromDevice () {
        if blePeripheral != nil {
            // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
            // Therefore, we will just disconnect from the peripheral
            centralManager?.cancelPeripheralConnection(blePeripheral!)
        }
    }
    //-Terminate all Peripheral Connection
    /*
     Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    
}
*/
