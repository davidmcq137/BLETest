//
//  BLELocation.swift
//
//
//  Created by David McQueeney on 1/18/20.
//  Copyright © 2020 David McQueeney. All rights reserved.
//

import Foundation
import SwiftUI
import CoreBluetooth
import CoreLocation
import Combine
import AVFoundation

var txCharacteristic : CBCharacteristic?
var rxCharacteristic : CBCharacteristic?
var blePeripheral : CBPeripheral?
var characteristicASCIIValue = NSString()
var BLEConnected = false
var BLETimer: Timer?
var InputBuffer: String = ""



var RSSIs = [NSNumber]()
var peripherals: [CBPeripheral] = []
var characteristicValue = [CBUUID: NSData]()
var data = NSMutableData()
var writeData: String = ""
var timer = Timer()
var characteristics = [String : CBCharacteristic]()

var horizontalAccuracyGPS: Double?
var foundFieldOnce: Bool = false

class BLELocation:  UIResponder, UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    
    var centralManager: CBCentralManager!
    static var blelocation = BLELocation()

    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @EnvironmentObject var tel: Telem

    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {


        blePeripheral = peripheral
        var new: Bool = false
        print("have new one: \( peripheral.name ?? "unknown") ")
        print("peripherals.count: \(peripherals.count)")
        
        if peripherals.count > 0 {
            for i in 0 ..< peripherals.count {
                print("i: \(i), peripheral: \(peripheral), peripherals[i]: \(peripherals[i])")
                if peripheral.name != peripherals[i].name {
                    print("new: \(peripheral.name ?? "unknown")")
                    new = true
                }
            }
            
            if new == false {
                print("Duplicate: \(peripheral)")
                return
            }
        }
        
        var str: String = "Device: " + (peripheral.name ?? "unknown")
        str = str + " UUID: " + (blePeripheral?.identifier.uuidString ?? "unknown") + " RSSI: \(RSSI)"
        
        peripherals.append(peripheral)
        RSSIs.append(RSSI)
        peripheral.delegate = self

        // put test here so as not to append duplicates...
        
        tele.BLEperipherals.append(str)
        tele.BLERSSIs.append(Int(truncating: RSSI))
        tele.BLEUUIDs.append(blePeripheral?.identifier.uuidString ?? "unknown")
        

        if blePeripheral != nil {
            print("Found new pheripheral devices with services")
            print("Peripheral name: \(peripheral.name ?? "unknown")")
            print("RSSI: \(RSSI)")
            //print ("Advertisement Data : \(advertisementData)")
        }
        
        let defaults = UserDefaults.standard
        let storedBLEUUID = defaults.object(forKey: "BLEUUID") as? String ?? "unknown"
        if storedBLEUUID == "unknown" {
            tele.BLEUserData = false
        } else {
            tele.BLEUserData = true
        }
        print("stored UUID: \(storedBLEUUID)")

        //
        // check if we have the BTE id of the device we are configured for
        // todo: arrange persistent storage for this value at a later time .. a config option is needed
        //
        // C43BD593-DA12-7816-79D0-8B39B1E0C424
        // 982526B8-658D-D0CB-5280-2049D0BF8305
        // 087F253D-24A7-EF4E-9D4D-09650EC0C673
        if blePeripheral?.identifier.uuidString == storedBLEUUID {
        //if blePeripheral?.identifier.uuidString == "087F253D-24A7-EF4E-9D4D-09650EC0C673" {
            print("YUP!")
            characteristicASCIIValue = ""
            connectToDevice()
        } else {
            print("NOPE!")
            print("id:\(String(describing: blePeripheral?.identifier.uuidString))")
        }
    }
    
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            print("Lat: \(location.coordinate.latitude)")
            print("Lon: \(location.coordinate.longitude)")
            
            //print("DEBUG: Inserting BDS")
            //tele.iPadLat = 41.339733//location.coordinate.latitude
            //tele.iPadLon = -74.431618//location.coordinate.longitude
            
            //print("DEBUG: Inserting GA Jets")
            //iPadLat = 33.1372    //location.coordinate.latitude
            //iPadLon = -84.611143 //location.coordinate.longitude

            tele.iPadLat = location.coordinate.latitude
            tele.iPadLon = location.coordinate.longitude
            
            let hAcc = location.horizontalAccuracy
            horizontalAccuracyGPS = hAcc
            let vAcc = location.verticalAccuracy
            print("hacc, vacc:", hAcc, vAcc)
            //tele.xxxlat = iPadLat
            //tele.xxxlon = iPadLon
            if hAcc > 10.0 {
                print("requesting location again")
                self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.manager.requestLocation()
                //return
            }
            
            if foundFieldOnce == false {
                _ = findField(lat: tele.iPadLat, lon: tele.iPadLon)
            }
            if activeField.imageIdx >= 0 {
                print("We are at a known field!")
                print ("shortname: \(String(activeField.shortname))")
                foundFieldOnce = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    func JAFOStartup() {
        
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        //print("centralManager: \(String(describing: centralManager))")
        
        /*
        let teststr="this is a test string"
         let testfilename = getDocumentsDirectory().appendingPathComponent("test.file")
         do {
             try teststr.write(to: testfilename, atomically: true, encoding: String.Encoding.utf8)
             print("written")
         } catch {
             print("bad write")
         }
        */
        
        let utterance = AVSpeechUtterance(string: "Launching JAFO, Requesting G P S location")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        utterance.rate = 0.5
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        
        print("setting field vars nil")
        activeField.imageIdx = -1
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestLocation()
        
    }
    
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
        if peripherals.count > 0 && !BLEConnected { // hopefully user went to BLE devices tab and picked one...
            print("****** Found at least one peripheral: RESTARTING SCAN *********")
            startScan()
        }
    }
    
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
        print("Peripheral ID: \(BLE_id)")
        print("Peripheral info: \(String(describing: blePeripheral))")
        
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
        print("Restarting Scan")
        startScan()
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
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        //print("application new scene session")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        //print("application discard scene session")
    }
 }



