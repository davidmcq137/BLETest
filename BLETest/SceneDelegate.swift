//
//  SceneDelegate.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/11/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

/*
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
}

*/

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print("scene will connect to session")
        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = ContentView().environment(\.managedObjectContext, context)

        tele = Telem()
        
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(tele))
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("scene did disconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("scene did become active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("scene will resign active")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        print("scene will enter foreground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        print("scene did enter background")
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}
/*
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
    //print(val)
    let xyPos = val.components(separatedBy: "$")
    if xyPos.count == 2 {
        tx = Double(xyPos[0]) ?? 0.0
        ty = Double(xyPos[1]) ?? 0.0
        //print(tx,ty)
            for i in 1 ..< MAXTABLE {
                xp[i-1] = xp[i]
                yp[i-1] = yp[i]
                //    print("i,x,y: \(i), \(xp[i-1]), \(yp[i-1])")
            }
            
        xp.remove(at: 0)
        yp.remove(at: 0)
        
        xp.append(tx)
        yp.append(ty)
        
        tele.currentXd = tx
        tele.currentYd = ty
        
        var xx: Double
        var yy: Double
        
        (xx, yy) = XYtoPixel(px: xp.last!, py: yp.last!)
        
        let rotationAngle: Double = fslope(x: xp, y: yp, n: MAXTABLE, ymult: -1) // mult -1 since rotation is in pixel space, data in xy space and y is inverted between them
        heading = rotationAngle * 180.0 / Double.pi
        
        computeBezier(numT: MAXBEZIER)
        //cometBezier.removeAllPoints()
        
        for i in 0 ... MAXBEZIER {
            var bx: Double
            var by: Double
            (bx, by) = XYtoPixel(px: Bxp[i], py: Byp[i])
            if i == 0 || i == MAXBEZIER {  //first point
                //cometBezier.move(to: CGPoint(x: bx, y: by))
            } else {
                //cometBezier.addLine(to: CGPoint(x: bx, y: by))
            }
        }
        //cometLayer.path = cometBezier.cgPath
        //self.view.layer.addSublayer(cometLayer)
        
    }
}


private func readGPS(val: String) {
    let latlon = val.components(separatedBy: "$")
    if latlon.count == 2 {
        if let dlat = Double(latlon[0]), let dlon = Double(latlon[1]) {
            for i in 1 ..< MAXTABLE {
                xp[i-1] = xp[i]
                yp[i-1] = yp[i]
            //    print("i,x,y: \(i), \(xp[i-1]), \(yp[i-1])")
            }
            var tx: Double
            var ty: Double
            
            (tx, ty) = GPStoXY(lat: dlat, lon: dlon)
            xp.remove(at: 0)
            yp.remove(at: 0)
            xp.append(tx)
            yp.append(ty)
            
            var xx: Double
            var yy: Double
            
            (xx, yy) = XYtoPixel(px: xp.last!, py: yp.last!)
            
            //let rotationAngle: Double = fslope(x: xp, y: yp, n: MAXTABLE, ymult: -1) // mult -1 since rotation is in pixel space, data in xy space and y is inverted between them
            //heading = rotationAngle * 180.0 / Double.pi
            
            computeBezier(numT: MAXBEZIER)
            //cometBezier.removeAllPoints()
            
            for i in 0 ... MAXBEZIER {
                var bx: Double
                var by: Double
                (bx, by) = XYtoPixel(px: Bxp[i], py: Byp[i])
                if i == 0 || i == MAXBEZIER {  //first point
                    //cometBezier.move(to: CGPoint(x: bx, y: by))
                } else {
                    //cometBezier.addLine(to: CGPoint(x: bx, y: by))
                }
            }
            //cometLayer.path = cometBezier.cgPath
            //self.view.layer.addSublayer(cometLayer)
            
        }
    } else {
        print("bad lat lon decode")
    }
}
*/
