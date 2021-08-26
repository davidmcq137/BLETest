//
//  updateIncomingData.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/17/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine
import CoreBluetooth

class Telem: ObservableObject {
    @Published var prevFRM: Double = 0
    @Published var prevAlt: Double = 0
    @Published var prevSpd: Double = 0
    @Published var prevEGT: Double = 0
    @Published var prevRPM: Double = 0
    @Published var heading: Double = 0
    @Published var stickP: [Double] = [0,0,0,0]
    @Published var currentXd: Double = 0
    @Published var currentYd: Double = 0
    @Published var BLERSSIs: [Int] = []
    @Published var BLEperipherals: [String] = []
    @Published var BLEUUIDs: [String] = []
    @Published var BLEUserData: Bool = true
    @Published var iPadLat: Double = 0
    @Published var iPadLon: Double = 0
}

var lastW: String = ""
var icount: Int = 0

func updateIncomingData () {
    
    ////NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
    ////notification in
    //print("cav \(characteristicASCIIValue)")
    //InputBuffer = InputBuffer + (characteristicASCIIValue as String) as String
    InputBuffer = InputBuffer.trimmingCharacters(in: .whitespacesAndNewlines) + (characteristicASCIIValue as String).trimmingCharacters(in: .whitespacesAndNewlines)
    //print("**SS**\(InputBuffer)**EE**")
    //print("next cav \( (characteristicASCIIValue as String).trimmingCharacters(in: .whitespacesAndNewlines))")
    //print("next InputBuffer \(InputBuffer)")
    let openIndex = InputBuffer.firstIndex(of: "(")
    let closeIndex = InputBuffer.firstIndex(of: ")")
    if openIndex == nil || closeIndex == nil {
        //print("RETURN FOR MORE DATA BEGIN")
        return
    }
    repeat {
        let openIndex = InputBuffer.firstIndex(of: "(")
        let closeIndex = InputBuffer.firstIndex(of: ")")
        if openIndex == nil || closeIndex == nil {
            //print("RETURN FOR MORE DATA REPEAT")
            return
        }
        if openIndex! > closeIndex! {
            print("OI > CI! \(InputBuffer)")
            InputBuffer.removeSubrange(InputBuffer.startIndex ..< openIndex!)
            //print("post remove: \(InputBuffer)")
            continue
        }
        
        var enclosedString = InputBuffer[openIndex! ..< closeIndex!]
        //print("enclosedString1:\(enclosedString)")
        //print("before InputBuffer:\(InputBuffer)")
        InputBuffer.removeSubrange(openIndex! ... closeIndex!)
        enclosedString.remove(at: openIndex!)
        //print("enclosedString2:\(enclosedString)")
        //print("new InputBuffer:\(InputBuffer)")
        
        let colonIndex = enclosedString.firstIndex(of: ":")
        if colonIndex == nil {
            continue
        }
        let valueArray = enclosedString.components(separatedBy: ":")
        if valueArray.count < 2 {
            print("bad valueArray: \(enclosedString)" )
            print("InputBuffer: \(InputBuffer)")
            return
        }
        let valName = valueArray[0]
        let valValue = valueArray[1]
        
        //print(valName, valValue)

        if valName == "Ctl" {
            //print(valValue)
            let stickS = valValue.components(separatedBy: "$")
            for i in 0 ..< stickS.count {
                tele.stickP[i]  = Double(stickS[i]) ?? 0
                if i == 1 || i == 3 {
                    tele.stickP[i] = -tele.stickP[i]
                }
            }
        } else if valName == "Pos" {
            readGPS(val: valValue)
        } else if valName == "XYP" {
            readXYP(val: valValue)
        } else if let vf = Double(valueArray[1]) {
            //print("valName, vf: \(valName), \(vf)")
            switch valName {
            case "Alt":
                tele.prevAlt = vf
            case "Spd":
                tele.prevSpd = vf
            case "EGT":
                tele.prevEGT = vf
            case "Frm":
                tele.prevFRM = vf
            case "RPM":
                tele.prevRPM = vf
            ///self.turbineRPM.currentValue = CGFloat(prevRPM)
            case "Tim":
                writeValue(data:"\(vf)")
            default:
                if valName != "Seq"  {
                    print("bad identifier \(valName)")
                }
            }
            //drawTape(leftVal: tele.prevSpd, rightVal: tele.prevAlt, topVal: tele.heading)
        }
    } while true

}

private func readXYP(val: String) {
    var tx: Double
    var ty: Double
    let xrange:[Double] = [1500, 3000, 6000]
    
    return
    let xyPos = val.components(separatedBy: "$")

    if xyPos.count == 2 {

        tx = Double(xyPos[0]) ?? 0.0
        ty = Double(xyPos[1]) ?? 0.0

        if tx == 0.0 || ty == 0.0 {
            print("ZERO on Input: tx, ty: \(tx), \(ty)")
        }
        //print("tx, ty: \(tx), \(ty)")
        tele.currentXd = tx
        tele.currentYd = ty

        for i in 1 ..< MAXTABLE {
            if xp[i] == 0.0 || yp[i] == 0.0 {
                print("ZERO on Shift: tx, ty: \(i), \(xp[i]), \(yp[i])")
            }
            xp[i-1] = xp[i]
            yp[i-1] = yp[i]
        }
        
        xp.remove(at: 0)
        yp.remove(at: 0)
        
        xp.append(tx)
        yp.append(ty)
        
        if activeField.imageIdx >= 0 {
            let xr = xrange[activeField.imageIdx]/2
            let yr = xrange[activeField.imageIdx]/8
            
            if (tx > xr) || (tx < -xr) || (ty > 3*yr) || (ty < -yr) {
                if activeField.imageIdx + 1 < xrange.count {
                    activeField.imageIdx = activeField.imageIdx + 1
                }
            }
        }
        //let rotationAngle: Double = fslope(x: xp, y: yp, n: MAXTABLE, ymult: -1) // mult -1 since rotation is in pixel space, data in xy space and y is inverted between them
        //heading = rotationAngle * 180.0 / Double.pi
        computeBezier(numT: MAXBEZIER)
        
        //print("Bxp[0], Byp[0]: \(Bxp[0]), \(Byp[0])")
        
    } else {
        print("bad format on XYP")
    }
}


// This func has not been ported .. probably won't work without a going-over...

private func readGPS(val: String) {

    let xrange:[Double] = [1500, 3000, 6000]
    print("*********** readGPS ******************************")
    print("lat0 lon0: \(activeField.latitude), \(activeField.longitude)")
    
    
    let latlon = val.components(separatedBy: "$")
    if latlon.count == 2 {
        if let dlat = Double(latlon[0]), let dlon = Double(latlon[1]) {
            print("after if let - lat, lon: \(dlat), \(dlon)")
            var tx: Double
            var ty: Double
            
            (tx, ty) = GPStoXY(lat: dlat, lon: dlon)

            print("back from GPStoXY: \(tx), \(ty)")
            tele.currentXd = tx
            tele.currentYd = ty

            for i in 1 ..< MAXTABLE {
                xp[i-1] = xp[i]
                yp[i-1] = yp[i]
                //    print("i,x,y: \(i), \(xp[i-1]), \(yp[i-1])")
            }

            xp.remove(at: 0)
            yp.remove(at: 0)
            xp.append(tx)
            yp.append(ty)
            
            if activeField.imageIdx >= 0 {
                let xr = xrange[activeField.imageIdx]/2
                let yr = xrange[activeField.imageIdx]/8
                
                if (tx > xr) || (tx < -xr) || (ty > 3*yr) || (ty < -yr) {
                    if activeField.imageIdx + 1 < xrange.count {
                        activeField.imageIdx = activeField.imageIdx + 1
                    }
                }
            }
            

            //(xx, yy) = XYtoPixel(px: xp.last!, py: yp.last!)
            
            //let rotationAngle: Double = fslope(x: xp, y: yp, n: MAXTABLE, ymult: -1) // mult -1 since rotation is in pixel space, data in xy space and y is inverted between them
            //heading = rotationAngle * 180.0 / Double.pi
            
            computeBezier(numT: MAXBEZIER)
            //cometBezier.removeAllPoints()
        }
    } else {
        print("bad lat lon decode")
    }
}

func writeValue(data: String){
    //print("in wV string: \(data)")
    if data == lastW {
        //print("same, returning")
        return
    }
    //let encap: String = "(" + data + ")"
    let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
    //change the "data" to valueString
    if let blePeripheral = blePeripheral{
        if let txCharacteristic = txCharacteristic {
            blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    lastW = data
}

func writeCharacteristic(val: Int8){
    var val = val
    let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
    blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
}
