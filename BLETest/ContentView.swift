//
//  ContentView.swift
//  BLETest
//
//  Created by David Mcqueeney on 1/11/20.
//  Copyright © 2020 David Mcqueeney. All rights reserved.
//

import SwiftUI
import Combine



struct ContentView: View {
    //    @State private var sliderValue: Double = 0
    
    @EnvironmentObject var tel: Telem
    
    
    private let maxValue: Double = 100
    
    var body: some View {
        
        VStack (spacing: 40) {
            GeometryReader { gRR in
                ZStack (alignment: .top){
                    fieldImage(idx: currentImageIndex)//.edgesIgnoringSafeArea(.horizontal)
                    fieldAnnotation(idx: currentImageIndex)
                    drawRunway(idx: currentImageIndex, width: Double(gRR.size.width), height: Double(gRR.size.width)/2).foregroundColor(.yellow)
                    drawPOIs(idx: currentImageIndex, width: Double(gRR.size.width), height: Double(gRR.size.width)/2).foregroundColor(.yellow)
                    iconT38(idx: currentImageIndex, rotA: fslope(ymult: -1)).position(
                        x: xPix(xd: self.tel.currentXd, width:  Double(gRR.size.width)),
                        y: yPix(yd: self.tel.currentYd, height: Double(gRR.size.width) / 2)
                    ).foregroundColor(.yellow)
                    bezPath(idx: currentImageIndex, xd: self.tel.currentXd, yd: self.tel.currentYd, width: Double(gRR.size.width), height: Double(gRR.size.width / 2)).foregroundColor(.yellow)
                    //Text("\r\n\r\nwidth:\(gRR.size.width) height: \(gRR.size.height)").foregroundColor(.yellow)
                    HStack (spacing: 600) {
                        drawTape(Val: self.tel.prevAlt, side: "Left" ).frame(width: 80, height: 350).padding(.top)
                        drawTape(Val: self.tel.prevSpd, side: "Right").frame(width: 80, height: 350).padding(.top)
                    }
                }
            }
            //Button(action: {
            //    print("Ouch!")
            //
            //}) {
            //    Text("Button title").padding(.all, 12).foregroundColor(.blue).background(Color.yellow)
            //}

            HStack (spacing: 100) {
                Gauge(value: self.tel.prevEGT, title: "EGT", labels: [0, 200, 400, 600, 800], minValue: 0.0, maxValue: 800.0).frame(width:150, height:150).foregroundColor(.red)
                
                Gauge(value: self.tel.prevRPM, title: "RPM", labels: [0, 25, 50, 75, 100, 125, 150], minValue: 0.0, maxValue: 150.0).frame(width:150, height:150).foregroundColor(.blue)
            }


            HStack (spacing: 150) {
                txStick(vert: self.tel.stickP[3], horiz: self.tel.stickP[2]).frame(width:150, height: 150)
                txStick(vert: self.tel.stickP[1], horiz: self.tel.stickP[0]).frame(width:150, height: 150)
            }
            
            
            ProgressBar(value: self.tel.prevFRM,
                        maxValue: self.maxValue,
                        foregroundColor: .blue)
                .frame(height: 10)
                .padding(10)
            Text("Fuel Remaining: \(Int(self.tel.prevFRM), specifier: "%d%%")").font(.body).foregroundColor(.blue)
            Spacer()
            
        } .background(SwiftUI.Color.black.edgesIgnoringSafeArea(.all))
    }
}


//struct ContentView: View {
//    @EnvironmentObject var tel: Telem
//    var body: some View {
//        Text("Hello World. Frm: \(self.tel.prevFRM)")
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
