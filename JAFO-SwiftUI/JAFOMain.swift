//
//  JAFOMain.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/19/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine

struct JAFOMain: View {
    
    @EnvironmentObject var tel: Telem
    
    let maxValue: Double = 100
    
    var body: some View {
        VStack (spacing: 45) { // no idea why this spacing works ... 
            FieldMap()//.border(Color.blue)
            HStack (spacing: 150) {
                Gauge(value: self.tel.prevEGT, title: "EGT", labels: [0, 200, 400, 600, 800], minValue: 0.0, maxValue: 800.0).frame(width:150, height:150).foregroundColor(.red)//.border(Color.yellow)
                
                Gauge(value: self.tel.prevRPM, title: "RPM", labels: [0, 25, 50, 75, 100, 125, 150], minValue: 0.0, maxValue: 150.0).frame(width:150, height:150).foregroundColor(.blue)//.border(Color.yellow)
            }
            
            
            HStack (spacing: 150) {
                txStick(vert: self.tel.stickP[3], horiz: self.tel.stickP[2]).frame(width:150, height: 150)//.border(Color.green)
                txStick(vert: self.tel.stickP[1], horiz: self.tel.stickP[0]).frame(width:150, height: 150)//.border(Color.green)
            }
            
            
            ProgressBar(value: self.tel.prevFRM,
                        maxValue: self.maxValue,
                        foregroundColor: .blue)
                .frame(width: 200, height: 10)
                .padding(5)//.border(Color.red)
            Text("Fuel Remaining: \(Int(self.tel.prevFRM), specifier: "%d%%")").font(.body).foregroundColor(.blue)//.border(Color.yellow)

            if tel.BLEUserData == false {
                AlertView()
            }

            Spacer()
            
        }.background(SwiftUI.Color.black).edgesIgnoringSafeArea(.top)
    }
}


