//
//  FieldMap.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/19/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine

struct FieldMap: View {
    
    @EnvironmentObject var tel: Telem
    
    var body: some View {
        GeometryReader { gRR in
            ZStack (alignment: .top){
                fieldImage(idx: activeField.imageIdx)//.border(Color.green)
                fieldAnnotation(idx: activeField.imageIdx)//.border(Color.pink)
                drawRunway(idx: activeField.imageIdx, width: Double(gRR.size.width), height: Double(gRR.size.width)/2).foregroundColor(.yellow)//.border(Color.purple)
                //drawPOIs(idx: activeField.imageIdx, width: Double(gRR.size.width), height: Double(gRR.size.width)/2).foregroundColor(.yellow)//.border(Color.black)
                iconT38(idx: activeField.imageIdx, rotA: fslope(ymult: -1)).position(
                    x: xPix(xd: self.tel.currentXd, width:  Double(gRR.size.width)),
                    y: yPix(yd: self.tel.currentYd, height: Double(gRR.size.width) / 2)
                ).foregroundColor(.yellow)//.border(Color.red)
                bezPath(idx: activeField.imageIdx, xd: self.tel.currentXd, yd: self.tel.currentYd, width: Double(gRR.size.width), height: Double(gRR.size.width / 2)).foregroundColor(.yellow)//.border(Color.yellow)
                //Text("\r\n\r\nwidth:\(gRR.size.width) height: \(gRR.size.height)").foregroundColor(.yellow)
                HStack (spacing: 600) {
                    drawTape(Val: self.tel.prevAlt, side: "Left", title:"Altitude").frame(width: 75, height: 330).padding(.top)
                    drawTape(Val: self.tel.prevSpd, side: "Right", title: "Airspeed").frame(width: 75, height: 330).padding(.top)
                }
            }
        }
    }
}
