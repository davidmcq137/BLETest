//
//  fieldImage.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/13/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI

struct fieldImage: View {
    
    private let idx: Int?
    
    init(idx: Int?) {
        self.idx = idx
    }
    
    var body: some View {
        var imageName: String!
        if activeField.imageIdx >= 0 { // idx is -1 if no field selected
            imageName =  activeField.images[activeField.imageIdx] + ".png"
        } else {
            imageName =  "iPad_FBF_6000_ft.png"
        }
        
        let imageURL =  getDocumentsDirectory().appendingPathComponent(imageName)
        let imagePath = imageURL.path
        guard
            FileManager.default.fileExists(atPath: imagePath),
            let imageData: Data = try? Data(contentsOf: imageURL),
            let image: UIImage = UIImage(data: imageData) else {
                //fatalError("no image found: \(imagePath) filemanager")
                fatalError("no image found: \(imagePath) filemanager")

        }
        print("image size: width height", image.size.width, image.size.height)

        return Image(uiImage: image).resizable().clipped().aspectRatio(2, contentMode: .fit)
        //return Image(uiImage: image).resizable().scaledToFit()
    }
}

struct drawRunway: Shape {

    private let idx: Int?
    private let width: Double
    private let height: Double
    
    init(idx: Int?, width: Double, height: Double) {
        self.idx = idx
        self.width = width
        self.height = height
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if idx == nil {
            return path
        }

        let hrwW = activeField.runwaywidth / 2
        let hrwL = activeField.runwaylength / 2
        
        path.move(to: CGPoint(x: xPix(xd: -hrwL, width: self.width), y: yPix(yd: -hrwW, height: self.height)))
        path.addLine(to: CGPoint(x: xPix(xd: -hrwL, width: self.width), y: yPix(yd: hrwW, height: self.height)))
        path.addLine(to: CGPoint(x: xPix(xd:  hrwL, width: self.width), y: yPix(yd: hrwW, height: self.height)))
        path.addLine(to: CGPoint(x: xPix(xd:  hrwL, width: self.width), y: yPix(yd: -hrwW, height: self.height)))
        path.addLine(to: CGPoint(x: xPix(xd: -hrwL, width: self.width), y: yPix(yd: -hrwW, height: self.height)))
        
        return path.strokedPath(StrokeStyle(lineWidth: CGFloat(1.5)))
    }
}

struct drawPOIs: View {
    
    private let idx: Int?
    private let width: Double
    private let height: Double
    
    init(idx: Int?, width: Double, height: Double) {
        self.idx = idx
        self.width = width
        self.height = height
    }
    var body: some View {
        ZStack { // have to have this because of conditional on currentField. Tried @ViewBuilder to no avail...
            Text("Testing 123")
//            if (activeField.imageIdx >= 0) {
//                //ForEach ((0 ... (currentField!.POI!.count - 1) ), id: \.self) {
//                    Circle()
//                        .fill(Color.yellow)
//                        .frame(width: CGFloat(self.width/40), height: CGFloat(self.height/40))
//                        .position(x: xPix(xd: GPStoX(lat: currentField!.POI![$0].lat, lon: currentField!.POI![$0].long),
//                                          width: self.width),
//                                  y: yPix(yd: GPStoY(lat: currentField!.POI![$0].lat, lon: currentField!.POI![$0].long), height: self.height))
//                }
//            }
         }
    }
}
